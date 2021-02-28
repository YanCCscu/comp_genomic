#!/bin/bash
[[ $# -lt 1 ]] && echo -e "\e[91msh $0 querysp.2bit\e[0m\n" && exit 1;
cmdir=$(cd $(dirname $0);pwd)
toolsdir=$cmdir
lastz_D=$cmdir/lastz-distrib-1.03.54/bin/lastz_D
querysp=$1 #query species
queryspdir=$(basename ${querysp%.2bit})
[[ -d $queryspdir ]] || mkdir $queryspdir 

ls Tbai.fa.cut/Tbai.fa.*.2bit|parallel -j 20 -I{} \
$lastz_D \
{}[multiple] \
${querysp} \
--chain --gapped --seed=12of19 --notransition K=2400 L=3000 Y=3000 H=2000 \
Q=${toolsdir}/HoxD55.q --format=axt \
">" $queryspdir/${queryspdir}.{/.}.axt


#ls Tbai.fa.cut/Tbai.fa.*.2bit|parallel -j 20 -I{} $lastz_D {}[multiple] genomes/$querysp --chain --gapped --seed=12of19 --notransition K=2400 L=3000 Y=3000 H=2000 Q=${toolsdir}/HoxD55.q --format=axt ">" $queryspdir/${querysp}.{/.}.axt
