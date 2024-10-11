library(randomForest)
tc_map = read.table("metadata.txt",header = T, row.names = 1)
otu_table =read.table("/data/project/LBB-16S/feipang/stamp/compare/tax_6Genus.txt",header = T, row.names = 1)
sub_map = tc_map
sub_otu = otu_table


set.seed(315)
rf = randomForest(t(sub_otu), sub_map$BMI, importance=TRUE, proximity=TRUE, ntree = 1000)
imp= as.data.frame(rf$importance)
imp = imp[order(imp[,1],decreasing = T),]
head(imp,n=10)
write.table(imp,file = "importance_class.txt",quote = F,sep = '\t', row.names = T, col.names = T)
print(rf)

result = rfcv(t(sub_otu), sub_map$BMI, cv.fold=5)
result$error.cv
with(result, plot(n.var, error.cv, log="x", type="o", lwd=2))
error.cv0 = data.frame(num = result$n.var, error.1 =  result$error.cv)
for (i in 1:(1+4)){
      print(i)
  set.seed(i)
    result= rfcv(t(sub_otu), sub_map$BMI, cv.fold=5) #  scale = "log", step = 0.9
    error.cv0 = cbind(error.cv0, result$error.cv)
}
error.cv0

library(pROC)
library(dplyr)

df<-read.table("6Genus.roc.input",sep="\t",header=T,row.names = 1,check.names = F,as.is=F)
rownames(df)=gsub(".*\\|","",rownames(df))
df<-as.data.frame(t(df))

top<-colnames(df)[-1]
df1<-df
name<-vector()
dfauc1<-vector()
for (taxn1 in top) {
  auc1<-roc(df1$Group, as.numeric(df1[[taxn1]]),ci=T)
  name<-append(name,taxn1)
  dfauc1<-append(dfauc1,auc1$auc)
}
aucdf<-data.frame(name,dfauc1)
colnames(aucdf)<-c("ID","N_vs_O")
write.table(aucdf,"16S.aucdf.xls",row.names = F,quote = F,sep="\t")
df1<-df%>%mutate(combine=as.numeric(Bergeyella))
df2<-df%>%mutate(combine=as.numeric(Sphingomonas))
pdf("roc.N_vs_O.pdf",8,8)
rocobj1<-plot.roc(df1$Group, as.numeric(df1$`combine`),main="N_vs_O", col="#E44165",legacy.axes=TRUE,print.auc=TRUE,lwd=2,identity.lty=2,pri
nt.auc.x=0.6,print.auc.y=0.4,auc.polygon=T,auc.polygon.col="#FEF6F6",grid=TRUE,grid.lwd=2)
rocobj2<-plot.roc(df2$Group, as.numeric(df2$`combine`), col="black",legacy.axes=TRUE,print.auc=TRUE,add=TRUE,lwd=2,identity.lty=2,print.auc.
x=0.6,print.auc.y=0.35)
testobj <- roc.test(rocobj1, rocobj2)
text(0.5, 0.05, labels=paste("p =", format.pval(testobj$p.value)), adj=c(0, .5))
dev.off()

