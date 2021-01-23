#### author pcj 2020.4.20 finished.
This pipline uses orthofinder to identify gene families and contanate single copy genes for 02.phylogeny.
It can also produce gene tables for 05.genefamily_expansion and Paml_PiPe_get_positivegenes

Only thing you should do is to run ./bin/run_orthofinder.pl like:
	perl ./bin/run_orthofinder.pl -p /data/tools/BGI_tools/BGI_pipelie_update/01.gene_families/input/pep -c /data/tools/BGI_tools/BGI_pipelie_update/01.gene_families/input/cds --cpu1 10 --cpu2 100 --cpu3 57
More detials can be found by run:
	perl ./bin/run_orthofinder.pl -h
Example can be found in output dir: work.sh.
notes: 1.the pep files and cds files should start with species id like Ohan.* Ptex.* et al. 
       2.The seq in pep and cds files should have same seq names. 
       3.The names can not include "|".
