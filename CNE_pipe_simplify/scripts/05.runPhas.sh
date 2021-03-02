#!/bin/bash
#set -ex
[[ $# -lt 2 ]] && {
echo -e "\e[1;32msh $0 path/to/splitmafdir phast_dir [refsp] [CNE.tre]"
echo -e "example: sh tools/05.runPhas.sh splitmaf phast_dir [refsp] [CNE.tre]\e[0m\n"
} && exit
mafdir=$1 #splitmaf
[[ $# -ge 2 ]] && phast_dir=$2 || phast_dir=phast_dir
[[ $# -ge 3 ]] && refsp=$3 || refsp=Tbai
[[ $# -ge 4 ]] && tree=$4 || tree=CNE.tre
[[ -d $phast_dir ]] || mkdir -p $phast_dir
cmdir=$(cd $(dirname $0);pwd)
phast_bin=$cmdir/phast-1.3/bin
curdir=$PWD
tree=$curdir/$tree
runphast(){
#-----------
file=$(basename $1)
$phast_bin/phyloFit \
--tree $tree \
--msa-format MAF \
--out-root $phast_dir/phyloFit.$file \
--subst-mod REV \
--EM \
--precision HIGH \
-l $phast_dir/${file}.phyloFit.log \
$1

#---------------------
$phast_bin/phastCons \
--expected-length 45 \
--target-coverage 0.3 \
--rho 0.3 \
--most-conserved $phast_dir/${file}.con.bed \
--log $phast_dir/${file}.phastCons.log \
$1 \
$phast_dir/phyloFit.${file}.mod \
> $phast_dir/${file}.score.wig
}
export -f runphast
export phast_bin
export tree
export phast_dir
((1))&&{
ls  $mafdir/*.maf.c| parallel -j 20 -I{} runphast {}
}
#revise content of output
#rm $phast_dir/*.cname.phas.bed
grep $refsp $mafdir/all*.maf|cut -d ' ' -f1-2|sort -u|sed 's/\:s /\t/'|sed -e "s/$mafdir\///" -e 's/.maf//' > maf_scaffold_idmapping.list
ls $phast_dir/*.con.bed |\
parallel -j 20  -I{} python $cmdir/IDMappingReplace.py -m maf_scaffold_idmapping.list -a {} -t 1 -o {}.cname.phas.bed
sed -i -e 's/all\([[:digit:]]\+\)\.maf/all\1\.maf\.phast/' $phast_dir/*.c.con.bed.cname.phas.bed

