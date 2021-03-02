#!/usr/bin/perl 
my $tree;
if($#ARGV < 0){
	print "perl $0 *.nex\n";
	exit;
}
while(<>){
	chomp;
	$tree=$_;
}
#print "$tree\n";
$tree=&addnodes($tree);
$tree=~s/%left%/(/g;
$tree=~s/%right%/)/g;
print "$tree\n";
sub addnodes{
	my $tree=shift;
	if($tree=~/(\([A-Za-z].*?\d+?\))/){
		my $tree1=$1;
		#print "$tree1+++\n";
		my $countl=$tree1=~tr/\(/\(/;
		my $countr=$tree1=~tr/\)/\)/;
		#print $countl, $countr;
		while($countl>$countr){
			$tree1=~s/\(/delete_l/;
			$countl=$tree1=~tr/\(/\(/;
			$countr=$tree1=~tr/\)/\)/;
		}
		while($countl<$countr){
			$tree1=~s/\)/delete_r/;
			$countl=$tree1=~tr/\(/\(/;
			$countr=$tree1=~tr/\)/\)/;
		}
		
		if($countl==$countr&& $countr==1){
			if($tree1=~/\((%left%.*?\d+?)\)/){
				$tree2=$1;
			}elsif($tree1=~/\(([A-Za-z].*?\d+?)\)/){
				$tree2=$1;
			}
			#my $tree2=$1,if($tree1=~/\(([A-Z].*?\d+?)\)/);
			my @lables=$tree2=~/(\w+):\d\.\d+/g;
			@lables =grep {++$cout{$_}<2} @lables;
			my $out = join"_",@lables;
			$tree=~s/\($tree2\)/%left%$tree2%right%$out/;
		}
	}
#	print "$tree\n";
	if($tree=~/\(/){
#		print "$tree===\n";
		$tree=&addnodes($tree); # 
	}
	return $tree;	
}
