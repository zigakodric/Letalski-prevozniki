server <- function(input, output, session) {
  #Iz baze uvozimo vse možna letališča
  uvoz_imena <- reactive({
    
    
    dbGetQuery(con, "SELECT ime, mesto, id from letalisca")
  })
  observe ({
    updateSelectInput(session,"imena","Izhodno letališče",
                      choices = uvoz_imena()
    )
    
  })
  
  #prikaz destinacij
  najdi_destinacije <-reactive({
    sql <- "SELECT ime, mesto, idprihodno,idodhodno FROM letalske_povezave 
    INNER JOIN letalisca
    ON letalisca.id = letalske_povezave.idprihodno
    WHERE letalske_povezave.idodhodno = ?id1"
    id <- letalisca["mesto"]
    id_nas <- which(id == input$imena)
    query <- sqlInterpolate(con, sql,id1 = id_nas) #preprecimo sql injectione
    t=dbGetQuery(con,query)
  })
  
  output$destinacije <- renderTable({ #glavna tabela rezultatov
    tabela1=najdi_destinacije()
    tabela1
  }
  )
  
  

}
