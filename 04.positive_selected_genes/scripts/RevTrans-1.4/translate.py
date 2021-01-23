#!/usr/bin/env python

import sys,mod_seqfiles,mod_translate

"""
$Id: translate.py,v 1.4 2005/06/09 09:58:54 raz Exp $

Syntax: translate [-n maxseqs] [--allinternal] [-mtx matrixfile] <infile>

Part of the revtrans server - hence the limit of sequences

Requires the mod_seqfiles and mod_translate modules
from the revtrans source.
"""

maxseqs = 0       # No limit
mtx     = None    # Use default translation matrix
firstIsStart = True
readThroughStop = False

if __name__ == "__main__":
	fn = ""
	argv  = sys.argv[1:]
	while len(argv) > 0:
		arg = argv[0]
		argv = argv[1:]
		
		if arg == "-n":
			maxseq = int(argv[0])
			argv = argv[1:]
			continue
			
		if arg == "--readthroughstop":
			readThroughStop = True
			continue

		if arg == "--allinternal":
			firstIsStart = False
			continue

		if arg == "-mtx":
			mtxfn = argv[0]
			argv = argv[1:]
			continue

		fn = arg
			
	mtx = mod_translate.parseMatrixFile(mtxfn)
	try:
		seqs = mod_seqfiles.readfileauto(fn)
	
		newseqs = {}
	
		if not maxseqs: maxseqs = len(seqs.keys())
		for key in seqs.keys()[0:maxseqs]:
			seq, note = seqs[key]
			newseqs[key] = mod_translate.translate(seq,mtx,firstIsStart,readThroughStop) , note
		
		mod_seqfiles.writestream(sys.stdout,newseqs,"fasta","P")
		
	except Exception, e:
		sys.stderr.write("Translation error: %s\n" % str(e))
		sys.exit(1)	
