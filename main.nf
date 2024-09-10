#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Load parameters from JSON file
params.config = 'params.json'
def json_params = jsonSlurper.parseText(file(params.config).text)
json_params.each { k, v -> params[k] = v }

// Input validation
if (!params.input_files) {
    exit 1, "Input files not specified!"
}

// Constants
params.container_version = "latest"

// Define the main workflow
workflow {
    Channel
        .fromPath(params.input_files)
        .set { input_ch }

    PROCESS_DATA(input_ch)
}

// Define the main process
process PROCESS_DATA {
    tag "Processing ${input_file.simpleName}"
    container "pipeline-test:latest"
    publishDir "${params.output_dir}", mode: 'copy'

    input:
    path input_file

    output:
    path "${params.output_file}"

    script:
    """
    python /app/process_data.py "$input_file" \
        OUTPUT_FILE="${params.output_file}" \
        STRING_PARAM="${params.string_param}" \
        INT_PARAM="${params.int_param}" \
        FLOAT_PARAM="${params.float_param}" \
        FILE_PARAM="${params.file_param}" \
        GLOB_FILES="${params.glob_files}" \
        FOLDER_PARAM="${params.folder_param}" \
        STRING_CHOICE="${params.string_choice}" \
        INT_RANGE="${params.int_range}" \
        FLOAT_RANGE="${params.float_range}"
    """
}
