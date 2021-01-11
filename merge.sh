#!/usr/bin/env sh

###
# Usage: merge.sh <dir1> <dir2> <dir3> ...
###

set -e

study="study"

echo Build text files

prefix="FS6.0.${study}"
for b in 10 11 12 13 17 18 26 49 50 51 52 53 54 58
do
    for m in "thick" "LogJacs"
    do
        out="${prefix}.${m}.${b}.txt"
        \rm -f $out
        for s in "$@"
        do
            od -f "${s}"/*/${m}_${b}.raw | gawk 'BEGIN{a="'$s'"}{for(i=2;i<NF+1;i++)a=a" "$i}END{print a}' >> $out
        done
    done
done

echo Add header and remove NAs

for f in "${prefix}".*.txt
do
    gawk 'BEGIN{f="'$f'";gsub(".txt",".clean.txt.gz",f)}{if(a<NF)a=NF;b[$1]=$0;c[$1]=NF}END{for(i=0;i<a;i++)if(i==0){h="bigrfullname"}else h=h" Vert_"i;print h | "gzip -9c > "f; for (d in b) if (c[d]==a) print b[d] | "gzip -9c > "f}' "$f"
done

echo Build and run R script

cat << EOF > merge.R

gzfiles=system("ls ${prefix}.*.clean.txt.gz",intern=T)

for (f in gzfiles){
    fX=gsub(".gz","",f)
    fR=gsub(".txt",".Rdata",fX)
    system(paste("zcat ",f," > ",fX,sep=""),intern=T)
    out=as.data.frame(read.table(fX, header=T))
    rownames(out) <- out[,1]
    out[,1] <- NULL
    save(out,file=fR)
    system(paste("rm ",fX,sep=""),intern=T)
}
EOF

Rscript merge.R

echo cleanup
\rm -f ${prefix}* 
\rm -f merge.R