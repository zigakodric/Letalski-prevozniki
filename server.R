library(RPostgreSQL)
library(shiny)
library(leaflet)
library(dplyr)
source("auth_public.R")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = db, host = host,
                 user = user, password = password)

server <- function(input, output, session) {
  session$onSessionEnded(function() {
    
    dbDisconnect(con)
    
  })
  

  #Najprej iz baze uvozimo seznam vseh možnih držav
  
  uvoz_sezdr <- reactive({ 

    g <- dbGetQuery(con, "SELECT drzava, id FROM letalisca ORDER BY drzava")

    })
  
  observe ({
    updateSelectInput(session,"drz","Država",
                      choices = uvoz_sezdr()[,1]
    )
    
  })
  
  uvoz_mesta <- reactive({
    validate(need(input$drz != "", "Mesto ni podano!"))
    
    sql <- "SELECT DISTINCT mesto, id FROM letalisca
                  WHERE drzava = ?dr"
    query <- sqlInterpolate(con, sql, dr = input$drz)
    t <- dbGetQuery(con, query)
    setNames(t[,2], t[,1])
    

    
  })
  
  observe ({
    updateSelectInput(session,"mesta","Mesta",
                      choices = uvoz_mesta()
    )
    
  })


  najdi_destinacije <-reactive({

    validate(need(input$mesta != "", "Mesto ni podano!"))
    sql <- "SELECT ime, mesto, drzava, idprihodno,idodhodno FROM letalske_povezave 
    INNER JOIN letalisca
    ON letalisca.id = letalske_povezave.idprihodno
    WHERE letalske_povezave.idodhodno = ?id1"
    query <- sqlInterpolate(con, sql,id1 = input$mesta) #preprecimo sql injectione in izberemo prvo letališče v mestu
    t=dbGetQuery(con,query)

    
  })

  
  output$destinacije <- renderTable({ #glavna tabela rezultatov
    tabela1 <- najdi_destinacije()
    validate(need(nrow(tabela1) != 0, "Iz tega letališča ni povezav!"))

    tabela1[!duplicated(tabela1),]
    tabela1$idprihodno = NULL
    tabela1$idodhodno = NULL
    colnames(tabela1) <- c("Ime letališča", "Mesto", "Država")
    tabela1
    })



  #---------------------------------------------------------------------------------------------------
  #ZEMLJEVID
  podatki <- reactive({

    

  
    

    
    sql <- "SELECT x,y, mesto, id FROM letalisca
                             JOIN vse_povezave 
                             ON letalisca.id = vse_povezave.idprihodno
                             WHERE vse_povezave.idodhodno = ?id1"
    query <- sqlInterpolate(con, sql,id1 = input$mesta)
    koordinate <- dbGetQuery(con, query)
    validate(need(nrow(koordinate) != 0, "Iz tega letališča ni povezav!"))
    

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


#------------------------------------------------------------------------------------------------------
#Tretji zavihek
#Uvoz seznama držav glede na tveganja, ki ga izberemo
  uvoz_drzave <- reactive({

    sql <- "SELECT  geopoliticalarea, id from tveg WHERE tveganja <= ?tvegid"
    query <- sqlInterpolate(con, sql,tvegid = input$tveganja)
  
    t <- dbGetQuery(con, query)
    setNames(t[[2]], t[[1]])
    
  })
  
  observe ({
    updateSelectInput(session,"drzave","Država",
                      choices = uvoz_drzave()
    )
    
  })
  
  #Pošiščemo informacije
  najdi_informacije <-reactive({

  
    sql_tra <- "SELECT travel_transportation FROM pot 
                          WHERE id = ?drzava_id"
    sql_zdr <-  "SELECT health FROM pot WHERE id = ?drzava_id"
    sql_zak <- "SELECT local_laws_and_special_circumstances FROM pot WHERE id = ?drzava_id"
    sql_var <- "SELECT safety_and_security FROM pot WHERE id = ?drzava_id"
    sql_viz <- "SELECT entry_exit_requirements FROM pot WHERE id = ?drzava_id"
    sql_spl <- "SELECT destination_description FROM pot WHERE id = ?drzava_id"


    drzave = input$drzave
    izbira <- c("Transport", "Zdravstvo", "Pravosodje", "Varnost", "Viza", "Splošno")
    k <- c()
    info <- input$info
    sql_stavki <- c(sql_tra, sql_zdr,sql_zak,sql_var, sql_viz,sql_spl)
    validate(need((length(info)) != 0, "Izberi informacije"))
    
    for (i in 1:length(info)){
      
      indeks_stavek <- match(info[i],izbira)
      query <- sqlInterpolate(con, sql_stavki[indeks_stavek],drzava_id = drzave)
      k[i] <- dbGetQuery(con, query)
      
    }
    informacije <- matrix(k, nrow = 1, length(k))
    colnames(informacije) <-input$info
    informacije
    


    })
  
  
  output$informacije <- renderTable({ #glavna tabela rezultatov}

    tabela1=najdi_informacije()
  }, sanitize.text.function = function(x) x)
  #------------------------------------------------------------------------------------------------------------------------------
}  

