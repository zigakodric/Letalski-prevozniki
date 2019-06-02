library(markdown)

navbarPage("Potovanje",
           tabPanel("Poišči svojo destinacijo",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput('imena',label ='izhodno',choices=NULL,selected = NULL, multiple = FALSE,width="450px"),
                        selectInput('imena',label ='destinacija',choices=NULL,selected = NULL, multiple = FALSE,width="450px")
                      )
                      
                      ,
                      
                      
                      
                      
                      mainPanel(tableOutput("destinacije")
                     
                      )
                    )))


