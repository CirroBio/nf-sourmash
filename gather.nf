#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

include { parse_samplesheet } from './parse_samplesheet.nf'
include { sketch_wf } from './sketch.nf'

process gather {
    publishDir "${params.output}/gather/", mode: 'copy', overwrite: true, pattern: "*.gather.csv"
    publishDir "${params.output}/matches/", mode: 'copy', overwrite: true, pattern: "*.matches.zip"
    publishDir "${params.output}/logs/", mode: 'copy', overwrite: true, pattern: "*.log"
    container "${params.container}"
    tag "${sample}"

    input:
    tuple val(sample), path(sig)
    path db

    output:
    tuple val(sample), path("${sample}.gather.csv"), emit: csv, optional: true
    tuple val(sample), path("${sample}.matches.zip"), emit: matches, optional: true
    path("${sample}.gather.log"), emit: log

    """#!/bin/bash
set -e

# Log the description of the database
sourmash sig summarize "${db}"

# Compare the k-mers in the sample against the database
sourmash gather \
    "${sig}" \
    "${db}" \
    --ksize "${params.ksize}" \
    --output "${sample}.gather.csv" \
    --save-matches "${sample}.matches.zip" \
    --threshold-bp "${params.threshold_bp}" \
    --fail-on-empty-database \
    2>&1 | tee "${sample}.gather.log"
"""
}

workflow gather_wf {
    take:
        input_ch
    main:
        if(!params.db){error "Must provide param: db"}
        if(!params.output){error "Must provide param: output"}

        // Get the database file
        db = file(params.db, checkIfExists: true)

        // Count k-mers from the database in each sample
        gather(input_ch, db)
    emit:
        gather.out.csv

}

workflow {

    log.info"""
########################
# nf-sourmash / gather #
########################

Parameters:
    samplesheet: ${params.samplesheet}
    db:          ${params.db}
    ksize:       ${params.ksize}
    output:      ${params.output}
    """

    // Parse the input
    // Sketch the input files
    // Compare to a reference database
    parse_samplesheet | sketch_wf | gather_wf

}