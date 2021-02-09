
#Chelonia_mydas
#Alligator_mississippiensis
#Alligator_sinensis
#Nanorana_parkeri
ftpsites=( ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/015/237/465/GCF_015237465.1_rCheMyd1.pri \
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/281/125/GCF_000281125.3_ASM28112v4 \
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/455/745/GCF_000455745.1_ASM45574v1 \
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/935/625/GCF_000935625.1_ASM93562v1 )
ftpsites=(https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/009/667/805/GCA_009667805.1_ASM966780v1)
ftpsites=(https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/331/425/GCF_000331425.1_PseHum1.0)
for ftpsite in ${ftpsites[@]}
do
	lftp -e 'mget -c *cds_from_genomic.fna.gz *genomic.fna.gz *genomic.gff.gz *genomic.gtf.gz *protein.faa.gz *translated_cds.faa.gz;exit' $ftpsite
q
done
