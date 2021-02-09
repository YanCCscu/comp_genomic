#!/bin/env python3
import sys
if len(sys.argv)<3:
	print("%s gfffile source<--ensembl|ncbi"%sys.argv[0])
	sys.exit(1)
#---------some useful function----------------#
def get_lens(starts,ends):
	sumlen=0
	assert len(starts) == len(ends), "starts and ends not equal, check them"
	for start,end in zip(starts,ends):
		sumlen+=abs(int(start)-int(end))+1
	return(sumlen)
def aid(gid):
	if sys.argv[2] == 'ensembl':
		return(gid.split(':')[1])
	if sys.argv[2] == 'ncbi':
		return(gid.split('-',1)[1])

#---------parse gff3file----------------#
gffdb={}
with open(sys.argv[1]) as gfile:
	geneid=''
	gline=gfile.readline()
	while True:
		if not gline:
			break
		if not len(gline.strip()) or gline.startswith('#'):
			gline=gfile.readline()
			continue
		glist=gline.strip().split('\t')
		feature=glist[2]
		fstart=glist[3]
		fend=glist[4]
		annolist=glist[8].split(';')
		annodict={annoitem.split("=")[0]:annoitem.split("=")[1] for annoitem in annolist}
		if not 'Parent' in annodict and 'ID' in annodict:
			geneid=annodict['ID']
			gffdb.setdefault(geneid,{})['feature']=feature
		elif 'ID' in annodict and 'Parent' in annodict:
				Parent=annodict['Parent']
				childid=annodict['ID']
				gffdb[geneid].setdefault(feature,{}).setdefault(childid,{})['Parent']=Parent
				gffdb[geneid][feature][childid].setdefault('starts',[]).append(fstart)
				gffdb[geneid][feature][childid].setdefault('ends',[]).append(fend)
				if 'biotype' in annodict or 'gene_biotype' in annodict:
					gffdb[geneid][feature][childid]['biotype']=annodict['biotype']
		elif not 'ID' in annodict and 'Parent' in annodict:
			Parent=annodict['Parent']
			gffdb[geneid].setdefault(feature,{})['Parent']=Parent
		else:
			pass
		gline=gfile.readline()
print("#Gene_id\tTranscript_id\tProteinid\tCDS_len")
for k,v in gffdb.items():
	if 'mRNA' in v:
		tid_len=[]
		max_len=0
		select_tid=''
		select_pid=''
		for tid in v['mRNA']:
			if not 'biotype' in v['mRNA'][tid] or v['mRNA'][tid]['biotype']=='protein_coding':
				for cds in v['CDS']:
					if v['CDS'][cds]['Parent'] == tid:
						mrnalen=get_lens(v['CDS'][cds]['starts'],v['CDS'][cds]['ends'])
						tid_len.append((tid,cds,mrnalen))
				(select_tid,select_pid,max_len)=sorted(tid_len,key=lambda k:k[2],reverse=True)[0]
		if max_len == 0:
			continue
		print("%s\t%s\t%s\t%d"%(aid(k),aid(select_tid),aid(select_pid),max_len))
		#print("%s\t%s\t%s\t%d"%(k,select_tid,select_pid,max_len))
