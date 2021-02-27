#!/usr/bin/env python3
import sys,os,time
import subprocess
from ete3 import Tree
from Bio import SeqIO
g='\033[1;32m'
r='\033[1;91m'
b='\033[0m'
if len(sys.argv)<2:
	print("%sUSAGE: python %s in.fas"%(g,sys.argv[0],b))
	sys.exit("%s---------: Nothing Have Done :-------------%s"%(g,b))
#sys.argv[1]='10000.maf.GERP49.fa.anc.dnd'
#t = Tree("(A:1,(B:0.5,E:0.5):0.5);", format = 1 )
#-----------define useful functions
#get percentage of identity of two seqs 
def GetPerID(Seq,Seqanc):
	assert len(Seq)==len(Seqanc),\
	"seq and seq_anc not in same length, make sure they were aligned ...\n"
	total_len=0
	matchbp=0
	for a,b in zip(Seq,Seqanc):
		if a == b:
			if a == '-':
				continue
			else:
				matchbp+=1
		total_len+=1
	return (matchbp,total_len)
		
#parse tree return three relative dicts		
def ParseTree(treefile):
	mytree=open(treefile)
	while True:
			#skip empty lines
			treestr=mytree.readline()
			if treestr != "":
				break
	t=Tree(treestr,format=1)
	nodesAnc=[]
	leafRoot=[]
	ancnode=""
	ancnum2name={}
	for node in t.traverse("preorder"):
		if not node.is_root():
			node.name=node.name.split("_")[0]
			nodesAnc.append((node.name,node.get_ancestors()[0].name))
		else:
			ancnode=node.name
	for node in t.traverse("preorder"):
		if node.is_leaf():
			leafRoot.append((node.name,ancnode))
			

	for node in t.traverse("postorder"):
		if not node.is_leaf():
			ancnum=node.name
			node.name=node.get_children()[0].name.split("-")[0]+\
			"-"+node.get_children()[1].name.split("-")[0]
			ancnum2name[ancnum]=node.name
	return (leafRoot,nodesAnc,ancnum2name)

#standard run shell comamnd
def runcmd(command):
	try:
		current_time = time.strftime("%Y-%m-%d %H:%M:%S",\
		time.localtime(time.time()))
		print(g,current_time, "\n", command,b,"\n", sep="")
		subprocess.check_call(command, shell=True)
		print(g,"prank running Done!",b)
	except:
		sys.exit("%sError occured when running command:\n%s%s"% (r,command,b))
###################################################################################################
####---------main process------####################################################################
###################################################################################################
if __name__ == "__main__":
	myfas=sys.argv[1]
	SeqID=os.path.basename(sys.argv[1]).replace('.fas','').replace('.fa','')
	outdir=os.path.dirname(sys.argv[1])
#run prank 
	prank="/data/nfs/OriginTools/bin/prank"
##### run prank #####
	prankcommand="%s -d=%s -o=%s -showtree -showanc -keep -prunetree -quiet -seed=10"%(prank,myfas,myfas)
	#subprocess.check_call(prankcommand, shell=True)
	runcmd(prankcommand)
	myancfas=myfas+".anc.fas"
	myanctree=myfas+".anc.dnd"
#------------parse and store fasta seq
	fasdict={ rec.id.split("_")[0] : rec.seq for rec in SeqIO.parse(myancfas,'fasta') }
#------------parse tree and make dict for
# leaves : ancestor for peridglobal
# internode :ancestor for peridlocal
# internode : intername for peridlocal id
	(leafRoot,nodesAnc,ancnum2name)=ParseTree(myanctree)
	#print("node:ancnode--->:\n",leafRoot,"\n",nodesAnc,"\n",ancnum2name)
#------------write peridglobal
	print(g,"%s output leaves identity refer to its MRA ..."%SeqID,b)
	with open(outdir+"/"+SeqID+".peridglobal",'w') as PERIDGLO:
		global_ids=[];leaves_sps=[]
		for (m,n) in sorted(leafRoot, key=lambda x: x[0]):
			(match,alllen)=GetPerID(fasdict[m],fasdict[n])
			leaves_sps.append(m)
			if alllen>=30:
				percent_id=match/alllen
				global_ids.append(str(percent_id))
			else:
				global_ids.append("NA")
		print("species","\t","\t".join(leaves_sps),file=PERIDGLO)
		print(SeqID,"\t","\t".join(global_ids),file=PERIDGLO)
#-------------write peridlocal
	print(g,"%s output internode identity refer to its MRA ..."%SeqID,b)
	with open(outdir+"/"+SeqID+".peridlocal",'w') as PERIDLOC:
		print("branch\tid\tpid",file=PERIDLOC)
		for (k,p) in nodesAnc:
			(match,alllen)=GetPerID(fasdict[k],fasdict[p])
			if alllen>=30:
				if k in ancnum2name:
					print("%s\t%s\t%f"%(ancnum2name[k],SeqID,match/alllen),file=PERIDLOC) 
				else:
					print("%s\t%s\t%f"%(k,SeqID,match/alllen),file=PERIDLOC)
