#!/bin/bash
workdir=/data/share/yancc/GenoComp/07.CNE_detect/00.data_prepare
export PERL5LIB=$PERL5LIB:/data/share/yancc/GenoComp/07.CNE_detect/00.data_prepare/tools/perl5lib
perl tools/run.Phastcons.2.1.pl \
-ph tools/phast-1.3/bin \
-m $workdir/splitmaf \
-b tools/bedtools2/bin \
-th 4 \
-ct 4 \
-pr tools/prank-msa/bin \
-tr CNE.tre \
-cd Tbai.gff \
-re Tbai
