#!/bin/env python3
import sys,re,os
toolsdir=os.path.dirname(os.path.abspath(sys.argv[0]))
chiq=toolsdir+'/chi2'
if len(sys.argv)<3:
	print("USAGE: %s null.mlc alte.mlc"%sys.argv[0])
	sys.exit(1)
def get_mlc_info(mlc):
	candsites=[]
	line=mlc.readline()
	while True:
		if not line:
			break
		if line.startswith('lnL'):
			mlnl=re.search(r'lnL\(ntime:\s+\d+\s+np:\s+(\d+)\):\s+(\S+)\s+\S+', line)
			np=mlnl.groups()[0]
			lnl=mlnl.groups()[1]
		if line.startswith('Bayes Empirical Bayes (BEB) analysis'):
			line=mlc.readline()
			while True:
				if not line:
					break
				if line.startswith('The grid (see ternary graph for p0-p1)'):
					line=mlc.readline()
					break
				m=re.search(r'\s+(\d+) (\w) (\S+)',line)
				if m:
					candsites.append("/".join(m.groups()))
				line=mlc.readline()
		line=mlc.readline()
	return(np,lnl,candsites)

def get_name_comm(mlc_nul,mlc_alt):
	mlc_nul=os.path.basename(mlc_nul)
	mlc_alt=os.path.basename(mlc_alt)
	cutpoint=0
	for i,j in enumerate(zip(mlc_nul,mlc_alt)):
		if not j[0] == j[1]:
			return(mlc_nul[0:i-1])
mlc_nul=sys.argv[1]
mlc_alt=sys.argv[2]

with open(mlc_nul,'r') as mlcnul:
	lnlnul=get_mlc_info(mlcnul)
with open(mlc_alt,'r') as mlcalt:
	lnlalt=get_mlc_info(mlcalt)

GeneID=get_name_comm(mlc_nul,mlc_alt)
df=int(lnlalt[0])-int(lnlnul[0])
LRT=2*(float(lnlalt[1])-float(lnlnul[1]))
#print("%s\t%s\t%s\t%s\t%s"%(GeneID,lnlnul[1],lnlalt[1],df,":".join(lnlalt[2])))
if LRT > 0:
	plist=os.popen('%s %s %s'%(chiq,df,LRT)).readlines()
	print(plist[1],file=sys.stderr)
	p=re.search(r'prob = \S+ = (\S+)',plist[1]).groups()[0]
else:
	p=1
#print("geneid\tlnL.nul\tlnL.alt\tdf\tp\tsites")
print("%s\t%s\t%s\t%s\t%s\t%s"%(GeneID,lnlnul[1],lnlalt[1],df,p,":".join(lnlalt[2])))
