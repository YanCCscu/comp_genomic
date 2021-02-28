if [ $# -lt 1 ];
then
	echo "sh $0  prefix_maf species_number split_number";
	echo "Example: sh work.splitmaf.sh Oapo-Acar-Lvir-Nnaj 4 11"
	exit;
fi
cmdir=$(cd $(dirname $0);pwd)
prefix=$1
species_number=$2
split_number=$3
[[ -d splitmaf ]] || mkdir -p splitmaf
for i in ${prefix}.*
do
	$cmdir/kent/bin/linux.x86_64/mafFilter -minRow=$species_number -minScore=20000 $i > ${i}.filtered.final.maf
done

for i in `seq 1 $split_number`
do
	$cmdir/kent/bin/linux.x86_64/mafSplit -byTarget splits.bed splitmaf/all${i} ${prefix}.${i}.net.filtered.axt.maf.filtered.final.maf
done

for i in splitmaf/all*
do
	perl -p -e's/_\S+//' $i  > ${i}.c
done
