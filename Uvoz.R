drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)

#Uvoz podatkov

#Letališča
letalisca <- read.csv("let.csv")

#Zbrišemo nepotrebne podatke
ohrani <- c("Ime", "Mesto", "Drzava", "IATA", "ICAO","X","Y")
letalisca[ohrani]

#Zapišemo podatke v tabelo v bazi
#Odstranimo okrajšave
dbSendQuery(con, "DROP TABLE IF EXISTS letalisca; ")
dbWriteTable(con,'letalisca',letalisca, row.names=FALSE)
dbSendQuery(con, "alter table letalisca add id serial")

#Letalske povezave
povezave <- read.csv("povezave.csv")
dbSendQuery(con, "DROP TABLE IF EXISTS letalske_povezave; ")

dbWriteTable(con,'letalske_povezave',povezave, row.names=FALSE)

#Letalske družba

letalske_druzbe <- read.csv("druzbe.csv")

dbSendQuery(con, "DROP TABLE IF EXISTS letalske_druzbe; ")

dbWriteTable(con,'letalske_druzbe',letalske_druzbe, row.names=FALSE)

#Letala
letala <- read.csv("letala.csv")
dbSendQuery(con, "DROP TABLE IF EXISTS letala; ")

dbWriteTable(con,'letala',letala, row.names=FALSE)

#Urejanje podatkov
#Iz baze odstranimo podatke o letalskih družbah, ki ne poslujejo več
dbSendQuery(con, 
            "DELETE from letalske_druzbe
             WHERE operativna = 'N'; "
)

#Izbiršemo podatke kje ne vemo kje se letališče nahaja in spremenimo tip
dbSendQuery(con, 
            "DELETE from letalske_povezave WHERE idodhodno = '\N'; ")
dbSendQuery(con, 
            "DELETE from letalske_povezave WHERE idprihodno = '\N'; ")
dbSendQuery(con, "ALTER TABLE letalske_povezave ALTER COLUMN idodhodno  TYPE integer USING (idodhodno::integer);"
)
dbSendQuery(con, "ALTER TABLE letalske_povezave ALTER COLUMN idprihodno  TYPE integer USING (idprihodno::integer);"
)
#POPRAVIMO
dbSendQuery(con,
            "DELETE from letalske_povezave
            WHERE idodhodno = 'N'")

#Dodamo ID letališčem
dbSendQuery(con, "ALTER table letalisca ADD id serial")

dbDisconnect(con)
