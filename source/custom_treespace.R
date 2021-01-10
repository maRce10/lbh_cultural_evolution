
# multi_list = a named list of multiphylo objects, names are used for labeling chains
custom_treespace <- function (multi_list, n.points = 100, thinning = 5000, method = "RF", cl = 1){

    # get subset of n.points for each list
    if (!is.infinite(n.points))
    for(y in 1:length(multi_list)) {

      indices <- round(seq(from = 1, to = length(multi_list[[y]]), length.out = n.points), 0)

      # add sample and model tag to each tree
      multi_list[[y]] <- lapply(1:length(multi_list[[y]]), function(x) {
        multi_list[[y]][[x]]$model <- names(multi_list)[y]
        multi_list[[y]][[x]]$sample <- x
        return(multi_list[[y]][[x]])
      })

      multi_list[[y]] <- multi_list[[y]][indices]
    }

  # add sample and model tag to each tree
    for(y in 1:length(multi_list)) {

      multi_list[[y]] <- lapply(1:length(multi_list[[y]]), function(x) {
        multi_list[[y]][[x]]$model <- names(multi_list)[y]
        multi_list[[y]][[x]]$sample <- x
      return(multi_list[[y]][[x]])
        })
    }

  # put trees in a single list
  alltrees <- unlist(multi_list, recursive = FALSE)
  # samples <- sapply(alltrees, "[[", "sample")
  # model <- sapply(alltrees, "[[", "model")

  # get distance
  # d <- try(tree.dist.matrix(alltrees), silent = TRUE)

  # if (is(d, "try-error"))
  # d <- as.matrix(custom_mRF(trees = alltrees, normalize = FALSE, rooted = FALSE))
    d <- as.matrix(topo_dist(trees = alltrees, method = method, cl = cl))

  if (sum(d) == 0) {
    x <- rep(0, length(alltrees))
    y <- rep(0, length(alltrees))
    mds <- data.frame(x = x, y = y)
  } else
  mds <- cmdscale(d, k = 2)

  points <- as.data.frame(mds)
  row.names(points) <- seq(nrow(points))
  names(points) <- c("x", "y")
  points$lek <- substr(colnames(d), 0, 3)
  points$chain <- gsub("[[:digit:]]", "", substr(colnames(d), 5, 100))
  points$sample <- as.numeric(gsub("[^0-9.-]|\\.", "", substr(colnames(d), 5, 100)))
  points$generation <- points$sample * 5000

  return(points)
}

##############################

topo_dist <- function(trees, method = "RF", cl){

  tree_names <- names(trees)

  combs <- t(combn(tree_names, 2))

  dsts <- pbsapply(1:nrow(combs), cl = cl, function(x){

    # extract 2 trees
    t1 <- trees[[combs[x, 1]]]
    t2 <- trees[[combs[x, 2]]]

    d <- try(compare_trees(t1, t2, method))

    if (is(d, "try-error")) return(NA) else return(d)
  })

  # put results in a distance matrix
  mat <- matrix(nrow = length(tree_names), ncol = length(tree_names))
  mat[] <- 0
  colnames(mat) <- rownames(mat) <- tree_names
  mat[lower.tri(mat, diag = FALSE)] <- dsts
  mat <- t(mat)
  mat[lower.tri(mat, diag = FALSE)] <- dsts

  # impute missing values
  # if (anyNA(mat))
  #   mat <- ape::ultrametric(as.dist(mat))

  while(anyNA(mat))
    mat <- mat[-1 * which.max(rowSums(is.na(mat))), -1 * which.max(colSums(is.na(mat))), drop = FALSE]

  return(mat)
}

##############################

compare_trees <- function(t1, t2, method){

  # drop unshared tips
  if (length(c(setdiff(t1$tip.label, t2$tip.label), setdiff(t2$tip.label, t1$tip.label))) > 0){

    common_tips <- intersect(t1$tip.label, t2$tip.label)

    t1 <- drop.tip(t1, setdiff(t1$tip.label, common_tips))

    t2 <- drop.tip(t2, setdiff(t2$tip.label, common_tips))
  }

  # run if both trees have at least 3 tips
  if (all(c(Ntip(t1), Ntip(t2)) > 2)){
  if (method == "RF")
    d <- phangorn::RF.dist(ape::unroot(t1), ape::unroot(t2))

  if (method == "wRF")
    d <- phangorn::wRF.dist(ape::unroot(t1), ape::unroot(t2))

  if (method == "KF")
    d <- phangorn::KF.dist(ape::unroot(t1), ape::unroot(t2))

  if (method == "path")
    d <- phangorn::path.dist(ape::unroot(t1), ape::unroot(t2))
  } else d <- NA
  return(d)
}

