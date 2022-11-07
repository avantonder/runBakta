# runBakta
nextflow pipeline for running bakta on assemblies

Example command:

    ```bash
    NXF_VER=21.10.3 nextflow run avantonder/runBakta \
        -r main \
        -c cambridge.config \
        -profile singularity \ 
        --input samplesheet.csv \
        --baktadb /home/ajv37/rds/hpc-work/databases/db \
        --outdir runBakta_results
    ```
