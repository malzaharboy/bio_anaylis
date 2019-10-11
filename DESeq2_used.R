path = 'C:/Users/FREEDOM/Desktop/TCGA_data/mainfest'
floders = list.files(path)#�г���Ŀ¼�º����ļ��е�����
BRCA_counts = data.frame()#����dataframe
fd1 = floders[1]#��һ���ļ���
file_name  =list.files(paste(path,'/',fd1,sep =''))#�г��ļ���fd1�е�ȫ���ļ���
file_list = substr(file_name[1],1,28)#�Ե�һ���ļ����������ֽ�ͼ��
mydata = read.table(gzfile(paste(path,'/',fd1,'/',file_name[1],sep = '')))#��ȡ��ѹ��gz�ڲ������ݣ�
names(mydata) <- c('ECSG_ID',file_list)#��ȡ��һ��gz�ļ�֮�󣬰��ļ�������������
BRCA_counts = mydata#��ֵΪBRCA����counts����
for (fd in floders[2:200]){#ѭ����200���ļ����д�����
  files_name = list.files(paste(path,'/',fd,sep = ''))
  print(files_name[1])
  file_list =substr(files_name[1],1,28)
  mydata = read.table(gzfile(paste(path,'/',fd,'/',files_name[1],sep = '')))
  names(mydata) <- c('ECSG_ID',file_list)
  BRCA_counts <- merge(BRCA_counts,mydata,by ='ECSG_ID')#���������ensg��Ž��кϲ���
 
}
write.csv(BRCA_counts,'C:/Users/FREEDOM/Desktop/TCGA_data/BRCA_counts.csv')#������д��csv�ļ��У�
group_text =read.csv(file = 'C:/Users/FREEDOM/Desktop/TCGA_data/group_text1.csv',header = T)
library(biomaRt)
library(curl)
#���л���ע��
new_data <- read.csv(file = 'C:/Users/FREEDOM/Desktop/TCGA_data/BRCA_counts1.csv')
rownames(new_data) <- new_data[,1]
new_data <- new_data[c(-1)]
print(rownames(new_data))
# 
char =substr(rownames(new_data),1,15)
print(char)
rownames(new_data) <- substr(rownames(new_data),1,15)
# 
# 
mart <- useDataset("hsapiens_gene_ensembl", useMart("ensembl"))  #����mart
my_ensembl_gene_id<-char #��Ҫת����exsembl�ı��룻
my_ensembl_gene_id
# 
# mms_symbols<- getBM(attributes=c('ensembl_gene_id','hgnc_symbol',"description"),filters = 'ensembl_gene_id',values = my_ensembl_gene_id,mart = mart)#����ע��֮��ı�
# 
# 
ensembl_gen_id <- char
result_diff<-cbind(ensembl_gen_id,new_data)
colnames(new_data)[1]<-c("ensembl_gene_id")
rownames(result_diff) <- NULL
print(colnames(mms_symbols))
print(colnames(result_diff))
colnames(result_diff)[1] <-c("ensembl_gene_id")
colnames(mms_symbols)[1] <- c("ensembl_gene_id")
 
resul_diff <- merge(result_diff,mms_symbols,by = "ensembl_gene_id")  #��ensembl_gene_idΪ�������кϲ�
result_diff <- resul_diff[,1:202]
write.csv(result_diff,'C:/Users/FREEDOM/Desktop/TCGA_data/group_notetext.csv')
#���в��������limma����
new_data <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/group_note.csv',headers <- T)
express_rec <- new_data
rownames(express_rec) <- express_rec[,1]
l
source("https://bioconductor.org/biocLite.R")#���밲װ��ַ��
biocLite("clusterProfiler")#���س������
biocLite("org.Hs.eg.db")

library(clusterProfiler)
library(org.Hs.eg.db)#����ע��(ENSGת��Ϊsymbol_id�õ�����������
char <- new_data$ensembl_gene_id

