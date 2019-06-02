library(markdown)
library(leaflet)
library(dplyr)
navbarPage("Potovanje",
           tabPanel("Poišči svojo destinacijo",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput('mesta',label ='Mesto',choices=NULL,selected = NULL, multiple = FALSE,width="450px"),
                        selectInput('letal',label ='Letališča',choices=NULL,selected = NULL, multiple = FALSE,width="450px")
                      ),
                      
                      mainPanel(tableOutput("destinacije")
                     
                      )
                    )),
           tabPanel("Zemljevid destinacij",
                    leafletOutput("mymap",height = 1000)))


