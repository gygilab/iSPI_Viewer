ui <-
  navbarPage(
    "FLR Viewer for Phosphorylation Site Localization",
    theme = "slp_viewer.css",
    footer = tags$div(
      class = "navbar-header",
      align = "center",
      style = "float:none;background-color:#b4b4b4;bottom:0;height:100px;box-shadow: 0 50vh 0 50vh #b4b4b4;",
      tags$img(height = "30", src = "GL.png"),
      "| FLR Viewer for Phosphorylation Site Localization | Copyright 2022 Gygi Lab & The President and Fellows of Harvard College",
    ),

    ##############Welcome page#####################
    tabPanel(
      "Welcome",
      tags$div(
        class = "container",
        tags$h2("Welcome to the FLR Viewer for Phosphorylation Site Localization!"),
        tags$p("Mass spectrometry-based phosphoproteomics has become indispensable for understanding cellular signaling in complex biological systems. Despite the central role of protein phosphorylation, the field still lacks inexpensive, regenerable, and diverse phosphopeptides with ground truth phosphorylation positions that can serve as gold standards for method development and pipeline evaluation. Here, we present Iterative Synthetically Phosphorylated Isomers (iSPI), a proteome-scale library of human-derived phosphoserine-containing phosphopeptides produced in E. coli using the phosphoserine orthogonal translation system. Because phosphoserine is genetically encoded, the position of phosphorylation is precisely known. Since the library is synthesized in E. coli, phosphopeptide production is scalable and regenerable. We demonstrate the utility of iSPI as a phosphopeptide standard to investigate instrument acquisition methods, to evaluate and optimize phosphorylation site localization algorithms, and to compare performance across data analysis pipelines. As a direct result of iSPI analyses, we present AscorePro, an updated version of the Ascore algorithm that has been specifically optimized for localization of phosphorylation sites in higher energy fragmentation spectra. In addition, we provide the FLR Viewer for Phosphorylation Site Localization, a browser-based tool allowing the community to calculate phosphorylation site false localization rates using their own workflows and analysis pipelines. Thus, iSPI and its associated data constitute a useful, multi-purpose resource for the phosphoproteomics community."),
        tags$br(),
        tags$img(width = "80%", src = "Fig1.PNG", style = "display: block; margin-left: auto; margin-right: auto;"),
        tags$h3("Citations"),
        tags$p("The FLR viewer was built by Jiaming Li."),
        tags$p(
          "For more information see the publication: ",
          tags$a("Placeholder", href = "https://gygi.hms.harvard.edu/")
        ),
        tags$p(
          "Or check out the ",
          tags$a("Gygi Lab Website", href = "https://gygi.hms.harvard.edu/")
        ),
        tags$br(),
        tags$br()
      ),
    ),

    ##############Upload data and view results#####################
    tabPanel(
      "Upload Data and View Results",
      fluid = TRUE,
      tags$head(tags$style(
        HTML(
          ".shiny-notification{position:fixed;top:calc(57%);left:calc(0.5%);width:20em}"
        )
      )),
      fluidRow(
        column(
          3,
          #input tables
          fileInput(
            "locfiles",
            "Choose the Localization File(s) (.txt): ",
            multiple = TRUE,
            accept = ".txt"
          ),
          fileInput(
            "meta",
            "Choose the Annotation File (.txt): ",
            multiple = FALSE,
            accept = ".txt"
          ),
          textInput(
            "phos_symbol",
            "What Symbol Indicates the Phosphorylation Site? e.g.: (ph), # ",
            value = "#"
          ),
          textInput("score_cutoff",
                    "Input Score Cutoff(s): ",
                    value = "0;13;19;30"),
          actionButton("submit", "Submit"),
          br(),
          br(),
          br(),
          ##download button
          span(textOutput("job_done"), style =
                 "color:red"),
          uiOutput("downloadButton_flr"),
        ),
        column(
          9,
          column(
            6,
            #output the locfile sample txt
            uiOutput("locfile_sample_header"),
            tableOutput("locfile_sample"),
            textOutput("instruct_locfile"),
            tags$style(type = "text/css", "#instruct_locfile {white-space: pre-wrap;}"),
          ),
          column(
            5,
            #output the meta sample txt
            uiOutput("meta_sample_header"),
            tableOutput("meta_sample"),
            textOutput("instruct_meta"),
            tags$style(type = "text/css", "#instruct_meta {white-space: pre-wrap;}"),
          ),
        ),
        column(9,
               align = "left",
               br(),
               plotOutput("flr_plot"))
      )
    ),
    #############################download sample tables####################
    tabPanel(
      "Download Samples",
      column(
        6,
        textOutput("download1"),
        tags$head(tags$style(
          "#download1{color: black;font-size: 20px;}"
        )),
        a(
          href = "SampleTables.zip",
          "Download Sample Tables",
          download = NA,
          target = "_blank"
        ),
      ),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
      br(),
    )
  )

