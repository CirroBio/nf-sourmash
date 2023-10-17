#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

workflow parse_samplesheet {

    main:
        if(!params.samplesheet){
            error "Must provide --samplesheet: Spreadsheet with columns sample,file"
        }

        // Read the samplesheet
        // Make sure that the columns sample and file are present
        // Map to the file in the 'file' column
        // Group all of the files with the same 'sample'
        Channel
            .fromPath(
                params.samplesheet,
                checkIfExists: true
            )
            .splitCsv(
                header: true
            )
            .ifEmpty({error "No rows found in ${params.samplesheet}"})
            .filter { "${it['sample']}" != "null" }
            .ifEmpty({error "Missing column 'sample' in ${params.samplesheet}"})
            .filter { "${it['file']}" != "null" }
            .ifEmpty({error "Missing column 'file' in ${params.samplesheet}"})
            .map {
                it -> [
                    it['sample'],
                    file(
                        it['file'],
                        checkIfExists: true
                    )
                ]
            }
            .groupTuple()
            .set { samplesheet_ch }

    emit:
        samplesheet_ch
}