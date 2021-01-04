
fi <- file.info(list.files(recursive = TRUE, full.names = TRUE))

fi$size

fi <- fi[order(-fi$size), ]

head(fi)

file_size <- sapply(fi$size, function(x) utils:::format.object_size(x, "Mb"))

file_size_df <- data.frame(file.path = rownames(fi), file_size_Mb = as.numeric(gsub(" Mb","", file_size)))

file_size_df[file_size_df$file_size_Mb > 99, ]

gitignore <- readLines(".gitignore")

big_files <- file_size_df$file.path[file_size_df$file_size_Mb > 99]

big_files <- gsub("^./", "", big_files)

big_files

gitignore2 <- unique(c(gitignore, big_files))


gitignore2 <- gitignore2[gitignore2 != ""]

writeLines(text = gitignore2, con = ".gitignore")
