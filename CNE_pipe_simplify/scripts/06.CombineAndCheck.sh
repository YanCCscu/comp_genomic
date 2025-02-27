#!/bin/bash
[[ $# -lt 2 ]] && echo -e "\e[1;91msh $0 splitfam gfffile [gerp_dir] [phast_dir] \n\e[0m" && exit 1
splitmaf=$1
cds_gff=$2 #Tbai.gff
[[ $# -ge 3 ]] && gerp_dir=$3 || gerp_dir=gerp_dir
[[ $# -ge 4 ]] && gerp_dir=$4 || phast_dir=phast_dir
cmdir=$(cd $(dirname $0);pwd)
bed_tools_bin=$cmdir/bedtools2/bin
echo -e "filter gff to keep only cds ..."
awk '$3=="CDS"' $cds_gff >${cds_gff%.gff}.cds.gff
[[ -d CNE ]] || mkdir -p CNE
((1)) && {
for maf in $splitmaf/*.maf
do 
	maf=$(basename $maf)
	((1)) && {
	#reshape GERP results
	cat MAFBLOCKS/$maf*.block*.GERP.rates.elems.f|awk -v OFS='\t' 'BEGIN{i=1}{i++;gsub("maf.GERP","maf.GERP"i,$4);print $0}' > $gerp_dir/${maf}.c.con.bed.cname.gerp.bed
	#merge GERP and PHAST results
	cat $phast_dir/${maf}.c.con.bed.cname.phas.bed $gerp_dir/${maf}.c.con.bed.cname.gerp.bed > CNE/${maf}.c.con.bed.cname.bed.phas-gerp.bed
	#sort by Chrom and Start Pos
	sort -k1,1 -k2,2n CNE/${maf}.c.con.bed.cname.bed.phas-gerp.bed > CNE/${maf}.c.con.bed.cname.bed.phas-gerp.sorted.bed
	#merge if overlaped
	$bed_tools_bin/bedtools merge -i CNE/${maf}.c.con.bed.cname.bed.phas-gerp.sorted.bed -d 10 -c 4 -o collapse > CNE/${maf}.c.con.bed.cname.bed
	perl -i -p -ne 's/,/_/g' ./CNE/${maf}.c.con.bed.cname.bed
	}
	#overlaped with cds or not
	$bed_tools_bin/bedtools intersect -wo -a ./CNE/${maf}.c.con.bed.cname.bed -b ${cds_gff%.gff}.cds.gff > ./CNE/${maf}.c.con.bed.cname.bed.overlap
	$bed_tools_bin/bedtools intersect -v -a ./CNE/${maf}.c.con.bed.cname.bed -b ${cds_gff%.gff}.cds.gff > ./CNE/${maf}.c.con.bed.cname.bed.no.overlap
	printf "produced files: %s ...\n" ./CNE/${maf}.c.con.bed.cname.bed.[no.]overlap 
done
}
