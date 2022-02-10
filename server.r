server<-function(input,output,session){
  secure_server(check_credentials=check_credentials(credentials),timeout=360)
  observe({
    if (is.null(input$shinymanager_where)||(!is.null(input$shinymanager_where)&&input$shinymanager_where %in% "application")){

  values<-reactiveValues()
  values$locfiles<-vector("list")
  values$metafile<-NULL
  values$flr<-NULL

  #read localization files
  observe({
    req(input$locfiles)
    for(f in 1:length(input$locfiles[,1])){
      fpath<-input$locfiles[[f, 'datapath']]
      ext<-tools::file_ext(fpath)
      if(ext != "txt"){
        showNotification(".TXT files only!",type="error",duration=15)
      }else{
        values$locfiles[[f]]<-read.delim(file = fpath,header = T,sep = "\t",quote = "",na="",stringsAsFactors = FALSE)
      }
    }
    tmp_name<-input$locfiles$name
    if(length(values$locfiles)==length(tmp_name)){
      names(values$locfiles)<-gsub("\\.txt","",tmp_name)
    }
  })

  #read meta table
  observe({
    req(input$meta)
    fpath<-input$meta$datapath
    ext<-tools::file_ext(fpath)
    if(ext != "txt"){
      showNotification(".TXT files only!",type="error",duration=15)
    }else{
      values$metafile<-read.table(fpath,header = T,sep = "\t",stringsAsFactors = FALSE,col.names=c("File_Name","Subpool_ID","Key1","Key2","Key3"))
    }
  })

  #submit loc files
  flr<-eventReactive(input$submit,{
    if(input$phos_symbol==""|input$score_cutoff==""){
      showNotification("Input a Symbol!",type="error",duration=15)
      return(NULL)
    }else{
      withProgress(message = 'Calculating...', value = 0, {
        incProgress(1, detail = "")
        tmp_rsl<-vector("list")
        for(f in 1:length(values$locfiles)){
          tmp_rsl[[f]]<-process_indi_locfile(locfile=values$locfiles[[f]],subpool=values$metafile$Subpool_ID[values$metafile$File_Name %in% names(values$locfiles)[f]],phos_symbol=input$phos_symbol,phoslib=phoslib,cutoff=input$score_cutoff,fname=names(values$locfiles)[f])
        }
        tmp_rsl<-do.call(rbind.data.frame,tmp_rsl)
        if(nrow(tmp_rsl)>0){
          tmp_rsl<-dplyr::left_join(tmp_rsl,values$metafile,by=c("file"="File_Name"))
          tmp_rsl$FLR <- 1-tmp_rsl$true_localization/tmp_rsl$total_seq
          values$flr<-tmp_rsl
          "Ready for download!"
        }else{
          return(NULL)
        }
      })
    }
  })


  ###output an example of the loc file and meta file
  output$locfile_sample_header<-renderText({HTML("<b>An example of the localization file:</b>")})
  output$locfile_sample<-renderTable({
    read.delim("www/locfile_sample.txt",header = T,sep = "\t",quote = "",na="",stringsAsFactors = FALSE,check.names = F)
  },align="c",na="")
  output$instruct_locfile<-renderText({
    "1. Two columns.\n2. The first column contains modified peptide sequences. Only sequences with ONE phosphorylated residue will be used. Symbols indicating other modifications are allowed. \n3. The second column contains localization scores."
  })

  output$meta_sample_header<-renderText({HTML('<b>An example of the annotation file:</b>')})
  output$meta_sample<-renderTable({
    read.delim("www/Meta_sample.txt",header = T,sep = "\t",quote = "",na="",stringsAsFactors = FALSE,check.names = F)
  },align="c",na="")
  output$instruct_meta<-renderText({
    "1. Five columns.\n2. The first column contains file names.\n3. The second column contains respective library subpool ID(s).\n4. The third to the fifth columns contain meta info for the files (leave blank if not applicable; the third to the fifth columns will be mapped to colors, columns, and rows in the result plot)."
  })


  #output a job done message
  output$job_done<-renderText({flr()})

  ##download button and save file
  output$downloadButton_flr<-renderUI({
    req(flr())
    if(!is.null(flr())){
      downloadButton("downloadData_flr",label="Download the FLR Table")
    }
  })
  output$downloadData_flr<-downloadHandler(
    filename = "FLR.txt",
    content = function(file) {
      write.table(values$flr, file, row.names = FALSE,na="",quote=F,sep="\t")
    }
  )

  ##make plot
  observe({
    req(flr())
    if(!is.null(flr())){
      tmp_flr<-group_by(select(values$flr,-contains(c("Subpool_ID","file","true_localization"))),score,Key1,Key2,Key3)
      tmp_flr<-summarise(tmp_flr,total_seq=sum(total_seq),FLR=mean(FLR))
      output$flr_plot<-renderPlot({
        if(all(is.na(tmp_flr$Key1))){
          tmp_plot<-ggplot(tmp_flr,aes(x=FLR,y=total_seq,group=file))
        }else{
          tmp_plot<-ggplot(tmp_flr,aes(x=FLR,y=total_seq,color=Key1))
        }
        tmp_plot<-tmp_plot+
          geom_point()+
          geom_text_repel(aes(label=score))+
          geom_line()+
          xlim(0,0.2)+
          ylim(0,NA)+
          facet_grid(Key3~Key2)+
          xlab("False Localization Rate")+
          ylab("#Sequence/Site")+
          theme(legend.title = element_blank())
        return(tmp_plot)
      })
    }
  })


  ##download sample tables
  output$download1<-renderText({"Download Sample Tables"})
}
  }
  )
  }
