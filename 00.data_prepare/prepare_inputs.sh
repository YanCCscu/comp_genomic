bin=./bin
#$bin/extract_longest_trans_NCBI_ensembl.pl 1|2|3 (1 for NCBI 2 for ensamble 3 for NCBI maker)<gff3> > longes_trans.id
genome_prefix=$1
gfffile=$2
fasfile=$3
echo obtain longest transid for $genome_prefix
$bin/extract_longest_trans_NCBI_ensembl.pl 1 $gfffile >${genome_prefix}_unique.ids
echo extract fa files based on gff and fasta files ...
$bin/gffread $gfffile -g $fasfile -x ${genome_prefix}.cds.all.fa -y ${genome_prefix}.pep.all.fa
echo extract sequences selected
fishInWinter.pl -bf table -bc 2 -ff fasta ${genome_prefix}_unique.ids ${genome_prefix}.cds.all.fa >${genome_prefix}.cds.fa
fishInWinter.pl -bf table -bc 2 -ff fasta ${genome_prefix}_unique.ids ${genome_prefix}.pep.all.fa >${genome_prefix}.pep.fa

#fishInWinter.pl -bf table -bc 3 -ff fasta --patternmode prepare_inputs/Pvit_unique.ids Pogona_vitticeps/GCF_900067755.1_pvi1.1/GCF_900067755.1_pvi1.1_protein.faa >Pvit.pep.fa

fishInWinter.pl -bf table -bc 3 -ff fasta --patternmode prepare_inputs/Pvit_unique.ids Pogona_vitticeps/GCF_900067755.1_pvi1.1/GCF_900067755.1_pvi1.1_translated_cds.faa >Pvit.cds.fa
