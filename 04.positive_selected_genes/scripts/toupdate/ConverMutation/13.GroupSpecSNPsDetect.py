#!/usr/bin/env python3
from __future__ import print_function
from Bio import AlignIO
import sys
import argparse
#UASAG: python GroupSpecSNPsDetect.py -a 1587.pep.fas -c sp_group.trait -g 6 -o snake_spe_snp.stat
parser = argparse.ArgumentParser()
parser.add_argument("-a", "--alignment", help="alignmemt file to check", action = "store")
parser.add_argument("-c", "--classified", help="classified info of samples, classed by OUT or IN", action = "store")
parser.add_argument("-o", "--outfile", help="output file site info", action = "store")
parser.add_argument("-g", "--gaps", help="gaps allowed in 'OUT' samples", type=int, action = "store",default=1)
args = parser.parse_args()

alignment = AlignIO.read(args.alignment, "fasta")
#print ("Number of rows: %i and cols: %i" % (len(alignment),alignment.get_alignment_length()))
sp_order=[record.id.split('|')[0] for record in alignment]
#for i,sp in enumerate(sp_order):
#	print("%d:%s"%(i+1,sp))
sp_dict={sp:i for i,sp in enumerate(sp_order)}
#tell whethe the position is species spcific
def sp_specific(seqcol,sp_dict,splist,outlist,gapmax=1):
	if seqcol.count('-')>gapmax:
		return False
	aimAA=[seqcol[sp_dict[ai]] for ai in splist]
	if not len(set(aimAA)) == 1:
		return False
	outAA=[seqcol[sp_dict[oi]] for oi in outlist]
	#leftAA=seqcol.replace(aimAA[0],'')
	if aimAA[0] in outAA:
		return False
	else:
		return True
statfile=open(args.outfile,'w')
splist=[]
outlist=[]
with open(args.classified) as groupinfo:
	for sp in groupinfo:
		spl=sp.strip().split("\t")
		if len(spl)>=2:
			if spl[1]=='IN':
				splist.append(spl[0].split('|')[0])
			if spl[1]=='OUT':
				outlist.append(spl[0].split('|')[0])
#print("#%s|%s"%(sp,sys.argv[1]))
storlist=[]
storlist.append([ind.split('_')[0]+":\t" for ind in sp_order])
print("\t",end="")
for i in range(alignment.get_alignment_length()):
	seqcol=alignment[:,i]
	#seqcol=[seqcol[sp_dict[ai]] for ai in allist]
	if sp_specific(seqcol,sp_dict,splist,outlist,gapmax=args.gaps):
		print(args.alignment,end=":\t",file=statfile)
		print(i+1,seqcol,file=statfile)
		print(i+1,end='|')
		storlist.append([letter for letter in seqcol])
		storlist.append([letter for letter in alignment[:,i+1]])
		storlist.append([letter for letter in alignment[:,i+2]])
print("")
posinum=len(storlist)
spnum=len(seqcol)
for sp in range(spnum):
	for posi in range(posinum):
		print(storlist[posi][sp],end="")
	print("")

