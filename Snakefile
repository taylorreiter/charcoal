genome_list = [ line.strip() for line in open('genome-list.txt', 'rt') ]

rule all:
    input:
        expand('genomes/{g}.hashes', g=genome_list),
        expand('genomes/{g}.hashes.fragment.100000', g=genome_list),
        expand('genomes/{g}.hashes.fragment.10000', g=genome_list),
        expand('genomes/{g}.hashes.fragment.5000', g=genome_list),
        expand('genomes/{g}.hashes.fragment.100000.matrix.csv', g=genome_list),

rule make_hashes:
    input:
        'genomes/{filename}.fna'
    output:
        'genomes/{filename}.fna.hashes'
    conda: 'env-sourmash.yml'
    shell: """
        ./process-genome.py {input} {output}
     """

rule make_hashes_fragment:
    input:
        'genomes/{filename}.fna'
    output:
        hashes='genomes/{filename}.fna.hashes.fragment.{size,\d+}',
        stats='genomes/{filename}.fna.hashes.fragment.{size,\d+}.stats'
    conda: 'env-sourmash.yml'
    shell: """
        ./process-genome.py {input} {output.hashes} \
             --fragment {wildcards.size} --stats {output.stats}
     """

rule make_matrix_csv:
    input:
        hashes='genomes/{filename}.hashes{postfix}',
        metag_list='ibd_metagenome_prefixes.txt.20'
    output:
        'genomes/{filename}.hashes{postfix}.matrix.csv'
    conda: 'env-sourmash.yml'
    shell: """
        ./match-metagenomes.py {input.hashes} {input.metag_list} {output}
    """

