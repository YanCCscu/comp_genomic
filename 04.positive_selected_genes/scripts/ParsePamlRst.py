#!/usr/bin/env python3
import sys,re
from ete3 import Tree
rstfile=sys.argv[1]
SeqDict={}
treestr=""
with open(rstfile) as RST:
	rstline=RST.readline()
	while True:
		if not rstline:
			break
		if re.search(r"tree with node labels for Rod Page\'s TreeView",rstline):
			rstline=RST.readline()
			while True:
				if not rstline:
					break
				if rstline == "\n":
					break
				treestr+=rstline
				rstline=RST.readline()
		if re.search(r"reconstructed sequences",rstline):
			RST.readline();RST.readline();RST.readline() #skip 3 unused rows
			rstline=RST.readline()
			while True:
				if not rstline:
					break
				if rstline == "\n":
					break
				rstlist=rstline.strip().split()
				if rstlist[0]=="node":
					rstlist=rstlist[1:]
					rstlist[0]=rstlist[0].replace("#","")
				#SeqDict[rstlist[0]]="".join(rstlist[1:])
				SeqDict.setdefault(rstlist[0],"")
				SeqDict[rstlist[0]]+="".join(rstlist[1:])
				rstline=RST.readline()
		rstline=RST.readline()

print(treestr)
allLen=[len(mseq) for mid,mseq in SeqDict.items()]
assert len(set(allLen))==1 , "not all seq are in equal length, please cheack!!!" 
t=Tree(treestr,format=1)
Node_nearAnc=[]
for node in t.traverse("preorder"):
	if node.is_leaf():
		if node.name.strip().split('_')[1] in ['Tbai','Phum']:
			Node_nearAnc.append((node.name.strip().split('_')[1],node.get_ancestors()[0].name))
print("cal conv ...")
COVOUT=open('conver_genelist.table','a')
for i in range(allLen[0]):
	childAA=[]
	parentAA=[]
	for targetsp in Node_nearAnc:
		childAA.append(SeqDict[targetsp[0]][i])
		parentAA.append(SeqDict[targetsp[1]][i])
	if len(set(childAA))>1:
		next
	elif childAA[0] in parentAA:
		#print(i,childAA,parentAA,"\n")
		next
	elif len(set(parentAA))==1:
		print("%s\tparallel\t%d %s->%s"%(rstfile,i,parentAA[0],childAA[0]),file=COVOUT)
	else:
		print("%s\tconverge\t%d %s->%s"%(rstfile,i,set(parentAA),childAA[0]),file=COVOUT)

