#!/bin/bash
#set -ex
if [ $# -lt 2 ]
then
	echo -e "sh $0 query refer split_num"
	echo -e "\e[1;91mexample: sh $0 Bcon Tbai.fa 20\e[0m\n"
	exit 1
fi
cmdir=$(cd $(dirname $0);pwd)
query=$1
querydir=$query
refer=$2
referdir=${refer}.cut
split_num=$3;

for i in $(seq 1 $split_num)
do 
#-------------axt to chain
((1)) && {
	$cmdir/kent/bin/linux.x86_64/axtChain \
	-linearGap=loose \
	$querydir/${query}.${refer}.${i}.axt \
	$referdir/${refer}.${i}.2bit \
	genomes/${query}.2bit $querydir/${query}.${i}.axt.chain
}
((1)) && {
	$cmdir/kent/bin/linux.x86_64/chainSort $querydir/$query.${i}.axt.chain $querydir/$query.${i}.axt.chain.sorted 
#------------chain to net
	$cmdir/GenomeAlignmentTools/bin/chainNet \
	-linearGap=medium \
	-rescore \
	-tNibDir=$referdir/${refer}.${i}.2bit \
	-qNibDir=genomes/${query}.2bit \
	$querydir/${query}.${i}.axt.chain.sorted \
	$referdir/${refer}.${i}.size \
	genomes/${query}.fa.size \
	$querydir/${refer}.${i}.net $querydir/${query}.${i}.net
#------------filter net
	$cmdir/GenomeAlignmentTools/bin/NetFilterNonNested.perl \
	-minScore 20000 -minSizeT 4000 -minSizeQ  4000 \
	$querydir/${refer}.${i}.net > $querydir/${refer}.${i}.net.filtered 
	$cmdir/GenomeAlignmentTools/bin/NetFilterNonNested.perl \
	-minScore 20000 -minSizeT 4000 -minSizeQ 4000 \
	$querydir/${query}.${i}.net > $querydir/${query}.${i}.net.filtered
}
((1)) && {
#------------net to axt
	$cmdir/kent/bin/linux.x86_64/netToAxt \
	$querydir/${refer}.${i}.net.filtered \
	$querydir/$query.${i}.axt.chain \
	$referdir/${refer}.${i}.2bit \
	genomes/${query}.2bit \
	$querydir/${refer}.${i}.net.filtered.axt 
#------------axt to maf
	$cmdir/kent/bin/linux.x86_64/axtToMaf \
	$querydir/${refer}.${i}.net.filtered.axt \
	${referdir}/${refer}.${i}.size \
	genomes/${query}.fa.size \
	$querydir/${refer%.fa}.${query}.${i}.net.filtered.axt.maf
}
done
