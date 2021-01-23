#!/usr/bin/env perl  
use strict;
use warnings;
use Text::Wrap qw(wrap $columns $huge);
my($cds_file,$code_table,$outfile);
use Getopt::Long;
GetOptions(
        "file|f:s"=>\$cds_file,
	"code_table|c:i"=>\$code_table,
	"out|o:s"=>\$outfile,
        "help|?"=>\&USAGE,
);
unless($cds_file && $code_table && $outfile){
	&USAGE;
}
#die "perl $0 <input cds file> <output pep file> <translation table No(1 or 11)>()\n" unless (@ARGV==3);


open IN,"$cds_file" or die "Cannot open input file: $cds_file $!";
open OUT,">$outfile" or die "Cannot open output file: $!";

my ($i,$j,$k);
my ($in,$seq,$out);
my ($aas,$starts,$base1,$base2,$base3);
my $temp;
my $flag=0;
my @mod;
my (%hash,%hashStarts);

if($code_table == 1)
{
	$aas    = "FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
	$starts = "---M---------------M---------------M----------------------------";
	$base1  = "TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
	$base2  = "TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
	$base3  = "TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table == 2){
	$aas  	= "FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSS**VVVVAAAADDEEGGGG";
  	$starts = "----------**--------------------MMMM----------**---M------------";
  	$base1  = "TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  	$base2  = "TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  	$base3  = "TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";

}
if($code_table ==3){
    $aas  ="FFLLSSSSYY**CCWWTTTTPPPPHHQQRRRRIIMMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------**----------------------MM----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==4){
    $aas  ="FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="--MM------**-------M------------MMMM---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==5){
    $aas  ="FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSSSSVVVVAAAADDEEGGGG";
  $starts ="---M------**--------------------MMMM---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==6){
    $aas  ="FFLLSSSSYYQQCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="--------------*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==9){
    $aas  ="FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNNKSSSSVVVVAAAADDEEGGGG";
  $starts ="----------**-----------------------M---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==10){
    $aas  ="FFLLSSSSYY**CCCWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------**-----------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==11){
    $aas  ="FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="---M------**--*----M------------MMMM---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==12){
    $aas  ="FFLLSSSSYY**CC*WLLLSPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------**--*----M---------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==13){
    $aas  ="FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNKKSSGGVVVVAAAADDEEGGGG";
  $starts ="---M------**----------------------MM---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==14){
    $aas  ="FFLLSSSSYYY*CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNNKSSSSVVVVAAAADDEEGGGG";
  $starts ="-----------*-----------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==16){
    $aas  ="FFLLSSSSYY*LCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------*---*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==21){
    $aas  ="FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIMMTTTTNNNKSSSSVVVVAAAADDEEGGGG";
  $starts ="----------**-----------------------M---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==22){
    $aas  ="FFLLSS*SYY*LCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="------*---*---*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==23){
    $aas  ="FF*LSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="--*-------**--*-----------------M--M---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==24){
    $aas  ="FFLLSSSSYY**CCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSSKVVVVAAAADDEEGGGG";
  $starts ="---M------**-------M---------------M---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==25){
    $aas  ="FFLLSSSSYY**CCGWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="---M------**-----------------------M---------------M------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==26){
    $aas  ="FFLLSSSSYY**CC*WLLLAPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------**--*----M---------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==27){
    $aas  ="FFLLSSSSYYQQCCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="--------------*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==28){
    $aas  ="FFLLSSSSYYQQCCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------**--*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==29){
    $aas  ="FFLLSSSSYYYYCC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="--------------*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==30){
    $aas  ="FFLLSSSSYYEECC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="--------------*--------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
if($code_table==31){
    $aas  ="FFLLSSSSYYEECCWWLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG";
  $starts ="----------**-----------------------M----------------------------";
  $base1  ="TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG";
  $base2  ="TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG";
  $base3  ="TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG";
}
foreach $i (1..(length $aas)) 
{
	$temp =substr($base1,($i-1),1);
	$temp.=substr($base2,($i-1),1);
	$temp.=substr($base3,($i-1),1);
	$hash{$temp}=substr($aas,($i-1),1);
}

foreach $i (1..(length $starts)) 
{
    if(substr($starts,($i-1),1) eq "M")
    {
	$temp =substr($base1,($i-1),1);
	$temp.=substr($base2,($i-1),1);
	$temp.=substr($base3,($i-1),1);
	$hashStarts{$temp}=substr($starts,($i-1),1);
    }
};
$/ = ">";
<IN>;
while(my $line = <IN>){	
    chomp $line;
    my @a = split(/\n/,$line);
    my $head = shift @a;
    print OUT ">$head\n";
    my $seq = join "",@a;
    $seq=uc($seq);
    if($head =~ /Lack\s*5\'\-end/ || $head =~ /Lack\s*both\s*end/){
	for($i=0;$i<length($seq);$i+=3)	{
	    if(exists $hash{substr($seq,$i,3)}){
		my $amino = $hash{substr($seq,$i,3)};
		$amino = &distinguish_U($hash{substr($seq,$i,3)}),if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" && substr($seq,$i,3) eq "TGA");
	#	$amino = &distinguish_U($hash{substr($seq,$i,3)}),if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*");
		$out.=$amino;
	    }else{
		$out.="X";
	    }
	}
    }else{
	if(exists $hashStarts{substr($seq,0,3)}){
	    $out.=$hashStarts{substr($seq,0,3)};
	    for($i=3;$i<length($seq);$i+=3){
		if(exists $hash{substr($seq,$i,3)}){
		   # print "$hash{substr($seq,$i,3)}\t",length($seq),"\t",$i+3,"\n",if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" && substr($seq,$i,3) eq "TGA");
		    my $amino = $hash{substr($seq,$i,3)};
		    $amino = &distinguish_U($hash{substr($seq,$i,3)}),if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" && substr($seq,$i,3) eq "TGA");
		#    $amino = &distinguish_U($hash{substr($seq,$i,3)}),print substr($seq,$i,3),"\n",if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" );
		    $out.=$amino;
		}else{
		    $out.="X";
		}
	    }			
	}else{
	    for($i=0;$i<length($seq);$i+=3){
		if(exists $hash{substr($seq,$i,3)}){
		 #   print "$hash{substr($seq,$i,3)}\t",length($seq),"\t",$i+3,"\n",if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" && substr($seq,$i,3) eq "TGA");
		    my $amino = $hash{substr($seq,$i,3)};
	            $amino = &distinguish_U($hash{substr($seq,$i,3)}),if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" && substr($seq,$i,3) eq "TGA");
	          #  $amino = &distinguish_U($hash{substr($seq,$i,3)}),print substr($seq,$i,3),"\n",if(length($seq) != $i+3 && $hash{substr($seq,$i,3)} eq "*" );
		    $out.=$amino;
		}else{
		    $out.="X";
		}
	    }
	}

    };
    my @b = split(//,$out);
    if($b[-1] eq "*"){
	pop @b;
    };
    $out = join "",@b;
    $columns = 51;
    print OUT wrap('','', $out),"\n";
    $out = "";
}

sub distinguish_U{
	my $amino = shift;
	$amino = "U";
	return $amino;
}
sub USAGE{
    my $usage=<<"USAGE";
Name:
----$0   
Author pcj added all code tables 2018.3.17; Add function distinguish_U to deal with U.
Description:
You can use this script to translate cds to protein , file contain cds seqences should be fasta format.
Usage:
  options:
  -f     <str>                     
  -c	 <int> From https://www.ncbi.nlm.nih.gov/Taxonomy/Utils/wprintgc.cgi?mode=c#SG23) translate code table to choose.
	       1 The Standard Code for eukaryotes.
	       2 The Vertebrate Mitochondrial Code.
	       3 The Yeast Mitochondrial Code.
	       4 The Mold, Protozoan, and Coelenterate Mitochondrial Code and the Mycoplasma/Spiroplasma Code.
	       5 The Invertebrate Mitochondrial Code.
	       6 The Ciliate, Dasycladacean and Hexamita Nuclear Code.
	       9 The Echinoderm and Flatworm Mitochondrial Code.
	       10 The Euplotid Nuclear Code.
	       11 The Bacterial, Archaeal and Plant Plastid Code(is used for Bacteria, Archaea, prokaryotic viruses and chloroplast proteins).
	       12 The Alternative Yeast Nuclear Code.
	       13 The Ascidian Mitochondrial Code.
	       14 The Alternative Flatworm Mitochondrial Code.
	       16 Chlorophycean Mitochondrial Code.
	       21 Trematode Mitochondrial Code.
	       22 Scenedesmus obliquus Mitochondrial Code.
	       23 Thraustochytrium Mitochondrial Code.
	       24 Pterobranchia Mitochondrial Code.
               25 Candidate Division SR1 and Gracilibacteria Code.
	       26 Pachysolen tannophilus Nuclear Code.
	       27 Karyorelict Nuclear.
	       28 Condylostoma Nuclear.
	       29 Mesodinium Nuclear.
	       30 Peritrich Nuclear.
	       31 Blastocrithidia Nuclear.
  -o	       <str>
  -h|?         Help (print usage)
Example:
perl $0 -f cds.fa -c 1 -o  pep.fa 

USAGE
  print $usage;
  exit;
}
