# ArchivesSpace Illinois Plugin

## Overview
This plugin customizes ArchivesSpace to meet the specific needs of the University of Illinois Urbana-Champaign Library.

## Features
- University of Illinois Urbana-Champaign branding.
- Automatic EAD ID generation based on resource identifiers.
- Moves the Finding Aid Filing Title field after the Title field in the staff interface and relabels it as "Sort Title".
- Reconfigures "print_to_pdf_job" job types to permit concurrent execution based on the number of threads available to run background jobs (`AppConfig[:job_thread_count]`).

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
5. Restart ArchivesSpace to apply the changes.

