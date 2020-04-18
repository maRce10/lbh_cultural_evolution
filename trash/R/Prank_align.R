
filepath <- "~/Dropbox/Cultural_Evolution/Mafft_align/"
prefix <- "SongSeqs_"
leks <- c("BR1", "CCE", "CCL", "HC1", "HC2", "LOC", "SAT", "SJA", "SUR", "TR1", "TR2")
suffix <- ".fa"
prankpath <-"~/Dropbox/Cultural_Evolution/Prank_align/"

for (i in 1:length(leks)){
  fname <-paste0(filepath, prefix, leks[i], suffix)
  dat <- readLines(fname)
  dat <- gsub(pattern = "f", replacement = "C", x = dat) # trill to pyrimidine
  dat <- gsub(pattern = "s", replacement = "T", x = dat) # trill to pyrimidine
  dat <- gsub(pattern = "m", replacement = "Y", x = dat) # medium trill treated as ambiguous between fast and slow
  dat <- gsub(pattern = "u", replacement = "A", x = dat) # tone to purine
  dat <- gsub(pattern = "d", replacement = "G", x = dat) # tone to purine
  dat <- gsub(pattern = "p", replacement = "R", x = dat) # flat tone treated as ambiguous between upwards and downwards
  write(x = dat, file = paste0(prankpath, "Prank_",leks[i], suffix))
}

setwd("~/Dropbox/Cultural_Evolution/Prank_align/")
for (i in 1:length(leks)){
  system(paste0("prank -d=", "Prank_",leks[i], suffix, " -o=", "Prank_",leks[i], " -iterate=100 -kappa=2"))
}

