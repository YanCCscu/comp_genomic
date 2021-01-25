input files
workdir/inputs
├── hss16.tre   #tree in newick format
├── Ortheogroups_I3.csv #gene table from orthfinder
└── selected_species   #usuallly, species in tree file

output dirs
workdir
├── oneonecds #exctracted cds
├── cdsalign  #aligned cds
├── pamldir   #trimed aligned cds and codeml restult dirs

output files
├── aligned.sge.sh
├── aligned.sge.sh.27965.log
├── aligned.sge.sh.27965.qsub
├── gene_failed.log
├── genelist
├── pipe.sh
├── psg.sge.sh
├── psg.sge.sh.23925.log
├── psg.sge.sh.23925.qsub
├── SingleCopyGeneSets.Ortheogroups_I3.table
└── SingleCopyGeneSets.Ortheogroups_I3.table.rename

geneanno outputfiles
├── joined_lnL_ortho.table
├── lnLout.SigGeneList
├── lnLout.SigGeneList.anno
├── lnLout.SigGeneList.rename
