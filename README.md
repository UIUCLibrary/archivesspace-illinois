# ArchivesSpace Illinois Plugin

## Overview
This plugin customizes ArchivesSpace to meet the specific needs of the University of Illinois Urbana-Champaign Library.

## Features
- University of Illinois Urbana-Champaign branding.
- Automatic EAD ID generation based on resource identifiers.
- Moves the Finding Aid Filing Title field after the Title field in the staff interface and relabels it as "Sort Title".
- Reconfigures "print_to_pdf_job" job types to permit concurrent execution based on the number of threads available to run background jobs (`AppConfig[:job_thread_count]`).
- Adds a `delete-feed-restricted` endpoint to return only records of resources, digital objects and agents that have been deleted since a given timestamp to be used by ArcFlow to identify records that need to be removed from the search index without having to fetch all records.
- Adds file upload support to ArchivesSpace digital object components. Uploaded files are stored temporarily and intended for ingestion into external applications like Omeka, supporting workflows where metadata is managed in ArchivesSpace and digital assets are hosted elsewhere.

## Installation
1. Clone this repository into your ArchivesSpace plugins directory:
    ```bash
    cd /path/to/archivesspace/plugins
    git clone https://github.com/illinois-library/archivesspace-illinois.git
    ```
2. Add `archivesspace-illinois` to the `plugins` array in your `config/config.rb` file:
    ```ruby
    AppConfig[:plugins] = ['archivesspace-illinois', ...]
    ```
3. Set the `illinois` theme for both staff and public interfaces in your `config/config.rb` file:
    ```ruby
    AppConfig[:frontend_theme] = 'illinois'
    AppConfig[:public_theme] = 'illinois'
    ```
4. Configure the `illinois` branding image and alt text for both interfaces in your `config/config.rb` file:
    ```ruby
    AppConfig[:pui_branding_img] = 'themes/illinois/illinois.png'
    AppConfig[:pui_branding_img_alt_text] = 'University Library - University of Illinois Urbana-Champaign'
    AppConfig[:frontend_branding_img] = 'themes/illinois/illinois.png'
    AppConfig[:frontend_branding_img_alt_text] = 'University Library - University of Illinois Urbana-Champaign'
    ```
5.  Combine the `public/public.tar.gz.part.dd` and `frontend/frontend.tar.gz.part.dd` parts and extract them into the ArchivesSpace `wars` directory to replace the existing `public.war` and `frontend.war` files:
    ```bash
    cd /path/to/archivesspace/plugins/archivesspace-illinois
    cat frontend/frontend.tar.gz.part.* | tar -xzvf - -C /path/to/archivesspace/wars
    cat public/public.tar.gz.part.* | tar -xzvf - -C /path/to/archivesspace/wars
    ```
6. Restart ArchivesSpace to apply the changes.

