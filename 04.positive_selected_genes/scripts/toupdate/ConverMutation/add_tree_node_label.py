#!/usr/bin/env python3
from ete3 import Tree
import sys
if len(sys.argv)>1:
	#print("python %s in.tree"%sys.argv[0])
	mytree=open(sys.argv[1])
else:
	mytree=sys.stdin
#t = Tree("(A:1,(B:0.5,E:0.5):0.5);", format = 1 )
while True:
	if len(sys.argv)>1:
	#skip empty lines
		treestr=mytree.readline()
		if treestr != "":
			break
	else:
		treestr=mytree.readline()
		break

t=Tree(treestr,format=1)
#print(t)
allleaves=[]
for node in t.traverse("preorder"):
	# Do some analysis on node
	node_namelist=[]
	if not node.is_leaf():
		for subnode in node.traverse("preorder"):
			if subnode.is_leaf():
				node_namelist.append(subnode.name.split("_")[0])
		node.name="_".join(node_namelist)
	else:
		node.name=node.name.split("_")[0]
		allleaves.append(node.name)
t.name="_".join(allleaves)
print(t.write(format=1).rstrip(";"),end="")
print(t.name+";")
"""
#print(t)
for node in t.traverse("postorder"):
	if not node.is_leaf():
		node.name=node.get_children()[0].name.split("-")[0]+\
		"-"+node.get_children()[1].name.split("-")[0]
	else:
		node.name=node.name.split("_")[0]
print(t.write(format=1))
"""
