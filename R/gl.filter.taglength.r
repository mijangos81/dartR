#' Filter loci in a genlight \{adegenet\} object based on sequence tag length
#'
#' SNP datasets generated by DArT typically have sequence tag lengths ranging from 20 to 69 base pairs.
#' 
#' @param x name of the genlight object containing the SNP data [required]
#' @param lower lower threshold value below which loci will be removed [default 20]
#' @param upper upper threshold value above which loci will be removed [default 69]
#' @param verbose verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]
#' @return     Returns a genlight object retaining loci with a sequence tag length in the range specified by the lower and upper threshold.
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})

# Last amended 3-Feb-19

gl.filter.taglength <- function(x, lower=20, upper=69, verbose=2) {

# TIDY UP FILE SPECS

  funname <- match.call()[[1]]

# FLAG SCRIPT START

  if (verbose < 0 | verbose > 5){
    cat("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to 2\n")
    verbose <- 2
  }

  if (verbose > 0) {
    cat("Starting",funname,"\n")
  }

# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  
  if(is.null(x@other$loc.metrics$TrimmedSequence)) {
    cat("  Fatal Error: locus metrics do not include trimmed sequences!\n"); stop("Execution terminated\n")
  }

  # Work around a bug in adegenet if genlight object is created by subsetting
      if (nLoc(x)!=nrow(x@other$loc.metrics)) { stop("The number of rows in the loc.metrics table does not match the number of loci in your genlight object!")  }

  # Set a population if none is specified (such as if the genlight object has been generated manually)
    if (is.null(pop(x)) | is.na(length(pop(x))) | length(pop(x)) <= 0) {
      if (verbose >= 2){ cat("  Population assignments not detected, individuals assigned to a single population labelled 'pop1'\n")}
      pop(x) <- array("pop1",dim = nInd(x))
      pop(x) <- as.factor(pop(x))
    }

  # Check for monomorphic loci
    tmp <- gl.filter.monomorphs(x, verbose=0)
    if ((nLoc(tmp) < nLoc(x)) & verbose >= 2) {cat("  Warning: genlight object contains monomorphic loci\n")}

# FUNCTION SPECIFIC ERROR CHECKING
    
# DO THE JOB
  
  n0 <- nLoc(x)
  if (verbose > 2) {cat("Initial no. of loci =", n0, "\n")}

  tags <- x@other$loc.metrics$TrimmedSequence
  nchar.tags <- nchar(as.character(tags))
  
    # Remove SNP loci with rdepth < threshold
    if (verbose > 1){cat("  Removing loci with taglength <",lower,"and >",upper,"\n")}
    index <- (nchar.tags>=lower & nchar.tags<= upper)
    x2 <- x[, index]
    # Remove the corresponding records from the loci metadata
    x2@other$loc.metrics <- x@other$loc.metrics[index,]
    if (verbose > 2) {cat ("  No. of loci deleted =", (n0-nLoc(x2)),"\n")}
    
  # REPORT A SUMMARY
  if (verbose > 2) {
    cat("Summary of filtered dataset\n")
    cat(paste("  Sequence Tag Length >=",lower,"and Sequence Tag Length <=",upper,"\n"))
    cat(paste("  No. of loci:",nLoc(x2),"\n"))
    cat(paste("  No. of individuals:", nInd(x2),"\n"))
    cat(paste("  No. of populations: ", length(levels(factor(pop(x2)))),"\n"))
  }  
  
# FLAG SCRIPT END

  if (verbose > 0) {
    cat("Completed:",funname,"\n")
  }
    
  #add to history
    nh <- length(x2@other$history)
    x2@other$history[[nh + 1]] <- match.call()
    
  return(x2)
  
}