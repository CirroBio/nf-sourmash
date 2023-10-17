# nf-sourmash
Nextflow workflow running sourmash

## Inputs

**--samplesheet**

Simple CSV with columns `sample` and `file`.
Everything in the `file` column should be a FASTQ.
All of the FASTQ files with the same `sample` label will be combined.

**--k**

Value of _k_ used for sketching the input data.

> The value of _k_ **must** match the database used

**--db**

Database file used for searching

**--tax_db**

Taxonomy database -- can be compiled from CSV with ([docs](https://sourmash.readthedocs.io/en/latest/command-line.html#sourmash-tax-prepare-prepare-and-or-combine-taxonomy-files)):

```
sourmash tax prepare --taxonomy file1.csv file2.csv -o tax.db
```

**--output**

Folder for all output files. Example structure:

```
output
├── [ 128]  gather
│   ├── [9.9K]  SRR8859675_1.gather.csv
│   └── [9.9K]  SRR8859675_2.gather.csv
├── [ 288]  logs
│   ├── [2.1K]  SRR8859675_1.gather.log
│   ├── [7.9K]  SRR8859675_1.sketch.log
│   ├── [4.2K]  SRR8859675_1.tax.metagenome.log
│   ├── [2.1K]  SRR8859675_2.gather.log
│   ├── [7.9K]  SRR8859675_2.sketch.log
│   ├── [4.2K]  SRR8859675_2.tax.metagenome.log
│   └── [4.9K]  all.tax.metagenome.log
├── [ 128]  matches
│   ├── [423K]  SRR8859675_1.matches.zip
│   └── [423K]  SRR8859675_2.matches.zip
├── [ 128]  sketch
│   ├── [1.3M]  SRR8859675_1.sig.gz
│   └── [1.5M]  SRR8859675_2.sig.gz
└── [ 832]  tax_metagenome
    ├── [ 631]  SRR8859675_1.tax.metagenome.class.krona.tsv
    ├── [ 942]  SRR8859675_1.tax.metagenome.family.krona.tsv
    ├── [1.4K]  SRR8859675_1.tax.metagenome.genus.krona.tsv
    ├── [2.5K]  SRR8859675_1.tax.metagenome.human.txt
    ├── [2.3K]  SRR8859675_1.tax.metagenome.kreport.txt
    ├── [ 788]  SRR8859675_1.tax.metagenome.order.krona.tsv
    ├── [ 436]  SRR8859675_1.tax.metagenome.phylum.krona.tsv
    ├── [2.4K]  SRR8859675_1.tax.metagenome.species.krona.tsv
    ├── [ 13K]  SRR8859675_1.tax.metagenome.summarized.csv
    ├── [ 632]  SRR8859675_2.tax.metagenome.class.krona.tsv
    ├── [ 943]  SRR8859675_2.tax.metagenome.family.krona.tsv
    ├── [1.4K]  SRR8859675_2.tax.metagenome.genus.krona.tsv
    ├── [2.5K]  SRR8859675_2.tax.metagenome.human.txt
    ├── [2.3K]  SRR8859675_2.tax.metagenome.kreport.txt
    ├── [ 789]  SRR8859675_2.tax.metagenome.order.krona.tsv
    ├── [ 438]  SRR8859675_2.tax.metagenome.phylum.krona.tsv
    ├── [2.4K]  SRR8859675_2.tax.metagenome.species.krona.tsv
    ├── [ 13K]  SRR8859675_2.tax.metagenome.summarized.csv
    ├── [ 796]  all.tax.metagenome.class.lineage_summary.tsv
    ├── [1.0K]  all.tax.metagenome.family.lineage_summary.tsv
    ├── [1.6K]  all.tax.metagenome.genus.lineage_summary.tsv
    ├── [ 934]  all.tax.metagenome.order.lineage_summary.tsv
    ├── [ 598]  all.tax.metagenome.phylum.lineage_summary.tsv
    └── [2.7K]  all.tax.metagenome.species.lineage_summary.tsv

```

**--container**

Docker container used to run the commands in the workflow.

Default: `quay.io/biocontainers/sourmash:4.8.4--hdfd78af_0`

**--threshold_bp**

Minimum number of basepairs required for a match (default: 50000)

**--ranks**

Taxonomic ranks over which results will be summarized.

Default: `phylum class order family genus species strain`
