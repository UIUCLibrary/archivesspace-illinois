class PrintToPDFRunner < JobRunner
  include JSONModel

  register_for_job_type('print_to_pdf_job', {
    :allow_reregister => true,
    :run_concurrently => true
  })

  def run
    begin
      RequestContext.open( :repo_id => @job.repo_id) do
        parsed = JSONModel.parse_reference(@json.job["source"])
        resource = Resource.get_or_die(parsed[:id])
        resource_jsonmodel = Resource.to_jsonmodel(resource)

        @job.write_output("Generating PDF for #{resource_jsonmodel["title"]}  ")

        obj = URIResolver.resolve_references(resource_jsonmodel,
                                            [ "repository", "linked_agents", "subjects", "digital_object", 'top_container', 'top_container::container_profile'])
        opts = {
          :include_unpublished => @json.job["include_unpublished"] || false,
          :include_daos => true,
          :use_numbered_c_tags => false
        }

        if obj["repository"]["_resolved"]["image_url"]
          image_for_pdf = obj["repository"]["_resolved"]["image_url"]
        else
          image_for_pdf = nil
        end

        record = JSONModel(:resource).new(obj)

        if record['publish'] === false
          @job.write_output("-" * 50)
          @job.write_output("Warning: this resource has not been published")
          @job.write_output("-" * 50)
        end

        ead = ASpaceExport.model(:ead).from_resource(record, resource.tree(:all, mode = :sparse), opts)
        xml = ""
        ASpaceExport.stream(ead).each { |x| xml << x }
        pdf = ASFop.new(xml, image_for_pdf).to_pdf
        job_file = @job.add_file( pdf )
        @job.write_output("File generated at #{job_file.full_file_path.inspect} ")

        # pdf will be either a Tempfile or File object, depending on whether it was created externally.
        if pdf.class == Tempfile
          pdf.unlink
        elsif pdf.class == File
          File.unlink(pdf.path)
        end

        @job.write_output("All done. Please click refresh to view your download link.")
        self.success!
        job_file
      end
    rescue Exception => e
      @job.write_output(e.message)
      @job.write_output(e.backtrace)
      raise e
    end
  end


end
#from commit 32053b3

# Returns only records of resources, digital objects and agents that have been
# deleted since the given timestamp. This is intended to be used by ArcFlow to
# identify records that need to be removed from the search index without having
# to fetch all records that have been deleted since the given timestamp, which 
# may include a large number of records that ArcFlow doesn't need to know about.
class ArchivesSpaceService < Sinatra::Base
    Endpoint.get('/delete-feed-restricted')
    .description("Get a stream of deleted records")
    .permissions([:index_system])
    .params()
    .paged(true)
    .returns([200, "a list of URIs that were deleted"]) \
  do
    modified_since_time = Time.at(params[:modified_since])

    dataset = Tombstone.where { timestamp >= modified_since_time  }.where(
      Sequel.|(
        Sequel.like(:uri, '/repositories/%/digital_objects/%'),
        Sequel.like(:uri, '/repositories/%/resources/%'),
        Sequel.like(:uri, '/agents/%'),
      )
    )
    dataset = dataset.extension(:pagination).paginate(params[:page], params[:page_size])

    response = {
      :first_page => dataset.page_range.first,
      :last_page => dataset.page_range.last,
      :this_page => dataset.current_page,
      :results => dataset.map(&:uri)
    }

    json_response(response)
  end

end