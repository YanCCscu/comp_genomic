#!/usr/bin/env python3
from __future__ import print_function
import sys,re
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-m", "--mapfile", help="id_mapping file", action = "store")
parser.add_argument("-a", "--aimfile", help="aim file to modified", action = "store")
parser.add_argument("-o", "--outfile", help="prefix of output file",action = "store",default = sys.stdout)
parser.add_argument("-t", "--times", help="replace times in each items",type=int, action = "store",default=1)
parser.add_argument("-r", "--reverse", help="reverse changes derection diy>scaffold(default):diy<scaffold",\
			action = "store_true", default = False)
args = parser.parse_args()
if args.outfile != sys.stdout:
	outfile=open(args.outfile,'w') 
else:
	outfile=sys.stdout
#restring=sys.argv[3]
oristring='all\d+'
scastring='Tbai_Scaffold\d+'
if args.reverse:
	header=re.compile(r"%s"%scastring.strip())
else:
	header=re.compile(r"%s"%oristring.strip())

with open(args.mapfile,'r') as mapfile:
	if args.reverse:
		mapping_dict={l.split()[1]:l.split()[0] for l in mapfile}
	else:
		mapping_dict={l.split()[0]:l.split()[1] for l in mapfile}

with open(args.aimfile,'r') as file_for_replace:
	for line in file_for_replace:
		replacetime=0
		for name in header.finditer(line):
			line=line.replace(name.group(),mapping_dict[name.group()],args.times) 
			break
		print(line,end="",file=outfile)

outfile.close()