gen_ids <- bitr(char,fromType = 'ENSEMBL',toType = c("SYMBOL", "GENENAME"),OrgDb = 'org.Hs.eg.db')#ע�ͽ��д�����
colnames(gen_ids)[1] <-  c("ensembl_gene_id")
gen_ids <- gen_ids[,1:2]
new_data1 <- merge(gen_ids,new_data,by ='ensembl_gene_id')
write.csv(new_data1,'C:/Users/FREEDOM/Desktop/TCGA_data/after_note.csv')

express_rec<- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/after_note2.csv')#��ȡ����
group_text <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/group_text.csv')

library('DESeq2')#���ذ���
install.packages('rpart')#����������ɺ��ԣ�û�е�ʱ��Ű�װ��
express_rec <- express_rec[,-1]
express_rec <- express_rec[,-1]
rownames(express_rec) <-express_rec[,1]
express_rec <- express_rec[(-1)]#�������Ĵ�����
rownames(group_text) <- group_text[,1]
group_text <- group_text[c(-1)]#�����������ݴ�����
all(rownames(group_text)==colnames(express_rec))#ȷ����������������������������һ�£�
dds <- DESeqDataSetFromMatrix(countData=express_rec, colData=group_text, design<- ~ group)  #DESeq2�ļ���
head(dds)
dds <- dds[ rowSums(counts(dds)) > 1, ] #����һЩlow count�����ݣ�
dds <- DESeq(dds)#DESeq���б�׼����
resultsNames(dds)
res <- results(dds)
summary(res)#�鿴������׼������Ļ��������
mcols(res,use.names = TRUE)
res_data <- merge(as.data.frame(res),as.data.frame(counts(dds,normalize = TRUE)),by = 'row.names',sort = FALSE)
res_data <- res_data[,1:7] 
write.csv(res_data,'C:/Users/FREEDOM/Desktop/TCGA_data/result_diff.csv')

#����plotMAͼ��
png(file="C:/Users/FREEDOM/Desktop/TCGA_data/plotMA_lfcshrink.png", bg="transparent")
res.shrink <- lfcShrink(dds, contrast = c("group","Tumor","Normal"), res=res)
plotMA(res.shrink, ylim = c(-5,5))#ͼƬ�߽���޶���
topGene <- rownames(res)[which.min(res$padj)]
with(res[topGene, ], {
  points(baseMean, log2FoldChange, col="dodgerblue", cex=2, lwd=2)
  text(baseMean, log2FoldChange, topGene, pos=2, col="dodgerblue")
})
dev.off()#ͼƬ���ɣ�




res_data <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/result_diff.csv',headers <- T)
res_data <- res_data[,-1]#���������Ҫ�ľ�����ȡ��
install.packages('ggrepel')#��װ�������
library(ggplot2)#���ػ�ɽͼ����
library(ggrepel)
#���ƻ�ɽͼ
rank_data <- res_data[order(res_data[,6]),]#��������ĳһ������
volcano_names <- rank_data$Row.names[1:5]#ȡpvalue��С���������
res_data$ID2 <- ifelse((res_data$Row.names %in% volcano_names)&abs(res_data$log2FoldChange)>3,gsub('"',''
                ,as.character(res_data$Row.names)),NA)#�ھ���res_data�����д���һ���ĵ��У���������|log2folchange|����3 �Ļ����������򱣴�ΪNA��
png(file="C:/Users/FREEDOM/Desktop/TCGA_data/myplot_lpval.png", bg="transparent")#�ȴ���һ��ͼƬ
boundary = ceiling(max(abs(res_data$log2FoldChange)))#ȷ��x��ı߽磻
threshold <- ifelse(res_data$pvalue<0.05,ifelse(res_data$log2FoldChange >=3,'UP',ifelse(res_data$log2FoldChange<=(-3),'DW','NoDIFF')),'NoDIFF')#���÷ֽ緧ֵ
ggplot(res_data,aes(x=res_data$log2FoldChange,y =res_data$pvalue,color=threshold))+geom_point(size=1, alpha=0.5) + theme_classic() +
  xlab('log2 fold_change')+ylab(' p-value') +xlim(-1 * boundary, boundary) + theme(legend.position="top", legend.title=element_blank())
