#!/bin/bash
[[ $# -lt 1 ]] && echo -e "bash $0 AllOutput.txt" && exit
[[ $# -ge 1 ]] && cnetable=$1 || cnetable=AllOutput.txt
finalbed=../final.all.bed
GFF=/data/share/yancc/GenoComp/07.CNE_detect/00.data_prepare/Tbai.gff
bedtools=/data/share/yancc/GenoComp/07.CNE_detect/00.data_prepare/tools/bedtools2/bin/bedtools
geneanno=/data/share/yancc/GenoComp/04.Positive_Selective_Test/NewRun2/scripts/Tbai.pep_hsa_gid.table
#get range for CNE
echo -e "Step One ..."
join  -1 4 -2 1 \
<(cut -d $'\t' -f1-4 $finalbed|sort -k4) \
<(tail -n +2 $cnetable| awk '($7<0.05 && $7>0) || ($9 < 0.05 && $9 > 0)' |cut -d' ' -f1,7,9|sort -k1) |\
awk '{print $2,$3,$4,$1,$5,$6}' \
>CNE.range.table

echo -e "Step Two ..."
#expand CNE range by add 2000bp at both terminators
awk -v OFS='\t' '{$2=$2-2000;$3=$3+2000;if($2<0){$2=1};print $0}' CNE.range.table >CNEex.range.table

echo -e "Step Three ..."
#CNE overlaped with gene region
$bedtools intersect -wo -a CNEex.range.table -b $GFF > CNEex_gene_bed.overlap
sed -i 's/ID=\([^\t;.]\+\)\S*/\1.t1/' CNEex_gene_bed.overlap

echo -e "Step Four ..."
#merge with gene annotation
join -a1 -1 15 -2 1  <(sort -k 15 CNEex_gene_bed.overlap) <(sort -k1 $geneanno) >CNEex_gene_bed.anno

echo -e "\e[1;91mPRODUCED FILES: CNE.range.table CNEex.range.table CNEex_gene_bed.overlap CNEex_gene_bed.anno\e[0m\n" 
