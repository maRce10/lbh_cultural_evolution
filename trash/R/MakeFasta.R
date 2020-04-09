###----Alignment of phenotypic sequence data: CSV to fasta format----------------------
require(seqinr)

dat<-read.csv("~/Dropbox/Cultural_Evolution/segments_by_song_type.csv")
head(dat)

#Are id's unique?
length(dat$song.type) == length(unique(dat$song.type)) #OK

#Seqs to strings
for (i in 3:22){
dat[,i] <- as.character(dat[,i])
}
seqs <- list()
for (i in 1:length(dat$song.type)){
  seqs[[i]] <- paste(dat[i,3:22], collapse = "")
}

#Write fasta file - should we align per lek?
write.fasta(seqs, dat$song.type, file.out = "~/Dropbox/Investigacion/Cultural_Evolution/SongSeqs.fa", open = "w", nbchar = 60, as.string = FALSE)

