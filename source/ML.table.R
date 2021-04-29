#Here we summarize marginal likelihood estimation under two alternative clock models: a fixed global model and a relaxed uncorrelated clock with branch rates drawn from an exponential prior. We used ML approximation to determine which clock model has a better fit to the song data.

#First, load the packages that we will need.
x <-
  c(
    "tidyr",
    "ggplot2",
    "viridis",
    "coda",
    "kableExtra"
  )

lapply(x, function(y) {
  # check if installed, if not install
  if (!y %in% installed.packages()[, "Package"])
    install.packages(y)
  
  # load package
  try(require(y, character.only = T), silent = T)
})

#And create some useful variables
# how many replicates of ML approximation
n <- 3

# path to files
fp <- "../output/revbayes/stdout/" 

# colour scale
aln_cols <- viridis(3,direction = -1)
aln_labs <- c("MAFFT-agnostic", "MAFFT-optimal", "PRANK-TN93")

#Read ML estimates
# all dataset files are the same, we can read just one
m <- read.table(file = paste0(fp, "datasetR1.txt"), header = F)

# read in stepping stone estimates
for (i in 1:n) {
  tmp <- read.table(file = paste0(fp, "SteppingStoneR", i , ".txt"), header = F, sep = ",")
  assign(paste0("ss.r", i), tmp)
}

# make a df with all replicates
m.ml <- m
for (i in 1:n) {
  m.ml <- cbind(m.ml, eval(parse(text = paste0("ss.r", i))))
}
colnames(m.ml) <- c("Model", paste0("ss",c(1:n)))

# every once in a while a run fails and has to be repeated. Mark the runs that failed
for(i in 1:n) {
  for (j in 1:nrow(m.ml)) {
    if (grepl(pattern = "This typically refers",
              x =  as.character(m.ml[j, i + 1]),
              fixed =  TRUE)) {
      m.ml[j, i + 1] <- "Repeat"
    }
    if (grepl(pattern = "Problem processing",
              x =  m.ml[j, i + 1],
              fixed =  TRUE)) {
      m.ml[j, i + 1] <- "Repeat"
    }
    if (grepl(pattern = "Could not open",
              x =  m.ml[j, i + 1],
              fixed =  TRUE)) {
      m.ml[j, i + 1] <- NA
    }
  }
}

#Read in repeats of failed approximations and complete df
# read in model names and ML values
m.rep<- read.table(file =paste0(fp, "datasetRepeats.txt"), header = F)
ss.rep <- read.table(file = paste0(fp, "SteppingStoneRepeat.txt"), header = F, sep = ",")

# make a repeat df
m.ml.rep <-cbind(m.rep, ss.rep)
colnames(m.ml.rep) <- c("Model", "ss")

# match name format
m.ml.rep$Model <- gsub(pattern = "_", replacement = ".", x = m.ml.rep$Model)
m.ml.rep$Model <- gsub(pattern = ".global", replacement = "._global", x = m.ml.rep$Model)
m.ml.rep$Model <- gsub(pattern = ".Uexp", replacement = "._Uexp", x = m.ml.rep$Model)

# replace "repeat" for ML values
for (i in 1:nrow(m.ml)) {
  for (j in 1:nrow(m.ml.rep)) {
    for (k in 1:n) {
      if (m.ml$Model[i] == m.ml.rep$Model[j] &
          m.ml[i, k + 1] == "Repeat") {
        m.ml[i, k + 1] <-  m.ml.rep$ss[j]
      }
    }
  }
}

for (k in 2:(n+1)) {
  m.ml[,k] <- as.numeric(m.ml[,k])}

#Make the final ML table
# remove "." from alignment name and no fossil sampling
m.ml$Model <- gsub(pattern = "all.equal", replacement = "allequal", x = m.ml$Model )
m.ml$Model <- gsub(pattern = "no.fossil", replacement = "nofossil.fullprocess", x = m.ml$Model )

# split name into columns
m.ml <- m.ml %>% separate(Model, c("Lek", "Align", "Record", "Sampling", "Clock"))

# long to wide and rearrange
m.ml <-
  pivot_wider(
    data = m.ml,
    names_from = Clock,
    values_from =  paste0("ss", c(1:n))
  )

m.ml <-
  m.ml[, c(
    "Lek",
    "Align",
    "Record",
    "Sampling",
    paste0("ss", c(1:n), "_global"),
    paste0("ss", c(1:n), "_Uexp")
  )]

m.ml  %>%
  kbl() %>%
  kable_minimal()


#Plot results
# make columns for the difference between the fixed and relaxed clocks in each replicate
for (i in 1:n){
  temp <- (m.ml[,(4+i+n)] - m.ml[,(4+i)])
  m.ml <- cbind(m.ml, diff = temp)
}
colnames(m.ml)[(4+2*n+1):(4+3*n)] <- paste0("ss", seq(1:n), "_diff")


# make long data frame
ml.long <- m.ml[,-grep(pattern = "global|Uexp", x= colnames(m.ml))]
ml.long <-
  pivot_longer(data = ml.long,
               cols = paste0("ss", c(1:n), "_diff"),
               names_to = "run")

# reorder leks
ml.long$Lek <-  factor(ml.long$Lek, levels=c('BR1','TR1','CCE','HC1', 'SUR'))

# new facet label names for fossil record
ml.long$Record <-  factor(ml.long$Record, levels=c('old', 'new', 'nofossil'))

Record.labs <- c("Including oldest records", "Recent records only", "No historical records")
names(Record.labs) <- c( "old", "new", "nofossil")

# plot
ML.plot <-
  ggplot(data = ml.long, aes(
    x = Sampling,
    y = value,
    colour = Align,
    shape = Sampling
  )) +
  geom_jitter(size = 3,
              alpha = 0.7,
              width = 0.2) +
  geom_hline(yintercept = 2, colour = "grey60", lty = 2) +
  facet_grid(Record ~ Lek,
             scales = "fixed",
             labeller = labeller(Record = Record.labs)) +
  theme_light(base_size = 12) +
  labs(y = "Difference in marginal likelihood \nbetween clock models (relaxed - fixed)", colour = "Alignment", x = "Sampling of historical records") +
  scale_shape_discrete(guide = FALSE) +
  scale_colour_manual(
    values = aln_cols,
    labels = aln_labs) +
  scale_x_discrete(labels = c("all", "earliest", "none"))

ML.plot

