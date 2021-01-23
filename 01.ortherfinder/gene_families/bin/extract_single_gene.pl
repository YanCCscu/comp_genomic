#!/usr/bin/perl -w
use Parallel::ForkManager;
use File::Spec;
my $path_curf = File::Spec->rel2abs(__FILE__);
my ($vol, $dirs, $file) = File::Spec->splitpath($path_curf);
if($#ARGV<2){
	print"example: perl $0 /data/project/nfs/pcj/somite_snakes/cds /data/project/nfs/pcj/somite_snakes/pep/Results_Nov17_1/Orthogroups.single.csv(gene table has head !) 30 \n ";
	exit;
}
my $cds_dir=$ARGV[0];
my $max_process = $ARGV[2] ||40;
my $pm = new Parallel::ForkManager($max_process);
`rm -rf family_split_cds` if (-e "family_split_cds");
mkdir "family_split_cds";
my %cds_seqs;
my $species_number=0;
opendir CDS_DIR,"$cds_dir";
while(readdir CDS_DIR){
	next,unless(/\.fa/);
	open IN,"$cds_dir/$_" or die "can not open $cds_dir/$_\n";
        $/=">";
	my @file_names=split/\./;
        while(<IN>){
        	chomp;
                next,unless($_);
                my @lines = split/\n/;
		$lines[0] =~s/Komodo\|//;
                my @names=split/\./,$lines[0];
                my $seq=join"",@lines[1..$#lines];
		my @seq_names=split" ",$lines[0];
		$cds_seqs{"$file_names[0]|$seq_names[0]"}=$seq;
		

       }
       close IN;
       $/="\n";
}
open GENE_table,"$ARGV[1]" or die "can not open $ARGV[1] \n";
my @pep_files;
my %super_tree;
while(<GENE_table>){
	chomp;
	if($.==1){
		@pep_files=split/\s+/,$_;	
		$species_number=$#pep_files;		
	}
	
	if($.>1){
		@lines=split/\t/,$_;
		open OUT,">>family_split_cds/$lines[0].cds.fa" or die "can not open $lines[0]\n";
		for(my $i=1;$i<=$#lines;$i++){
			my @species=split/\./,$pep_files[$i];
			my @gene_names=split" ",$lines[$i];
			$gene_names[0]=~s/Komodo\|//;
			print OUT ">$species[0]|$gene_names[0]\n",$cds_seqs{"$species[0]|$gene_names[0]"},"\n",if(exists $cds_seqs{"$species[0]|$gene_names[0]"});
			if(!exists $cds_seqs{"$species[0]|$gene_names[0]"}){
				print "no $species[0]|$gene_names[0] found in cds files please check the seq names in pep and cds files!\n";
				exit;
			}	
		}
		close OUT;		
	}	
}
my @families=glob"family_split_cds//*.cds.fa";
LINE:
foreach(@families){
	$pm->start and next LINE;
#	print "prank -d=$_ -o=$_ -codon\n";
	system("perl $dirs/cds2pep_zy.pl -f $_ -o $_.pep.fa -c 1");
	system("perl $dirs/pep_prank_and_trimal_html.pl $_.pep.fa");
	system("perl $dirs/pep_trimal2cds_trimal.pl $_ $_.pep.fa.best.fas $_.pep.fa.best.fas.trimal.html > $_.trim");
	system("perl $dirs/prank2phylip_spe.pl $_.trim $_.trim.phylip ");
	#print "trimal -in $_.best.fas -out $_.best.fas.trim -automated1\n";
	$pm->finish;
}
$pm->wait_all_children;
#$species_number=8;
my @aligned_files=glob"family_split_cds//*.trim";
open OUT,">contanated_genes.fa";
foreach my $file(@aligned_files){
	my $line_number=`grep -c \\> $file`;
	chomp $line_number;
#	print "$line_number\t$species_number\n";
	next,unless($line_number == $species_number);
	open IN,"$file" or die "can not open $file\n";
	$/=">";
	while(<IN>){
		chomp;
		next,unless($_);
		@lines=split/\n/;
		my @names=split/\|/,$lines[0];
		my $seq=join"",@lines[1..$#lines];
		$super_tree{$names[0]}.=$seq;
	}
	close IN;
	$/="\n";
}
foreach(keys %super_tree){
	print OUT ">$_\n$super_tree{$_}\n";
}
close OUT;
