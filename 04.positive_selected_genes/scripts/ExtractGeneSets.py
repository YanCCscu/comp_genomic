#!/usr/bin/env python3
import os,sys
from Bio import SeqIO
if len(sys.argv)<3:
	print("python3 %s GeneListFile cdsdir"%sys.argv[0])
	descripts="Example:\n\
	Genelistfile=\"TbaiParaGene.list\" #the list should contain header\n\
	cdsdir=\"/data/share/yancc/GenoComp/00.data_prepare/input/cds\"\n\
	"
	print(descripts)
	sys.exit(1)
Genelistfile=sys.argv[1]
cdsdir=sys.argv[2]
fasdict={}
#output dir
if os.path.exists("oneonecds"):
	while True:
		ask=input("The oneonecds already exists,overwirte it [Yy/Nn]:")
		if ask.strip() in 'Nn':
			sys.exit(1)
		elif ask.strip() in 'Yy':
			os.rmdir('oneonecds')
			break
		else:
			pass
else:
	os.makedirs('oneonecds')
	
with open(Genelistfile) as Genelist:
	header=Genelist.readline().lstrip().rstrip("\n").replace(".pep","").split("\t")
	print("start reading fasta files ...")
	for mysp in header:
		mysp=mysp.split('.')[0]
		path_to_mysp=cdsdir+"/"+mysp+".cds.fa"
		fasdict[mysp]=SeqIO.to_dict(SeqIO.parse(path_to_mysp,'fasta'))
	print("start get single cluster ...")
	for gl in Genelist:
		gll=gl.strip("\n").split("\t")
		OG=gll[0]
		print("starting writing gene cluster %s into file ..."%OG)
		with open("oneonecds/"+OG+".cds.fa",'w') as splitfas:
			assert len(header) == len(gll[1:]), "length of header and geneid not equal" 
			for spname,geneid in zip(header,gll[1:]):
				if not geneid == "":
					print(">%s|%s\n%s"%(spname,geneid,fasdict[spname][geneid].seq),file=splitfas)
