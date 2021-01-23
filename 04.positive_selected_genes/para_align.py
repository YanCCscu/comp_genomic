#!/usr/bin/env python3
import sys,subprocess,time
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
def runcmd(command):
	try:
		current_time = time.strftime("%Y-%m-%d %H:%M:%S",
                                                time.localtime(time.time()))
		print(current_time, "\n", command, "\n", sep="")
		subprocess.check_call(command, shell=True)
	except:
		sys.exit("Error occured when running command:\n%s" % command)
fasdict={}
with open(Genelistfile) as Genelist:
	header=Genelist.readline()
	print("start reading fasta files ...")
	for mysp in header.strip().split():
		mysp=mysp.split('.')[0]
		path_to_mysp=cdsdir+"/"+mysp+".cds.fa"
		fasdict[mysp]=SeqIO.to_dict(SeqIO.parse(path_to_mysp,'fasta'))
	print("start get single cluster ...")
	for gl in Genelist:
		gll=gl.strip().split("\t")
		OG=gll[0]
		Tbai=gll[1]
		for gid in Tbai.strip().split(','):
			gid=gid.strip()
			genestore={}
			blast_command="blastn -query out_para/%s.cds.fa -db TbaiParadb/%s -outfmt 6 \
-evalue 1e-6 -num_threads 1 -max_target_seqs 1 -out %s.blastn.table"%\
				(OG,gid,gid)
			runcmd(blast_command)
			with open(gid+".blastn.table") as blastout:
				for geneinfo in blastout:
					geneitem=geneinfo.strip().split()
					spename=geneitem[0].split('|')[0]
					genename=geneitem[0].split('|')[1]
					bscore=geneitem[11]
					evalue=geneitem[10]
					complete=geneitem[2]
					if not spename in genestore:
						genestore[spename]={genename:[bscore,evalue,complete]}
					else:
						if [bscore,evalue,complete] > genestore[spename][list(genestore[spename].keys())[0]]:
							genestore[spename]={genename:[bscore,evalue,complete]} 
			print("starting writing %s into file ..."%gid)
			with open(gid+".split.cds.fa",'w') as splitfas:
				for spname in genestore:
					genename=list(genestore[spname].keys())[0]
					print(">%s|%s\n%s"%(spname,genename,fasdict[spname][genename].seq),file=splitfas)
#after that,try this:
#perl 02.Extract_and_Align.pl $PWD/paracds
