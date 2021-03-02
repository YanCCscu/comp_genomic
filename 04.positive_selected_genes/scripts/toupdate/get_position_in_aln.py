#!/usr/bin/env python3
""" Extract transition between branches """
"""
./get_position_in_aln.py ../cdsalign/OG0013099.cds.aligned.fa Tbai 461,462,463
spe	seqpos	shift	aapos	alipos
Tbai	39	39	13	461
Tbai	40	40	14	462
Tbai	41	41	14	463
"""
import sys,math
from Bio import SeqIO
if len(sys.argv)<4:
	print("\033[91m%s alignment.fa target_seqid pos_position(1,2,3...) [shift]<-default 0"%sys.argv[0])
	sys.exit(1)
# Load sequences
matrix = {}
# matrix_id = []

sequence_target = sys.argv[2]
seq_of_interest = sys.argv[3]
if len(sys.argv)>=5:
	shift = int(sys.argv[4])
else:
	shift = 0
aln_start = 0
aln_stop = 0

position_str_list = seq_of_interest.split(",")
position_list = [int(x)+shift for x in position_str_list]
print("%s\t%s\t%s\t%s\t%s"%('spe','seqpos','shift','aapos','alipos'))
max_length = 0
input_handle = open(sys.argv[1], 'r')
for record in SeqIO.parse(input_handle, 'fasta'):
    matrix[record.id] = str(record.seq)
    # matrix_id.append(record.id)
    if record.id == sequence_target:
        j = 0
        for i, aa in enumerate(str(record.seq)):
            if aa != "-":
                j = j+1
            if i in position_list:
                print("%s\t%s\t%s\t%d\t%d"%(record.id,j,j+shift,math.ceil((j+shift)/3), i))
