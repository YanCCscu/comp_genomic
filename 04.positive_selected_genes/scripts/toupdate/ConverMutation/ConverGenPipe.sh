#!/bin/bash
#set -ex
infasta=$1
outfasta=$(basename ${infasta%.fa*}).sim.fas
speciestre=$2 #species.tre
outtre=$(basename ${speciestre%.tre*})
scripts_dir=/data/backup/yancc/GitRepo/comp_genomic/04.positive_selected_genes/scripts
echo -e "trim tree according to alignment seq id ..."
bioawk -c fastx '{n=split($name,a,"|");printf(">%s\n%s\n",a[1],$seq)}' $infasta > $outfasta
nw_prune -v $speciestre $(bioawk -c fastx '{printf("%s ",$name)}' $outfasta) > ${outtre}.nodes
sh $scripts_dir/apply_ancRate.sh -a $outfasta -t ${outtre}.nodes
python $scripts_dir/toupdate/ConverMutation/ParsePamlRst.py ${outfasta%.*}.rst

rm $outfasta ${outtre}.nodes



#nw_prune -v species.tre $(bioawk -c fastx '{printf("%s ",$name)}' $outfasta) | $scripts_dir/add_tree_node_label.py > ${speciestre}.nodes
#echo -e "running: perl  $scripts_dir/find_convergence.pl Tbai,Phum $outfasta ${speciestre}.nodes"
#perl  $scripts_dir/find_convergence.pl Tbai,Phum $outfasta ${speciestre}.nodes
