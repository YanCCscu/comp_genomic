#!/bin/bash
[[ $# -lt 2 ]] && { echo sh $0 INFAS 'sps'; \
echo exmaple: sh groupSPEsnp.sh infas 'Tbai,Phum';\
exit 1
}
cmdir=$(cd $(dirname $0);pwd)
INFAS=$1
INSP=$2 #'Tbai|Phum'
INSP=${INSP//,/\\|}
outbase=$(basename $INFAS)
outbase=${outbase%.*}
############
grep \> $INFAS|sed 's/>//'|sed -e 's/$/\tOUT/' -e "/^$INSP/s/OUT$/IN/" >sp_groupout.list
python3 $cmdir/13.GroupSpecSNPsDetect.py -a $INFAS -c sp_groupout.list -g 5 -o ${outbase}.table
