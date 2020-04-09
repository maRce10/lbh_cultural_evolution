###---make occurrence range data----

fdat <- read.csv("~/Dropbox/Cultural_Evolution/year_range_by_song_type.csv", sep = "," , header = T)
head(fdat)

leks <- c("BR1", "CCE", "CCL", "HC1", "HC2", "LOC", "SAT", "SJA", "SUR", "TR1", "TR2") 
  
for (i in 1:11){
  temp <- data.frame(song = character(length = sum(fdat$lek == leks[i])), min = numeric(length = sum(fdat$lek == leks[i]) ))
  temp$song <- fdat$song.type[which(fdat$lek == leks[i])]
  temp$min <- fdat$year[which(fdat$lek == leks[i])]
  temp$max <- temp$min
  write.table(temp, paste0("~/Dropbox/Cultural_Evolution/RB/", leks[i], "/data/", leks[i], "_taxa.tsv"), 
              quote = F, sep = "\t", row.names = F)
} 

require (ape)