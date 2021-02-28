#!/usr/bin/env python3
import sys
from ete3 import Tree
if len(sys.argv)<2:
	print("python %s in.tree"%sys.argv[0])
#sys.argv[1]='10000.maf.GERP49.fa.anc.dnd'
#t = Tree("(A:1,(B:0.5,E:0.5):0.5);", format = 1 )
mytree=open(sys.argv[1])
while True:
	#skip empty lines
	treestr=mytree.readline()
	if treestr != "":
		break
t=Tree(treestr,format=1)

t=Tree(treestr,format=1)
for node in t.traverse("preorder"):
    if node.is_leaf():
        node.name=node.name.split("_")[0]
        print("C",node.name,node.get_ancestors()[0].name)
        
for node in t.traverse("preorder"):
    if not node.is_leaf() and not node.is_root():
        print("P",node.name.split("_")[0],node.get_ancestors()[0].name)
        
for node in t.traverse("postorder"):
    # Do some analysis on node
    node_namelist=[]
    if not node.is_leaf():
        print("T",node.name,end=" ")
        node.name=node.get_children()[0].name.split("-")[0]+\
        "-"+node.get_children()[1].name.split("-")[0]
        print(node.name)
