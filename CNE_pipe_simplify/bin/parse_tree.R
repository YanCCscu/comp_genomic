argv<-commandArgs(TRUE);
library(phytools);
tree1<-read.newick(file=argv[1]);
parents_nodes_lab<-tree1$node.label;
child_nodes_lab<-tree1$tip.label;
edge<-tree1$edge;
file_parents<-paste(argv[1],".pnodes",sep="");
file_child<-paste(argv[1],".cnodes",sep="");
file_edge<-paste(argv[1],".edge",sep="");
write.table(parents_nodes_lab,file=file_parents,sep='\t',quote = F,row.names = F,col.names = F);
write.table(child_nodes_lab,file=file_child,sep='\t',quote = F,row.names = F,col.names = F);
write.table(edge,file=file_edge,sep='\t',quote = F,row.names = F,col.names = F);

