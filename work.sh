set -ex ;
db=script
Rscript=~/miniconda3/envs/R4/bin/Rscript

mkdir -p result/compare/
for compare in O-N
do
    $Rscript ${db}/compare.R \
      --input otutab.txt --design metadata.txt \
      --group Group --compare ${compare} --threshold 0.1 \
      --method edgeR --pvalue 0.05 --fdr 0.99 \
      --output ./compare
    bash ${db}/compare_manhattan.sh -i /data/project/LBB-16S/feipang/diff/result/compare/${compare}.txt \
       -t /data/project/LBB-16S/feipang/diff/result/taxonomy.txt \
       -p /data/project/LBB-16S/feipang/diff/result/otu_table.Family.relative.xls \
       -w 140 -v 102 -s 8 -l 12 -L Family \
       -o ./compare/${compare}.manhattan.f.legend.pdf
done

for compare in O-N
do
    $Rscript ${db}/script/compare_stamp.R \
      --input compare/tax_6Genus.txt --metadata metadata.txt \
      --group Group --compare ${compare} --threshold 0.1 \
      --method "wilcox" --pvalue 0.1 --fdr "fdr" \
      --width 189 --height 159 \
      --output ./compare/${compare}

done

