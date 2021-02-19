#!/bin/bash
#set -ex
[[ $# -lt 1 ]] && echo -e "sh $0 OGID orderfile\n" && exit 1 
cmdir=$(cd $(dirname $0);pwd)
workdir=$PWD
OGID=$1
orderfile=$2
trimfasta=$workdir/pamldir/${OGID}.cds.aligned/${OGID}.cds.aligned.trimal.fasta
orderacc=$(for i in `cat $orderfile`; do [[ $(grep $i $trimfasta) ]] && printf "%s," $i;done)
orderacc=${orderacc%,}
echo $trimfasta $orderacc

echo -e "$cmdir/scripts/cds2pep_zy.pl \
-f $workdir/pamldir/${OGID}.cds.aligned/${OGID}.cds.aligned.trimal.fasta -c 1 -o - | \
alv -l -so $orderacc - |less -RS"

$cmdir/scripts/cds2pep_zy.pl \
-f $trimfasta -c 1 -o - | \
alv -l -so $orderacc - |less -RS
