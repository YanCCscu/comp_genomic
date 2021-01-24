#!/usr/bin/env python3
import sys
if len(sys.argv)<2:
	print(sys.argv[0],"swissfile hsa_file [3] <inputfile")
	print("\tdefault geneid column is 3 in stdin")
	sys.exit(1)
swiss_file=sys.argv[1]
hsa_file=sys.argv[2]
if len(sys.argv)>3:
	colint=int(sys.argv[3])-1
else:
	colint=2
#name_file=sys.argv[2]
def choose_name(strname):
	if not '|' in strname:
		return(strname)
	else:
		return(strname.split('|')[1])

with open(swiss_file) as swiss_anno:
	#print('parse swiss info ...')
	title=swiss_anno.readline()
	swiss_dict={ gi.strip().split("\t")[0]:choose_name(gi.strip().split("\t")[1]) for gi in swiss_anno }
	swiss_keys=swiss_dict.keys()

with open(hsa_file) as hsa_anno:
	#print('parse hsa info ...')
	title=hsa_anno.readline()
	hsa_dict={ gi.strip().split("\t")[0]:gi.strip().split("\t")[1:] for gi in hsa_anno }
	hsa_keys=hsa_dict.keys()

for line in sys.stdin:
	llist=line.strip().split("\t")
	#gid=llist[0].split()[0].strip()
	#gabbr=llist[1]
	gid=llist[colint]
	if gid in swiss_keys:
		lline="%s\t%s"%(line.strip(),swiss_dict[gid])
	else:
		lline="%s\t%s"%(line.strip(),"-")
	if gid in hsa_keys:
		if len(hsa_dict[gid])==1:
			print("%s\t%s\t-"%(lline,hsa_dict[gid][0]))
		else:
			print("%s\t%s\t%s"%(lline,hsa_dict[gid][0],hsa_dict[gid][1]))
	else:
		print("%s\t%s\t%s"%(lline,"-","-"))
