args<-commandArgs(TRUE)
if (length(args)<2){cat("Rscripts 01.selected_species.R Orthogroups.csv selected_species [Tbai] [8-16]\n");q("no")}
Orthofile=args[1]
Selectedsp=args[2]
mustspecies="Tbai"
spnum='8-16'
if (length(args)>=3){mustspecies=args[3]}
if (length(args)>=4){spnum=args[4]}
spnum=strsplit(spnum,'-',fixed=TRUE)[[1]]
spmin=as.numeric(spnum[1]);spmax=as.numeric(spnum[2])
Orthoout=paste("SingleCopyGeneSets",sub("\\..*",'',basename(Orthofile)),"table",sep=".")
orth<-read.table(Orthofile,
	header=TRUE,stringsAsFactors=FALSE,sep='\t',row.names=1)
sps=read.table(Selectedsp,stringsAsFactors=FALSE,header=FALSE)
orth_sel<-orth[paste(sps$V1,'pep',sep='.')]
nodot<-apply(orth_sel,1,function(m) ! grepl(',',m) & grepl('.',m))
orth_sel_scg<-orth_sel[colSums(nodot)>=spmin & colSums(nodot)<=spmax,]
orth_sel_df<-t(apply(orth_sel_scg,1,function(n){n[grepl(',',n)]="";n}))
mustspecies_null=orth_sel_df[,paste(mustspecies,'pep',sep='.')]==""
orth_sel_df<-orth_sel_df[!mustspecies_null,]
write.table(orth_sel_df,file=Orthoout,sep="\t",quote=FALSE)

#remember to fill a tab at begining of the header line

