BEGIN{
	maffile=ARGV[1]
	outdir=ARGV[2]
	split(maffile,sf,"/")
	sflen=length(sf)
	outbase=outdir"/"sf[sflen]
	i=1
	title=""
}
{
	if(NR==1){
		title=$0
	}
	if(NR==total_line){
		if ($0~/^\s*$/) next
	}
	if ($1!~/a|s/){
		i++
		print title > outbase".block"i".maf"
	} else {
		print $0 > outbase".block"i".maf"
	}
}

