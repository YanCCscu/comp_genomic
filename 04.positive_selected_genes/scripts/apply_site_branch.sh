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
cat <<EOF > sitebranch.alt.ctl
     seqfile = $inphy            * sequence data file name
    treefile = $intree     * tree structure file name
     outfile = ${inphy%.*}.alt.mlc      * main result file name---------------- 
 
       noisy = 3   * 0,1,2,3,9: how much rubbish on the screen
     verbose = 1   * 1: detailed output, 0: concise output
     runmode = 0   * 0: user tree;  1: semi-automatic;  2: automatic
                   * 3: StepwiseAddition; (4,5):PerturbationNNI; -2: pairwise

     seqtype = 1   * 1:codons; 2:AAs; 3:codons-->AAs
   CodonFreq = 2   * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
       clock = 0   * 0: no clock, unrooted tree, 1: clock, rooted tree
      aaDist = 0   * 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
       model = 2   * models for codons:
                   * 0:one, 1:b, 2:2 or more dN/dS ratios for branches
     NSsites = 2   * 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete;
                   * 4:freqs; 5:gamma;6:2gamma;7:beta;8:beta&w;9:beta&gamma;10:3normal
       icode = 0   * 0:standard genetic code; 1:mammalian mt; 2-10:see below
       Mgene = 0   * 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
   fix_kappa = 0   * 1: kappa fixed, 0: kappa to be estimated
       kappa = 2   * initial or fixed kappa
   fix_omega = 0   * 1: omega or omega_1 fixed, 0: estimate ---------------------------
       omega = 1   * initial or fixed omega, for codons or codon-based AAs
       getSE = 0       * 0: don't want them, 1: want S.E.s of estimates
RateAncestor = 0       * (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
  Small_Diff = .45e-6  * Default value.
   cleandata = 1       * remove sites with ambiguity data (1:yes, 0:no)?
 fix_blength = 0       * 0: ignore, -1: random, 1: initial, 2: fixed
EOF
#NOTE: We estimate the Ts/Tv ratio (fix_kappa = 0) and the dN/dS (fix_omega = 0). 
#The branch-site model is specified by setting the model parameter to 2 (different dN/dS for branches) and 
#the NSosites value to 2 (which allows 3 categories for sites: purifying, neutral and positive selection

cat <<EOF > sitebranch.nul.ctl
     seqfile = $inphy               * sequence data file name
    treefile = $intree        * tree structure file name
     outfile = ${inphy%.*}.nul.mlc  * main result file name--------------
 
       noisy = 3   * 0,1,2,3,9: how much rubbish on the screen
     verbose = 1   * 1: detailed output, 0: concise output
     runmode = 0   * 0: user tree;  1: semi-automatic;  2: automatic
                * 3: StepwiseAddition; (4,5):PerturbationNNI; -2: pairwise

     seqtype = 1   * 1:codons; 2:AAs; 3:codons-->AAs
   CodonFreq = 2   * 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
       clock = 0   * 0: no clock, unrooted tree, 1: clock, rooted tree
      aaDist = 0   * 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
       model = 2   * models for codons:
                   * 0:one, 1:b, 2:2 or more dN/dS ratios for branches
     NSsites = 2   * 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete;
                   * 4:freqs; 5:gamma;6:2gamma;7:beta;8:beta&w;9:beta&gamma;10:3normal
       icode = 0   * 0:standard genetic code; 1:mammalian mt; 2-10:see below
       Mgene = 0   * 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
   fix_kappa = 0   * 1: kappa fixed, 0: kappa to be estimated
       kappa = 2   * initial or fixed kappa
   fix_omega = 1   * 1: omega or omega_1 fixed, 0: estimate---------------------------
       omega = 1   * initial or fixed omega, for codons or codon-based AAs
       getSE = 0       * 0: don't want them, 1: want S.E.s of estimates
RateAncestor = 0       * (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
  Small_Diff = .45e-6  * Default value.
   cleandata = 1       * remove sites with ambiguity data (1:yes, 0:no)?
 fix_blength = 0       * 0: ignore, -1: random, 1: initial, 2: fixed
EOF

$toolsdir/codeml sitebranch.nul.ctl
mv rst sitebranch.nul.rst
$toolsdir/codeml sitebranch.alt.ctl
mv rst sitebranch.alt.rst
