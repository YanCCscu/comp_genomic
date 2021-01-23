#reheader ncbi
#for f in `cat ncbi.list`;do sed -i 's/>.\+_prot_\([^ ]\+\) \[\([^ ]\+\)\].\+/>\1 \2/' ${f}.pep.fa;done
#for f in `cat ncbi.list`;do sed -i 's/>.\+_cds_\([^ ]\+\) \[\([^ ]\+\)\].\+/>\1 \2/' ${f}.cds.fa;done

#reheader ensembl
for f in `cat ensembl.list`; do sed -i 's/>\([^ ]\+\).\+gene:\([^ ]\+\).\+/>\2 \1/i' ${f}.pep.fa;done
for f in `cat ensembl.list`; do sed -i 's/>\([^ ]\+\).\+gene:\([^ ]\+\).\+/>\2 \1/i' ${f}.cds.fa;done
