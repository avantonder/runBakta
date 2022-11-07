process BAKTA {
    tag "${fasta.baseName}"
    label 'process_medium'
    label 'error_retry'

    conda (params.enable_conda ? "bioconda::bakta=1.5.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bakta:1.5.0--pyhdfd78af_0' :
        'quay.io/biocontainers/bakta:1.5.0--pyhdfd78af_0' }"

    input:
    file(fasta)
    path db
    path proteins
    path prodigal_tf

    output:
    tuple val(${fasta.baseName}), path("${prefix}.embl")             , emit: embl
    tuple val(${fasta.baseName}), path("${prefix}.faa")              , emit: faa
    tuple val(${fasta.baseName}), path("${prefix}.ffn")              , emit: ffn
    tuple val(${fasta.baseName}), path("${prefix}.fna")              , emit: fna
    tuple val(${fasta.baseName}), path("${prefix}.gbff")             , emit: gbff
    tuple val(${fasta.baseName}), path("${prefix}.gff3")             , emit: gff
    tuple val(${fasta.baseName}), path("${prefix}.hypotheticals.tsv"), emit: hypotheticals_tsv
    tuple val(${fasta.baseName}), path("${prefix}.hypotheticals.faa"), emit: hypotheticals_faa
    tuple val(${fasta.baseName}), path("${prefix}.tsv")              , emit: tsv
    tuple val(${fasta.baseName}), path("${prefix}.txt")              , emit: txt
    path "versions.yml"                                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''
    prefix   = task.ext.prefix ?: "${fasta.baseName}"
    def proteins_opt = proteins ? "--proteins ${proteins[0]}" : ""
    def prodigal_opt = prodigal_tf ? "--prodigal-tf ${prodigal_tf[0]}" : ""
    """
    bakta \\
        $args \\
        --threads $task.cpus \\
        --prefix $prefix \\
        --db $db \\
        $proteins_opt \\
        $prodigal_tf \\
        $fasta
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bakta: \$( echo \$(bakta --version 2>&1) | sed 's/^.*bakta //' )
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${${fasta.baseName}.id}"
    """
    touch ${prefix}.embl
    touch ${prefix}.faa
    touch ${prefix}.ffn
    touch ${prefix}.fna
    touch ${prefix}.gbff
    touch ${prefix}.gff3
    touch ${prefix}.hypotheticals.tsv
    touch ${prefix}.hypotheticals.faa
    touch ${prefix}.tsv
    touch ${prefix}.txt
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bakta: \$( echo \$(bakta --version 2>&1) | sed 's/^.*bakta //' )
    END_VERSIONS
    """
}