+ geom_text_repel(aes(label=res_data$ID2))#��ɽͼ���ı���ǩ��ע��
dev.off()#�����ɽͼͼƬ��



deseq2_heatmap <- rank_data[1:30,]#ȡǰ30�����컯���Ļ���
write.csv(deseq2_heatmap,'C:/Users/FREEDOM/Desktop/TCGA_data/DEseq2_heatmap.csv')
#������ͼ��


library(pheatmap)#������ͼ�������


initial_rec <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/after_note2.csv')
express_rec <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/DEseq2_diffen.csv')
data_rec <-express_rec[1:30,]#ȡ����������30������
colnames(initial_rec)[2] <- c('gene_name')
data_rec <- merge(initial_rec,data_rec,by <- 'gene_name')
data_rec <-data_rec[,1:202]
data_rec1 <- data_rec[,-2]
group_text <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/group_text.csv')
annotation_col = data.frame(#����annotation_col����Ϊ������ͼ�ĺ���������׼����
  sampleType = factor(group_text$group)
)
data_rec <- data_rec[-16,]
rownames(data_rec) <- data_rec[,1]
data_rec <- data_rec[,-1]
data_rec <- data_rec[,-1]
data_rec[data_rec==0] <-1
data_rec <-log(data_rec,2)#�Ա�������ֵ���б�׼����
rownames(annotation_col) <-substr(colnames(data_rec),9,25)#������ȡ������ֵ��
colnames(data_rec) <-rownames(annotation_col)#ȷ��annotataion_col����������������������һ�£�
#������ͼ��
png("C:/Users/FREEDOM/Desktop/TCGA_data/TCGA_GBM_diff.png",height = 800, width = 1600)
pheatmap(data_rec,annotation_col = annotation_col,color <- colorRampPalette(c('red','black','green'))(100),main ='TCGA_BRCA��Tumor��Normal��������')
dev.off()

# gene <- deseq2_heatmap['Row.names']#�ɲ�������������ȡ�Ļ���
# express_rec <- read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/after_note2.csv')
# express_rec <- express_rec[,-1]
# express_rec <- express_rec[,-1]
# colnames(express_rec)[1] <- c('symbol')
# filter_data <- express_rec[gene[,1],]#�ӱ������ɸѡ����ָ������ı������
# rownames(filter_data) <-  filter_data[,1]
# filter_data <- filter_data[c(-1)]
# filter_data[filter_data==0] <-1#�Ѿ�����Ϊ0������ת��Ϊ1��Ϊ����log��׼����
# filter_data <- log(filter_data,2)#�����е����ݽ���log2������
# data_1 <- as.matrix.data.frame(filter_data)
# data <- matrix(as.numeric(data_1),ncol = 200)#ת��Ϊ����
# text_group =read.csv('C:/Users/FREEDOM/Desktop/TCGA_data/group_text.csv')#�������Ĵ�����
# colnames(data) <- as.character(text_group[,1])#����������������ã�
# anno <- data.frame(CellType =factor(text_group[,2]))
# rownames(anno) <- colnames(data)
# anno_colors <- list(CellType = c(Tumor = "#1B9E77", Normal = "#D95F02"))#������ͼlengend(��ǩ)��ɫ��
# text_sample <- log2(data+1)#����log��
# rownames(text_sample) <- rownames(data)#��ͼ���ƶ����������������ã�
# pheatmap(text_sample,
#          color <- colorRampPalette(c('red','black','green'))(100),cluster_rows = TRUE,
#          cluster_cols = TRUE,
#          main = 'TCGA_BRCA��֢�방�Ի��������ͼ',
#          # annotation_col <- anno,
#          )