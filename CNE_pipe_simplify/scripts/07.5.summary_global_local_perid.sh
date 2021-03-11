find ../Bed.fa -name "*.peridlocal"| xargs cat |grep -v ^branch > allcne.peridlocal.tmp
find ../Bed.fa -name "*.peridglobal"| xargs cat |grep -v ^species > allcne.peridglobal.tmp

find ../Bed.fa -name "*.peridlocal"| xargs cat | grep ^branch|sort -u|cat - allcne.peridlocal.tmp >allcne.peridlocal
find ../Bed.fa -name "*.peridglobal"| xargs cat | grep ^species|sort -u|cat - allcne.peridglobal.tmp >allcne.peridglobal

rm allcne.peridlocal.tmp allcne.peridglobal.tmp

#cat ../Bed.fa/*/*.peridglobal|grep ^species |sort -u|cat - allcne.peridglobal.tmp >allcne.peridglobal
