library(shiny)
library(ggplot2)
library(ggrepel)
library(dplyr)
library(shinymanager)
options(shiny.maxRequestSize=500*1024^2)
phoslib<-readRDS("phoslib/Library_wTryptic_pep.rds")


###############################################################################
credentials <- data.frame(user = "iSPI",password = "iSPI",stringsAsFactors = FALSE)

process_indi_locfile<-function(locfile,subpool,phos_symbol="#",phoslib=phoslib,cutoff,fname){
  cutoff<-gsub(" ","", unlist(strsplit(cutoff,split=";")))
  cutoff<-na.omit(as.numeric(cutoff))
  if(length(cutoff)==0){return(NULL)}

  subpool<-na.omit(as.numeric(subpool))
  if(length(subpool)==0){return(NULL)}

  sub_phoslib<-phoslib[phoslib$is_phos & phoslib$Subpool_ID==subpool,]
  if(nrow(sub_phoslib)==0){return(NULL)}

  if(ncol(locfile)!=2){return(NULL)}
  colnames(locfile)<-c("modScore_peptide","max_score")
  tmp_phos_ct<-sapply(locfile$modScore_peptide,function(x){lengths(regmatches(x, gregexpr(phos_symbol, x)))})
  locfile<-locfile[which(tmp_phos_ct==1),]

  ##replace the user phos symbol with "#"
  locfile$modScore_peptide<-gsub(phos_symbol,"#",locfile$modScore_peptide)
  ##replace parentheses and everything inside
  locfile$modScore_peptide<-gsub("\\s*\\([^\\)]+\\)","",locfile$modScore_peptide)
  ##replace special characters except for #
  locfile$modScore_peptide<-gsub("[][!$%()*,.:;<=>@^_`|~.{}]","",locfile$modScore_peptide)
  ##toupper
  locfile$modScore_peptide<-toupper(locfile$modScore_peptide)
  ##generate no mod sequence
  locfile$noModSeq<-gsub("#","",locfile$modScore_peptide)

  #are noMod sequences in the Subpool?
  locfile$is_noModSeq_inSubpool<-locfile$noModSeq %in% sub_phoslib$Tryptic_seq_noMod
  #are mod sequences in the Subpool?
  locfile$is_ModSeq_inSubpool<-locfile$modScore_peptide %in% sub_phoslib$Tryptic_seq
  #are Mod Sequences isomeric in the subpool?
  locfile$is_ModSeq_isomeric_inSubpool<-locfile$modScore_peptide %in% sub_phoslib$Tryptic_seq[sub_phoslib$is_tryseq_isomer_insubpool]
  #only keep sequences whose backbone seqs are in the subpool and no isomeric
  locfile<-dplyr::filter(locfile,is_noModSeq_inSubpool==TRUE,is_ModSeq_isomeric_inSubpool==FALSE)

  #flr table
  rsl<-data.frame(score=NULL,total_seq=NULL,true_localization=NULL)
  locfile$max_score<-as.numeric(locfile$max_score)
  for(s in 1:length(cutoff)){
    tmp<-locfile[locfile$max_score>=cutoff[s],]
    rsl[s,"score"]=cutoff[s]
    rsl[s,"total_seq"]<-nrow(tmp)
    rsl[s,"true_localization"]<-sum(tmp$is_ModSeq_inSubpool)
  }
  rsl$file<-fname
  return(rsl)
}

