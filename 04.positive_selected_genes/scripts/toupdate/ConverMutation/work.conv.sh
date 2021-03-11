#perl /data/tools/phylogeny_evolution/find_convergence.pl Oapo,Tbai,Nnaj,Cvir /data/nfs/pcj/lizard_conver/pep /data/nfs/pcj/lizard_conver/tree.paml.treefile fa
infasta=$1
outfasta=$(basename ${infasta%.fa*}).sim.fas
speciestre=species4d.tre
scripts_dir=/data/backup/yancc/GitRepo/comp_genomic/04.positive_selected_genes/scripts/toupdate/ConverMutation
echo -e "trim tree according to alignment seq id ..."
bioawk -c fastx '{n=split($name,a,"|");printf(">%s\n%s\n",a[1],$seq)}' $infasta > $outfasta
nw_prune -v species.tre $(bioawk -c fastx '{printf("%s ",$name)}' $outfasta) | $scripts_dir/add_tree_node_label.py > ${speciestre}.nodes
echo -e "running: perl  $scripts_dir/find_convergence.pl Tbai,Phum $outfasta ${speciestre}.nodes"
perl  $scripts_dir/find_convergence.pl Tbai,Phum $outfasta ${speciestre}.nodes
