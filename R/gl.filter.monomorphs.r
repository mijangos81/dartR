#' @name gl.filter.monomorphs
#' @title Remove monomorphic loci, including those with all NAs
#' 
#' @description
#' This script deletes monomorphic loci from a genlight \{adegenet\} object
#'
#' A DArT dataset will not have monomorphic loci, but they can arise, along with loci that are scored all NA, when populations or individuals are deleted.
#' Retaining monomorphic loci unnecessarily increases the size of the dataset and will affect some calculations.
#' 
#' Note that for SNP data, NAs likely represent null alleles; in tag presence/absence data, NAs represent missing values (presence/absence could not 
#' be reliably scored)
#' 
#' @param x -- name of the input genlight object [required]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, unless specified using gl.set.verbosity]
#' @return A genlight object with monomorphic (and all NA) loci removed
#' 
#' @author Arthur Georges -- Post to \url{https://groups.google.com/d/forum/dartr}
#' @examples
#' # SNP data
#'   result <- gl.filter.monomorphs(testset.gl, verbose=3)
#' # Tag P/A data
#'   result <- gl.filter.monomorphs(testset.gs, verbose=3)
#'  
#' @family filters and filter reports
#' @import utils patchwork
#' @importFrom plyr count
#' @export

gl.filter.monomorphs <- function (x, 
                                  verbose = NULL) {

  # SET VERBOSITY
  verbose <- gl.check.verbosity(verbose)
  
  # FLAG SCRIPT START
  funname <- match.call()[[1]]
  utils.flag.start(func=funname,build="Jackson",v=verbose)
  
  # CHECK DATATYPE 
  datatype <- utils.check.datatype(x,verbose=verbose)
  
# STANDARD ERROR CHECKING
  
  if(class(x)[1]!="genlight") {
    stop(error("Fatal Error: genlight object required!"))
  }
  
# DO THE JOB

  hold <- x
  na.counter <- 0
  loc.list <- array(NA,nLoc(x))

  if (verbose >= 2){
    cat(report("  Identifying monomorphic loci\n"))
  }  
  
  # Tag presence/absence data
  if (datatype=="SilicoDArT"){
    nL <- nLoc(x)
    matrix <- as.matrix(x)
    l.names <- locNames(x)
    for (i in 1:nL){
      row <- matrix[,i] # Row for each locus
      if (all(row == 0, na.rm=TRUE) | all(row == 1, na.rm=TRUE) | all(is.na(row))){
        loc.list[i] <- l.names[i]
        if (all(is.na(row))){
          na.counter = na.counter + 1
        }
      }
    }                          
  } 
  
  # SNP data
  if (datatype=="SNP"){
    nL <- nLoc(x)
    matrix <- as.matrix(x)
    lN <- locNames(x)
    for (i in 1:nL){
      row <- matrix[,i] # Row for each locus
      if (all(row == 0, na.rm=TRUE) | all(row == 2, na.rm=TRUE) | all(is.na(row))){
        loc.list[i] <- lN[i]
        if (all(is.na(row))){
          na.counter = na.counter + 1
        }
      }
    }                          
  } 
  
  # Remove NAs from list of monomorphic loci and loci with all NAs
  loc.list <- loc.list[!is.na(loc.list)]
  
  # remove monomorphic loc and loci with all NAs
  
  if(length(loc.list > 0)){
    if (verbose >= 2){    cat("  Removing monomorphic loci\n")} 
    x <- gl.drop.loc(x,loc.list=loc.list,verbose=0)
  } else {
    if (verbose >= 2){cat("  No monomorphic loci to remove\n")}
  }
  
  # Report results
  if (verbose >= 3) {
    cat("    Original No. of loci:",nLoc(hold),"\n")
    cat("    Monomorphic loci:", nLoc(hold)-nLoc(x)-na.counter,"\n")
    cat("    Loci scored all NA:",na.counter,"\n")
    cat("    No. of loci deleted:",nLoc(hold)-nLoc(x),"\n")
    cat("    No. of loci retained:",nLoc(x),"\n")
    cat("    No. of individuals:",nInd(x),"\n")
    cat("    No. of populations:",nPop(x),"\n")
  }
  
# RESET THE FLAG
  
  x@other$loc.metrics.flags$monomorphs <- TRUE

# ADD TO HISTORY
  nh <- length(x@other$history)
  x@other$history[[nh + 1]] <- match.call()
  
# FLAG SCRIPT END
  if (verbose >= 1){
    cat(report("Completed:",funname,"\n"))
  }  
  
return (x)
}
