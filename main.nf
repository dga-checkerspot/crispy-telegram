#!/usr/bin/env nextflow

params.reads='s3://algaetranscriptomics/CHK*_R{1,2}_001.fastq.gz'
geno='s3://invertase/CHK15_computomics_scrB_extraction.fasta'


process minimapALIGN {

	memory '4G'

	input:
	tuple val(pair_id), path(reads) from read_pairs_ch
	path genom from geno
	
	output:
	set pair_id, "minimap.out.bam" into align_ch
	

    """
    minimap2 -ax sr $genom "${pair_id}_R1_001.fastq.gz" "${pair_id}_R2_001.fastq.gz" > aln.sam
    samtools view -bS aln.sam > minimap.out.bam
    """

}


process merge {

	memory '4G'

	input:
	tuple val(pair_id), path(fileList) from align_ch.collect()
	
	output:
	file 'merged.s.bam' into merged_bam
	
	"""
	echo `ls * ` > dir.txt
	samtools merge -b dir.txt merged.bam
	samtools sort merged.bam > merged.s.bam
	
	"""
}
