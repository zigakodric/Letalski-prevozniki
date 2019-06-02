library(shiny)
library(leaflet)
library(dplyr)
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = db, host = host,
                 user = user, password = password)

server <- function(input, output, session) {
  #Iz baze uvozimo vse možna letališča
  uvoz_mesta <- reactive({
    
    
    dbGetQuery(con, "SELECT  mesto, id from letalisca")
  })
  observe ({
    updateSelectInput(session,"mesta","Mesta",
                      choices = uvoz_mesta()
    )
    
  })
  
  #prikaz mest
  najdi_destinacije <-reactive({
    sql <- "SELECT ime, mesto, idprihodno,idodhodno FROM letalske_povezave 
    INNER JOIN letalisca
    ON letalisca.id = letalske_povezave.idprihodno
    WHERE letalske_povezave.idodhodno = ?id1"
    id <- letalisca["mesto"]
    id_nas <- which(id == "Berlin")+1
    query <- sqlInterpolate(con, sql,id1 = id_nas) #preprecimo sql injectione
    t=dbGetQuery(con,query)
  })
  
  output$destinacije <- renderTable({ #glavna tabela rezultatov
    tabela1=najdi_destinacije()
    tabela1[!duplicated(tabela1),]
  }
  )
#Še po  
  uvoz_letal <- reactive({
    
    
    dbGetQuery(con, "SELECT  ime, id from letalisca")
  })
  observe ({
    updateSelectInput(session,"letal","Letališče",
                      choices = uvoz_letal()
    )
    
  })
  
  #prikaz mest
  najdi_destinacije <-reactive({
    sql <- "SELECT ime, mesto, idprihodno,idodhodno FROM letalske_povezave 
    INNER JOIN letalisca
    ON letalisca.id = letalske_povezave.idprihodno
    WHERE letalske_povezave.idodhodno = ?id1"
    id <- letalisca["mesto"]
    id_nas <- which(id == "London")[3]+1
    query <- sqlInterpolate(con, sql,id1 = id_nas) #preprecimo sql injectione
    t=dbGetQuery(con,query)
  })
  
  output$destinacije <- renderTable({ #glavna tabela rezultatov
    tabela1=najdi_destinacije()
    tabela1[!duplicated(tabela1),]
  }
  )
  #---------------------------------------------------------------------------------------------------
  #ZEMLJEVID
  podatki <- reactive({

    
    dbSendQuery(con, "DROP VIEW IF EXISTS zacasno; ")
    
    sql <- "CREATE VIEW zacasno AS
    SELECT ime, idprihodno,idodhodno FROM letalske_povezave 
    JOIN letalisca
    ON letalisca.id = letalske_povezave.idprihodno
    WHERE letalske_povezave.idodhodno = 340"
    id <- letalisca["mesto"]
    id_nas <- which(id == "Berlin")[2]
    query <- sqlInterpolate(con, sql,id1 = id_nas)
    dbSendQuery(con, query)
    
    koordinate <- dbGetQuery(con, "SELECT x,y, mesto, id FROM letalisca
    JOIN zacasno 
    ON letalisca.id = zacasno.idprihodno")
    koordinate$x <- as.numeric(koordinate$x)
    koordinate$y <- as.numeric(koordinate$y)
    
    x <- koordinate
    x
  })
  
  output$mymap <- renderLeaflet({
    df <- podatki()
    
    m <- leaflet(data = df) %>%
      addTiles() %>%
      addMarkers(lng = ~y,
                 lat = ~x,
                 label = ~mesto
                 )
    m
  })
}
