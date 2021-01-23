#!/usr/local/python/bin/python

#    Copyright 2002,2003 Rasmus Wernersson, Technical University of Denmark
#
#    This file is part of RevTrans.
#
#    RevTrans is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    RevTrans is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with RevTrans; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# $Id: mod_seqfiles.py,v 1.6 2005/06/09 09:58:54 raz Exp $
#
# $Log: mod_seqfiles.py,v $
# Revision 1.6  2005/06/09 09:58:54  raz
# Handles the simutation where multiple DNA sequences gives rise to the same
# peptide sequence.
#
# Revision 1.5  2004/12/06 09:32:57  raz
# Spaces is now automatically removed from FASTA sequences.
#
# Revision 1.4  2004/07/20 09:44:19  raz
# Minor changes for better error repporting
#
# Revision 1.3  2004/06/30 09:35:01  raz
# CVS now in sync with RevTrans 1.2
#
# Revision 1.2  2003/04/04 20:24:16  raz
# All revtrans files now released under the GPL
#
# Revision 1.1  2003/04/04 20:03:17  raz
# Translation has been moved into it's own module, and improved quite a lot. Supports
# full IUPAC.
#
# Handling of files hae also been moved into it's own module. When reading FASTA files
# the entire line after ">" counts as the name. Comments might just as well be phased
# out.
#
# Revtrans now makes sure no illegal characters exist in the read files. This also fixes
# problems with sequences with white-spaces.


# 25/3-2004: Fixed a problem where unexpected whitespace/newlines in FASTA files caused problems

"""
RevTrans - Module for handling sequence files
"""

import sys,string

def addEntry(name,seq,note,dict):
	uniqename = name
	c = 1
	while dict.has_key(uniqename):
		uniqename = "%s_%i" % (name,c)
		c += 1
	dict[uniqename] = (seq,note)

def readfasta(stream):
	result = {}
	name, seq, note = "",[],""
	
	for line in stream.readlines():
		#line.strip()            # Remove whitespace at ends - including newline
		if line.startswith(">"):
			if name: 
				addEntry(name,"".join(seq),note,result)
			name = line[1:].strip()         # skip leading ">"
			note = ""
			seq = []
		else:
			seqline = line.strip().replace(" ","")
			seq.append(seqline)
	if name: 
		addEntry(name,"".join(seq),note,result)
	
	return result

def writefasta(stream,seqs,charsperline):
	for key in seqs.keys():
		seq,note = seqs[key]
		stream.write(">"+key+" "+note+"\n")
		
		while len(seq) > 0:
			stream.write(seq[0:charsperline]+"\n")
			seq = seq [charsperline:]

def generic_writefasta(stream,seqs):
	#print "writefasta:",seqs
	writefasta(stream,seqs,50)

def readmsf(stream):
	#print "readmsf"
	result = {}
	name, seq, note = "","",""
	header = 1
	
	for line in stream.readlines():
		s = line.strip()
		tokens = s.split()
		
		if header:
			if s == "//": 
				header = 0
				validnames = result.keys()
				continue
			if tokens and (tokens[0].lower()) == "name:":
				result[tokens[1]] = ""
		elif tokens:
			if tokens[0] in validnames:
				key = tokens[0]
				seq = string.join(tokens[1:],"")
				result[key] += seq
			 
	for key in validnames:
		seq = result[key]
		result[key] = (seq,"")
		
	return result

def chop(s,interval):
	result = ""
	for i in range(0,(len(s)/interval) +1):
		result += s[i*interval:(i+1)*interval]+" "
	return result.strip()

def writemsf(stream,seqs,filetype):
	cpl = 50 			#Chars per line

	key = seqs.keys()[0]
	seq,note = seqs[key]
	stream.write("PileUp\n\n")
	stream.write("MSF: "+str(len(seq))+"\tType: "+filetype+"\tCheck: 0\t..\n\n")
	
	for key in seqs.keys():
		seq,note = seqs[key]
		stream.write("Name: "+key+"\tLen: "+str(len(seq))+"\n")
	stream.write("\n\n//\n\n")
	
	glob_len = len(seq)
	
	i = 0
	while i < glob_len:
		for key in seqs.keys():
			#print seqs[key]
			seq,note = seqs[key]
			seq = seq[i:i+cpl]
			stream.write(key.ljust(16)+chop(seq,10)+"\n")
		
		i +=cpl
		stream.write("\n")
		
def generic_writemsf(stream,seqs):
	writemsf(stream,seqs,"N")

def readaln(stream):
	result = {}
	firstline = 1
	for line in stream.readlines():
		if firstline:
			if not (line[:7]).lower() == "clustal": 
				raise ValueError, "Not an ALN file"
			firstline = 0
			continue
			
		if line[0:1] == " ": continue
		
		tokens = line.split()
		
		if not tokens: continue
		
		name = tokens[0]
		seq = tokens[1]
		#seq = string.join(tokens[1:],"")
		
		if name in result.keys():
			result[name] += seq
		else:
			result[name] = seq

	for key in result.keys():
		seq = result[key]
		result[key] = (seq,"")
	
	return result
	
def writealn(stream,seqs):
	stream.write("CLUSTAL X (1.64b) multiple sequence alignment - created by revtrans\n\n")
	
	cpl = 60 	# Chars per line
	
	glob_len = 0
	for key in seqs.keys():
		seq,note = seqs[key]
		glob_len = len(seq)
		
	i = 0
	while i < glob_len:
		for key in seqs.keys():
			#print seqs[key]
			seq,note = seqs[key]
			seq = seq[i:i+cpl]
			stream.write(key.ljust(16)[:16]+seq+"\n")
		
		i +=cpl
		stream.write("\n\n")
			

	
readers = {"fasta":readfasta,"msf":readmsf,"aln":readaln}
#writers = {"fasta":generic_writefasta,"msf":generic_writemsf}

def autotype(filename):
	f = open(filename,"r")
	line = f.readline()
	f.close()
	
	line = line.lower()
	
	if   line.find("clustal") == 0:        return "aln"
	elif line.find("pileup") == 0:         return "msf"
	elif line[0] == ">":                   return "fasta"
	
	return "unknown"

def readfileauto(filename):
	filetype = autotype(filename)
	return readfile(filename,filetype)

def readfile(filename, filetype):
	if not filetype in readers.keys(): 
		raise ValueError, "No suitable reader for file type: "+filetype 
	
	reader = readers[filetype]
	stream = open(filename,"r")
	result = reader(stream)
	stream.close()
	return result

def writestream(stream,seqs,filetype,seqtype):
	if   filetype == "msf"  : writemsf(stream,seqs,seqtype)
	elif filetype == "aln"  : writealn(stream,seqs)
	else :	                  writefasta(stream,seqs,50)

if __name__ == "__main__":
	seqs = readfileauto(sys.argv[1])
	print "#seqs:"+str(len(seqs))
