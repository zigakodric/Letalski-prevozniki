library(markdown)
library(leaflet)
library(dplyr)
library(shinythemes)
navbarPage(theme = shinytheme("cerulean"), "Potovanje",
           tabPanel("Poišči svojo destinacijo",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput('drz',label ='Drzava',choices=NULL, multiple = FALSE,width="450px"),
                        
                        selectInput('mesta',label ='Mesto',choices=NULL, multiple = FALSE,width="450px")
                        
                      ),
                      
                      mainPanel(h2("Možne destinacije"),tableOutput("destinacije")
                     
                      )
                    )),
           tabPanel("Zemljevid destinacij",
                    leafletOutput("mymap",height = 1000)),
           tabPanel("Informacije o destinacijah",
                    sidebarLayout(
                      sidebarPanel(
                        sliderInput("tveganja", "Določi stopnjo tveganja", min = 1, max = 4, value = 1, step = 1),
                    

                        selectInput("drzave",label ='Mesto',choices=NULL,selected = "", multiple = FALSE,width="450px"),
                        selectInput("info", label =  "Zanima me", 
                                    choices = c("Transport", "Zdravstvo", "Pravosodje", "Varnost", "Viza", "Splošno"), multiple = TRUE)
                      ),
                      mainPanel(h2("Informacije o destinaciji"),tableOutput("informacije"))
                    ))
           
           
           )


