#!/bin/bash
[ $# -lt 2 ] && {
echo -e "sh $0 ref.fa genomesdir"
echo -e "the format of title in fasta files(.fa) should be >Spei_scaffoldid"
echo -e "EXAMPLE: sh $0 Tbai.fa genomes"
} && exit 1
refgenome=$1
querygenome_dir=$2
cmdir=$(cd $(dirname $0);pwd)
toolsdir=$cmdir/tools 
#split and convert refer genomes
fastaDeal.pl --cutf 20 $refgenome 
ls ${refgenome}.cut/${refgenome}.* | parallel -j 10 -I{} $cmdir/faToTwoBit {} {}.2bit
ls ${refgenome}.cut/${refgenome}.{1..20} | parallel -j 20 -I{} fastaDeal.pl -attr id:len {} ">" {}.size

ls $querygenome_dir/*.fa|parallel -j 10 -I{} $cmdir/faToTwoBit {} {.}.2bit
ls $querygenome_dir/*.fa|parallel -j 10 -I{} fastaDeal.pl -attr id:len {} ">" {}.size
