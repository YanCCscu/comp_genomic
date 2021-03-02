#!/bin/bash
[[ $# -lt 1 ]] && {
echo -e "\e[1;91msh $0 tree mafdir refsp splnum\e[0m\n" 
echo -e "example: sh tools/03.MergeMAF.sh CNE.tre AllMAF Tbai 20\n"
} && exit 1
treefile=$1
AllMAF=$2
refsp=$3
splnum=$4
#nw_prune -v -f /data/backup/yancc/data/psgconv/species.tre spelist >CNE.tre
treenodes=($(nw_labels -I $treefile|grep -v $refsp)) #get labels and remove refsp
#echo ${treenodes[@]} ${#treenodes[@]}
AllMAF=$(cd $AllMAF;pwd)
cmdir=$(cd $(dirname $0);pwd)
multiz=$cmdir/multiz/bin/multiz
[[ -d MAFMerge ]] || mkdir -p MAFMerge
printf "\e[1;34mThe MAF-merge scripts is writting into dir: MAFMerge ...\e[0m\n"
for i in $(seq 1 $splnum)
do
	stepnodes=$refsp
	for j in $(seq 0 $((${#treenodes[@]}-2)))
	do
		stepnodes=$stepnodes.${treenodes[$j]}
		printf "#---------------run chuncks %d step %d\n" $i $[$j+1]
		printf "echo -e \"\\\\e[1;91mstep %d: produce %s\\\\e[0m\"\n" $[$j+1] ${stepnodes}.${treenodes[$j+1]} 
		printf "%s %s/%s.%d.net.filtered.axt.maf %s/%s.%s.%d.net.filtered.axt.maf 1 > %s/%s.%d.net.filtered.axt.maf\n" \
		$multiz $AllMAF $stepnodes $i \
		$AllMAF $refsp ${treenodes[$j+1]} $i \
		$AllMAF ${stepnodes}.${treenodes[$j+1]} $i
	done >MAFMerge/MAFMergeChrunk_${i}.sh
done
echo -e "now you can submit jobs with:"
echo -e "ls MAFMerge/MAFMergeChrunk_*.sh|xargs -I{} qsub -l vf=8G,p=1 -N mergemaf {}"
echo -e "Good Luck!!"
