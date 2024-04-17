#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

include { parse_samplesheet } from './parse_samplesheet.nf'
include { sketch_wf } from './sketch.nf'
include { gather_wf } from './gather.nf'

process all {
    publishDir "${params.output}/tax_metagenome/", mode: 'copy', overwrite: true, pattern: "*.tsv"
    publishDir "${params.output}/tax_metagenome/", mode: 'copy', overwrite: true, pattern: "*.txt"
    publishDir "${params.output}/tax_metagenome/", mode: 'copy', overwrite: true, pattern: "*.csv"
    publishDir "${params.output}/logs/", mode: 'copy', overwrite: true, pattern: "*.log"
    container "${params.container}"

    input:
    path "inputs/"
    path tax_db

    output:
    path "*.tax.metagenome.*"

    """#!/bin/bash
set -e

sourmash tax metagenome \
    --gather-csv inputs/* \
    --output-base all.tax.metagenome \
    --output-dir "\$PWD" \
    --taxonomy ${tax_db} \
    --output-format csv_summary \
    2>&1 | tee -a "all.tax.metagenome.log"

for RANK in ${params.ranks}; do

    sourmash tax metagenome \
        --gather-csv inputs/* \
        --output-base all.tax.metagenome.\${RANK} \
        --output-dir "\$PWD" \
        --taxonomy ${tax_db} \
        --output-format lineage_summary \
        --rank \$RANK \
        2>&1 | tee -a "all.tax.metagenome.log"

done
"""
}

process single {
    publishDir "${params.output}/tax_metagenome/", mode: 'copy', overwrite: true, pattern: "*.tsv"
    publishDir "${params.output}/tax_metagenome/", mode: 'copy', overwrite: true, pattern: "*.txt"
    publishDir "${params.output}/tax_metagenome/", mode: 'copy', overwrite: true, pattern: "*.csv"
    publishDir "${params.output}/logs/", mode: 'copy', overwrite: true, pattern: "*.log"
    container "${params.container}"
    tag "${sample}"

    input:
    tuple val(sample), path(csv)
    path tax_db

    output:
    path "${sample}.tax.metagenome.*"

    """#!/bin/bash
set -e

sourmash tax metagenome \
    --gather-csv "${csv}" \
    --output-base ${sample}.tax.metagenome \
    --output-dir "\$PWD" \
    --taxonomy ${tax_db} \
    --output-format human csv_summary kreport \
    2>&1 | tee -a "${sample}.tax.metagenome.log"

for RANK in ${params.ranks}; do

    sourmash tax metagenome \
        --gather-csv "${csv}" \
        --output-base ${sample}.tax.metagenome.\${RANK} \
        --output-dir "\$PWD" \
        --taxonomy ${tax_db} \
        --output-format krona \
        --rank \$RANK \
        2>&1 | tee -a "${sample}.tax.metagenome.log"

done
"""
}


workflow tax_metagenome_wf {
    take:
        input_ch
    main:
        if(!params.tax_db){error "Must provide param: tax_db"}
        if(!params.output){error "Must provide param: output"}

        // Get the taxonomic database file
        tax_db = file(params.tax_db, checkIfExists: true)

        // Count k-mers from the database in each sample
        single(input_ch, tax_db)

        // Combine information across all samples
        all(
            input_ch
            .map{ it -> it[1] }
            .toSortedList(),
            tax_db
        )

    emit:
        all = all.out
        single = single.out
}

workflow {

    log.info"""
################################
# nf-sourmash / tax_metagenome #
################################

Parameters:
    samplesheet: ${params.samplesheet}
    db:          ${params.db}
    tax_db:      ${params.tax_db}
    ksize:       ${params.ksize}
    output:      ${params.output}
    """

    // Parse the input
    // Sketch the input files
    // Compare to a reference database
    parse_samplesheet | sketch_wf | gather_wf | tax_metagenome_wf

}