#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process sketch {
    publishDir "${params.output}/sketch/", mode: 'copy', overwrite: true, pattern: "*.sig.gz"
    publishDir "${params.output}/logs/", mode: 'copy', overwrite: true, pattern: "*.log"
    tag "${sample}"
    container "${params.container}"

    input:
    tuple val(sample), path("inputs/")

    output:
    tuple val(sample), path("${sample}.sig.gz"), emit: sig
    path("${sample}.sketch.log"), emit: log

    """#!/bin/bash
set -e

echo "Sketching DNA inputs:"
ls -lah inputs/

sourmash sketch dna \
    --param-string k=${params.ksize},abund \
    inputs/* \
    --output "${sample}.sig.gz" \
    --name "${sample}" \
    2>&1 | tee "${sample}.sketch.log"
"""
}

workflow sketch_wf {
    take:
        input_ch
    main:
        if(!params.ksize){error "Must provide param: ksize"}
        if(!params.output){error "Must provide param: output"}
        sketch(input_ch)
    emit:
        sketch.out.sig
}

workflow {

    log.info"""
########################
# nf-sourmash / sketch #
########################

Parameters:
    samplesheet: ${params.samplesheet}
    ksize:       ${params.ksize}
    output:      ${params.output}
    """

    // Parse the input
    // Sketch the input files
    parse_samplesheet | sketch_wf

}
