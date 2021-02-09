#!/bin/bash
tooldir=/data/nfs/OriginTools/gene_anotation/structure/gth-1.7.1-Linux_x86_64-64bit
$tooldir/bin/gth \
-genomic GCA_000800605.1_Vber.be_1.0_genomic.fna \
-protein Tbai.pep.fa \
-species chicken \
-gff3out \
-o cds.fa.pep.fa.gth.gff \
-skipalignmentout \
-force

#gth -species chicken -translationtable 1 -gff3out -intermediate -protein Oapo.pep.fa -genomic ../Dopasia_harti.genome.fa -o Oapo.gff3
