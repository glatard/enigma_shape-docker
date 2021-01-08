#!/usr/bin/env bash

###
# Usage: merge.sh <dir1> <dir2> <dir3> ...
###


study="study"

for b in 10 11 12 13 17 18 26 49 50 51 52 53 54 58
do
    for m in "thick" "LogJacs"
    do
        out="FS6.0.${study}."${m}"."${b}".txt"
        \rm -f $out
        for s in $*
        do
            od -f shape/${s}/${m}_${b}.raw | gawk 'BEGIN{a="'$s'"}{for(i=2;i<NF+1;i++)a=a" "$i}END{print a}' >> $out
        done
    done
done

\rm merge.R
cat << EOF > merge.R

gzfiles=system("ls FS6.0.${study}.*.clean.txt.gz",intern=T)

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
