drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = db, host = host,
                    user = user, password = password)

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


#Izbiršemo podatke kje ne vemo kje se letališče nahaja in spremenimo tip
#POZOR ZAENKRAT JE POTREBNO ROČNO NA BAZI VNESTI KODO ZA IZBRIS \N, DIREKTNO NE VEM ZAKAJ NE DELUJE
dbSendQuery(con, 
            "DELETE from letalske_povezave WHERE idodhodno = '\N'; ")
dbSendQuery(con, 
            "DELETE from letalske_povezave WHERE idprihodno = '\N'; ")
dbSendQuery(con, "ALTER TABLE letalske_povezave ALTER COLUMN idodhodno  TYPE integer USING (idodhodno::integer);"
)
dbSendQuery(con, "ALTER TABLE letalske_povezave ALTER COLUMN idprihodno  TYPE integer USING (idprihodno::integer);"
)


#Dodamo ID letališčem
dbSendQuery(con, "ALTER table letalisca ADD id serial")

dbDisconnect(con)