###
# custom_mRF <- function(trees, normalize = FALSE, rooted = FALSE)
# {
#   if (!inherits(trees, "multiPhylo"))
#     stop("trees should be an object of class \"multiPhylo\"")
#   trees <- .compressTipLabel(trees)
#   tipLabel <- attr(trees, "TipLabel")
#   nTips <- length(tipLabel)
#   l <- length(trees)
#   RF <- numeric((l * (l - 1))/2)
#   if (rooted & any(!is.rooted(trees))) {
#     warning("some trees were rooted, unrooted all")
#     rooted <- FALSE
#   }
#   if (!rooted) {
#     if (any(is.rooted(trees))) {
#       trees <- unroot(trees)
#     }
#   }
#   if (any(has.singles(trees)))
#     trees <- lapply(trees, collapse.singles)
#   # if (any(!is.binary(trees))) {
#   #   message("Some trees are not binary. Result may not what you expect!")
#   # }
#   Nnodes <- sapply(trees, Nnode)
#   trees <- .uncompressTipLabel(trees)
#   trees <- unclass(trees)
#   xx <- lapply(trees, bipart)
#   if (!rooted)
#     xx <- lapply(xx, SHORTwise, nTips)
#   xx <- lapply(xx, function(x) sapply(x, paste, collapse = "_"))
#   k <- 1
#   for (i in 1:(l - 1)) {
#     tmp <- xx[[i]]
#     for (j in (i + 1):l) {
#       RF[k] <- Nnodes[i] + Nnodes[j] - 2 * sum(fastmatch::fmatch(xx[[j]],
#                                                       tmp, nomatch = 0L) > 0L)
#       if (normalize)
#         RF[k] <- RF[k]/(Nnodes[i] + Nnodes[j] - 2)
#       k <- k + 1
#     }
#   }
#   attr(RF, "Size") <- l
#   if (!is.null(names(trees)))
#     attr(RF, "Labels") <- names(trees)
#   attr(RF, "Diag") <- FALSE
#   attr(RF, "Upper") <- FALSE
#   class(RF) <- "dist"
#   return(RF)
# }
#
# SHORTwise <- function(x, nTips, delete = FALSE) {
#   v <- 1:nTips
#   l <- lengths(x)
#   lv <- floor(nTips / 2)
#   for (i in seq_along(x)) {
#     if (l[i] > lv) {
#       y <- x[[i]]
#       x[[i]] <- v[-y]
#     }
#     if (l[i] == nTips / 2) {
#       y <- x[[i]]
#       if (y[1] != 1)
#         x[[i]] <- v[-y]
#     }
#   }
#   if (any(l == nTips) && delete) {
#     x <- x[l != nTips]
#   }
#   x
# }
#
# bipart <- function(x) {
#   x <- reorder(x, "postorder")
#   nTips <- as.integer(length(x$tip.label))
#   .Call("_phangorn_bipartCPP", PACKAGE = "phangorn", x$edge, nTips)
# }

# methods are: "RF", "wRF", "KF", "path"
# methods as in phangorn::treedist function names

# function to leave only most recent song types (from the last year in the data)
# method = "most_recent_year" for leaving only the tips found in the last year that a lek was sampled (for all fossil models) and "shared" to leave only those tips shared by all trees (a proportion given by "prop.trees")
# tree_prunner <- function(trees, method = "most_recent_year", prop.trees = 0.9){
#
#   library(ape)
#   library(phangorn)
#
#   tl <- unique(unlist(lapply(trees,  function(x) x$tip.label)))
#
#   if (method == "most_recent_year")
#   {
#   # years in tree tips
#   yrs <- as.numeric(substr(start = 8, 12, x = tl))
#
#   # most recent year
#   mryr <- max(yrs)
#
#   # target tips
#   trg.tps <- grep(x = tl, pattern =  mryr, value = TRUE)
#   }
#
#   if (method == "shared")
#   {
#     # tip count
#     tb <- table(unlist(lapply(trees,  function(x) x$tip.label)))
#
#     # those tips found in 90% of the trees
#     trg.tps <- names(tb[tb >= length(trees) * prop.trees])
#   }
#
#   prunned.trees <- lapply(trees, drop.tip, setdiff(tl, trg.tps))
#
#   ntips <- sapply(prunned.trees, Ntip)
#
#   prunned.trees <- prunned.trees[ntips == max(ntips)]
#
#   class(prunned.trees) <- "multiPhylo"
#
#   return(prunned.trees)
# }
