#perl /data/tools/phylogeny_evolution/find_convergence.pl Oapo,Tbai,Nnaj,Cvir /data/nfs/pcj/lizard_conver/pep /data/nfs/pcj/lizard_conver/tree.paml.treefile fa
infasta=$1
speciestre=species.tre
scripts_dir=/data/backup/yancc/GitRepo/comp_genomic/04.positive_selected_genes/scripts/toupdate/ConverMutation
nw_prune -v species.tre $(bioawk -c fastx '{printf("%s ",$name)}' $infasta) | $scripts_dir/add_tree_node_label.py > ${speciestre}.nodes
echo -e "perl  $scripts_dir/find_convergence.pl Tbai,Phum $infasta $speciestre"
perl  $scripts_dir/find_convergence.pl Tbai,Phum $infasta $speciestre
