#!/bin/bash
set -e
[[ $# -lt 2 ]] && echo -e "sh $0 path/to/splitmafdir gerpcommand [refsp] [cnetree]" && exit
#EXAMPLE: sh tools/05.runGERP.sh splitmaf gerp_commands >batch.GERP.sh
mafdir=$1 #splitmaf
gerp_command=$2
[[ $# -ge 3 ]] && ref_species=$3 || ref_species=Tbai
[[ $# -ge 3 ]] && tree=$4 || tree=CNE.tre
curdir=$PWD
tree=$curdir/$tree
cmdir=$(cd $(dirname $0);pwd)
[[ -d $gerp_command ]] &&  rm -rf $gerp_command
[[ -d $gerp_command ]] || mkdir -p $gerp_command
phast_bin=$cmdir/tools/phast-1.3/bin
#--------split maf into blocks
((0)) && {
[[ -d MAFBLOCKS ]] || mkdir -p MAFBLOCKS
#ls $mafdir/*.maf|parallel -j 20 -I{} awk -f tools/awk_split_maf.awk {} MAFBLOCKS
for f in $mafdir/*.maf;do echo awk -v total_line=$(wc -l $f|cut -d" " -f1) -f tools/awk_split_maf.awk $f MAFBLOCKS;done|parallel -j 20
}
#echo -e "submmit jobs with the following scripts:"
for maf in $mafdir/*.maf
do
	maf=$(basename $maf)
	for mafblock in MAFBLOCKS/${maf}.block*.maf
	do
		blockid=$(basename ${mafblock%.maf*.maf})
		blockid=${blockid#all}
		block_scaf=$(awk '{sp="'$ref_species'";if(a=index($2,sp)){print $2}}' $mafblock)
		block_start=$(awk '{sp="'$ref_species'";if(a=index($2,sp)){print $3}}' $mafblock)
		sed 's/_\S\+//' $mafblock >${mafblock}.c
		cat <<EOF >>$gerp_command/runGERP_${maf}.sh
echo -e "\e[91mrun GERP for block $mafblock ...\e[0m"
$cmdir/gerpcol -t $tree -f $curdir/${mafblock}.c -x .GERP.rates -e $ref_species
$cmdir/gerpelem -c $block_scaf -s $block_start -w .ex -f $curdir/${mafblock}.c.GERP.rates -d 0.01
awk -v id=$blockid -v OFS="\t" '{\$7=id".maf.GERP";printf("%s\t%s\t%s\t%s\t0\t+\n",\$1,\$2,\$3,\$7)}' $curdir/${mafblock}.c.gerp.rates.elems > $curdir/${mafblock}.c.gerp.rates.elems.f 
EOF
	done
done
cat $gerp_command/runGERP_*.sh >batch_runGERP.sh
echo -e "nohup qsub-sge.pl -l 4 -res vf=16G,p=1 -c no -m 100 -j mafgerp batch_runGERP.sh &"

##################################################
