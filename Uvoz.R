source("auth.R")
library(RPostgreSQL)
library(dplyr)


drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)
#dodamo pravice
dbSendQuery(con, "GRANT CONNECT ON DATABASE sem2019_zigak TO javnost;")
dbSendQuery(con,"GRANT SELECT ON ALL TABLES IN SCHEMA public TO javnost;")
#Uvoz podatkov

#Letališča
letalisca <- read.csv("let.csv")


#Zapišemo podatke v tabelo v bazi
dbSendQuery(con, "DROP TABLE IF EXISTS letalisca; ")
dbWriteTable(con,'letalisca',letalisca, row.names=FALSE)
dbSendQuery(con, "alter table letalisca add id serial")

#Letalske povezave
povezave <- read.csv("povezave.csv")
dbSendQuery(con, "DROP TABLE IF EXISTS letalske_povezave; ")

dbWriteTable(con,'letalske_povezave',povezave, row.names=FALSE)



#Podatki o destinacijah
pot <- read.csv("pod.csv")

dbSendQuery(con, "DROP TABLE IF EXISTS pot; ")
dbWriteTable(con, 'pot', pot, row.names=FALSE )

#Dodamo ID državam
dbSendQuery(con, "alter table pot add id serial")

#Varnostna tveganja v država
#Ker nisem našel tabele primerne za uvoz sem tveganja prilagodil (tj. določil random število med 1 in 4) 
#kar lahko privede do nelogičnih rezultatov :)
drzave <- pot["geopoliticalarea"]
tveganja <- round( runif(212, 1, 4))
tveg <- cbind(drzave, data.frame(tveganja))
dbSendQuery(con, "DROP TABLE IF EXSITS tveganja; ")

dbWriteTable(con, 'tveganja', tveg, row.names = FALSE)
dbSendQuery(con, "alter table tveganja add id serial ")
dbSendQuery(con,"ALTER TABLE tveganja
RENAME COLUMN id TO idtveg;")
dbSendQuery(con,"ALTER TABLE tveganja
RENAME COLUMN geopoliticalarea TO drzave;")
#Urejanje podatkov


#Izbiršemo podatke kjer ne vemo kje se letališče nahaja in spremenimo tip
dbSendQuery(con, 
            "DELETE from letalske_povezave WHERE idodhodno = '\\N'; ")
dbSendQuery(con, 
            "DELETE from letalske_povezave WHERE idprihodno = '\\N'; ")
dbSendQuery(con, "ALTER TABLE letalske_povezave ALTER COLUMN idodhodno  TYPE integer USING (idodhodno::integer);"
)
dbSendQuery(con, "ALTER TABLE letalske_povezave ALTER COLUMN idprihodno  TYPE integer USING (idprihodno::integer);"
)

#Ustvarimo pogled
#vseh povezav
dbSendQuery(con, sql <- "CREATE VIEW vse_povezave AS
    SELECT ime, idprihodno,idodhodno FROM letalske_povezave 
            JOIN letalisca
            ON letalisca.id = letalske_povezave.idprihodno")

#za tveganja
dbSendQuery(con, "CREATE VIEW tveg AS SELECT * FROM tveganja INNER JOIN pot ON pot.id = tveganja.idtveg")
dbDisconnect(con)
