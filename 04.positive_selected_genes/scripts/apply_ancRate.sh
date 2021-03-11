#!/bin/bash
#do episodic positive selection test with codeml site-branch model
toolsdir=$(cd $(dirname $0);pwd)

if [[ $# -lt 1 ]];then
 echo ">>>input `basename $0` -h to see the usage<<<"
 exit 1
fi
######get option###########
while getopts "a:t:h" opt
do
  case $opt in
    a)
      echo "aligned cds alignment in phylip format" >&2
      inphy=$OPTARG
      ;;
    t)
      echo "newick tree" >&2
      intree=$OPTARG
      ;;
    h)
      echo "USAGE:`basename $0` -a in.phy -t in.tree">&2
      exit 1
      ;;
    \?)
      echo "No option match the input" >&2
      exit 1
      ;;
  esac
done
shift $(($OPTIND - 1))


#set alternative model 
cat <<EOF > aaRate.ctl
     seqfile = $inphy            * sequence data file name
    treefile = $intree     * tree structure file name
     outfile = mlc 	   *${inphy%.*}.alt.mlc * main result file name---------------- 

        noisy = 3  * 0,1,2,3,9: how much rubbish on the screen
      verbose = 1  * 0: concise; 1: detailed, 2: too much
      runmode = 0  * 0: user tree;  1: semi-automatic;  2: automatic
                   * 3: StepwiseAddition; (4,5):PerturbationNNI; -2: pairwise

      seqtype = 2  * 1:codons; 2:AAs; 3:codons-->AAs
   aaRatefile = $toolsdir/dat/jones.dat * only used for aa seqs with model=empirical(_F)
                   * dayhoff.dat, jones.dat, wag.dat, mtmam.dat, or your own

        model = 3
                   * models for AAs or codon-translated AAs:
                      * 0:poisson, 1:proportional, 2:Empirical, 3:Empirical+F
                      * 6:FromCodon, 7:AAClasses, 8:REVaa_0, 9:REVaa(nr=189)
        Mgene = 0
                   * AA: 0:rates, 1:separate

        clock = 0  * 0:no clock, 1:global clock; 2:local clock
    fix_alpha = 0  * 0: estimate gamma shape parameter; 1: fix it at alpha
        alpha = 1  * initial or fixed alpha, 0:infinity (constant rate)
       Malpha = 0  * different alphas for genes
        ncatG = 8  * # of categories in dG of NSsites models

        getSE = 1  * 0: don't want them, 1: want S.E.s of estimates
 RateAncestor = 1  * (0,1,2): rates (alpha>0) or ancestral states (1 or 2)

    cleandata = 0  * remove sites with ambiguity data (1:yes, 0:no)?
*  fix_blength = 1  * 0: ignore, -1: random, 1: initial, 2: fixed
        method = 1   * 0: simultaneous; 1: one branch at a time
EOF
#NOTE: We estimate the Ts/Tv ratio (fix_kappa = 0) and the dN/dS (fix_omega = 0). 
#The branch-site model is specified by setting the model parameter to 2 (different dN/dS for branches) and 
#the NSosites value to 2 (which allows 3 categories for sites: purifying, neutral and positive selection

$toolsdir/codeml aaRate.ctl 
mv rst ${inphy%.*}.rst

