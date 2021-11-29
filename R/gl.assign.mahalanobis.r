#' @name gl.assign.mahalanobis
#' @title Assign an individual of unknown provenance to population based on PCA
#' @description
#' This script assigns an individual of unknown provenance to one or more target
#' populations based on the unknown individual's proximity to population centroids;
#' proximity is estimated using Mahalanobis Distance. 
#'
#' The following process is followed:
#' \enumerate{
#' \item An ordination is undertaken on the populations to again yield a
#' series of orthogonal (independent) axes.
#' \item A workable subset of dimensions is chosen, normally equal to the number
#'  of dimensions with substantive eigenvalues.
#' \item The Mahalobalis Distance is calculated for the unknown against each
#' population and probability of membership of each population is calculated.
#' The assignment probabilities are listed in support of a decision.
#' }
#' @details
#' There are three considerations to assignment. First, consider only those
#' populations for which the unknown has no private alleles. Private alleles are
#' an indication that the unknown does not belong to a target population
#' (provided that the sample size is adequate, say >=10). This can be evaluated
#'  with gl.assign.pa().
#'
#' A next step is to consider the PCoA plot for populations where no private
#' alleles have been detected. The position of the unknown in relation to the
#' confidence ellipses is plotted by this script as a basis for narrowing down
#' the list of putative source populations. 
#' 
#' Note, this plot is
#' considering only the top two dimensions of the ordination, and so an unknown
#' lying outside the confidence ellipse can be interpreted as it lying outside
#' the confidence envelope. However, if the unknown lies inside the confidence
#' ellipse in two dimensions, then it may still lie outside the confidence
#' envelope. Thus this second step is good for eliminating populations from
#' consideration, but does not provide confidence in assignment.
#'
#' The third step (delivered by this script) is to consider the assignment probabilities based on 
#' the squared Generalised Linear Distance (Mahalanobis distance) of
#' the unknown from the centroid for each population, then to consider the
#' probability associated with its quantile using the Chisquare approximation. 
#' In effect, this index takes into account position of the unknown in
#' relation to the confidence envelope in all selected dimensions of the
#' ordination. The larger the assignment probability, the greater the confidence in the
#' assignment. 
#' 
#' If the unknown individual is an extreme outlier, say at less than 0.001 probability
#' of population membership, then the associated population can be eliminated from
#' further consideration.
#'
#' Each of these above approaches provides evidence, none are 100% definitive. They
#' need to be interpreted cautiously.
#'
#' @param x Name of the input genlight object [required].
#' @param unknown Identity label of the focal individual whose provenance is
#' unknown [required].
#' @param plevel Probability level for bounding ellipses in the PCoA plot
#' [default 1- 0.001].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log; 3, progress and results summary; 5, full report
#' [default 2 or as specified using gl.set.verbosity].
#'
#' @return A data frame with the results of the assignment analysis. 
#'
#' @importFrom stats dnorm qnorm
#' @export
#'
#' @author Custodian: Arthur Georges --
#' Post to \url{https://groups.google.com/d/forum/dartr}
#'
#' @examples Test run with a focal individual from the Macleay River (EmmacMaclGeor) 
#' x <- gl.assign.pa(testset.gl, unknown='UC_01044', nmin=10, threshold=1,verbose=3) 
#' x <- gl.assign.pca(x, unknown='UC_01044', plevel=0.95, verbose=3)
#' df <- gl.assign.mahalanobis(x, unknown='UC_01044', verbose=3)

gl.assign.mahalanobis <- function(x,
                                  plevel=1-0.001,
                                  unknown,
                                  verbose = NULL) {
    # SET VERBOSITY
    verbose <- gl.check.verbosity(verbose)
    
    # FLAG SCRIPT START
    funname <- match.call()[[1]]
    utils.flag.start(func = funname,
                     build = "Jody",
                     verbosity = verbose)
    
    # CHECK PACKAGES
    # pkg <- "SIBER"
    # if (!(requireNamespace(pkg, quietly = TRUE))) {
    #     stop(error(
    #         "Package",
    #         pkg,
    #         " needed for this function to work. Please install it."
    #     ))
    # }
    
    # CHECK DATATYPE
    datatype <- utils.check.datatype(x, verbose = 0)
    if (nPop(x) < 2) {
        stop(
            error(
                "Fatal Error: Only one population, including the unknown, no putative source"
            )
        )
    }
    
    # FUNCTION SPECIFIC ERROR CHECKING
    
    if (!(unknown %in% indNames(x))) {
        stop(
            error(
                "Fatal Error: Unknown must be listed among the individuals in the genlight object!\n"
            )
        )
    }
    
    if (plevel > 1 || plevel < 0) {
        cat(warn(
            "  Warning: Value of plevel must be between 0 and 1, set to 0.999\n"
        ))
        plevel <- 0.999
    }
    
    if (nLoc(x) < nPop(x)) {
        stop(error(
            "Fatal Error: Number of loci less than number of populations"
        ))
    }
    
    # DO THE JOB
    vec <- as.vector(pop(x))
    vec[indNames(x) == unknown] <- "unknown"
    pop(x) <- as.factor(vec)
    
    # Run the pcoa 
    hard.limit <- 8
    if (nInd(x) < 2) {
        df <- NULL
    } else {
        pcoa <- gl.pcoa(x,nfactors=hard.limit,verbose=0)
        suppressWarnings(suppressMessages(gl.pcoa.plot(pcoa,x,ellipse=TRUE,plevel=plevel)))

        # Determine the number of dimensions for confidence envelope (the ordination and dimension reduction) From the eigenvalue
        # distribution
        s <- sum(pcoa$eig)
        e <- round(pcoa$eig * 100 / s, 1)
        e <- e[e > mean(e)]
        first.est <- length(e)
        # From the number of populations, including the unknown sec.est <- nPop(x)
        
        # cat(' Number of populations, including the unknown:',sec.est,'\n')
        if (verbose >= 2) {
            cat(
                report(
                    "  Number of dimensions with substantial eigenvalues:",
                    first.est,
                    ". Hardwired limit",
                    hard.limit,
                    "\n"
                )
            )
            cat(report("    Selecting the smallest of the two\n"))
        }
        dim <- min(first.est, hard.limit)
        if (verbose >= 2) {
            cat(report("    Dimension of confidence envelope set at", dim, "\n"))
        }
        pcoa$scores <- pcoa$scores[, 1:dim]
        
        # Add population names to the scores
        c <-
            data.frame(cbind(pcoa$scores, as.character(pop(x))), stringsAsFactors = FALSE)
        colnames(c)[dim + 1] <- "pop"
        
        # Create a set of data without the unknown
        clouds <- c[c[, "pop"] != "unknown",]
        Unknown <- c[c[, "pop"] == "unknown",]
        # Unknown[1:dim] <- as.numeric(Unknown[1:dim])
        
        # 
        # 
        # if (verbose >= 3) {
        #     cat(
        #         "  Likelihood Index for assignment of unknown",
        #         unknown,
        #         "to putative source populations\n"
        #     )
        # }
        
        # For each population
        p <- as.factor(unique(clouds[, "pop"]))
        for (i in 1:length(levels(p))) {
            # Pull out population i
            m <- clouds[clouds[, "pop"] == levels(p)[i],]
            # Discard the population labels
            m <- m[, 1:dim]
            hold <- row.names(m)
            row.names(m) <- NULL
            Unknown <- Unknown[1:dim]
            row.names(Unknown) <- NULL
            # Convert to numeric, and reformat as a matrix
            n <- as.matrix(sapply(m, as.numeric))
            Unknown <- as.numeric(Unknown)
            # Calculate statistics for the data without the unknown
            means <- colMeans(n)
            covariance <- cov(n)
            # Add back in the unknown
            all <- rbind(n,Unknown)
            # Calculate Mahalanobis Distances
            D <- mahalanobis(all, means, covariance, toll=1e-20)
            names(D) <- c(hold,"unknown")
            # Calculate the associated probabilities
            pval <- (pchisq(D, df=length(d)-1, lower.tail=FALSE))
            # Is the result non-significant, then assign=yes
            if (pval["unknown"] >= 1-plevel) {
                assign <- "yes"
            } else {
                assign="no"
            }
            # Create a dataframe to hold the results
            if(i==1){
              df <- data.frame(unknown=NA,pop=NA,MahalD=NA,pval=NA,critval=NA,assign="NA")
            }
            # Add a row
            df[i,1] <- unknown
            df[i,2] <- levels(p)[i]
            df[i,3] <- D["unknown"]
            df[i,4] <- pval["unknown"]
            df[i,5] <- 1 - plevel
            df[i,6] <- assign
        }
        # Order the dataframe in descending order on pval
        df <- df[order(df$pval,decreasing=TRUE),]
        # Display
        if (verbose >= 3) {
            print(df)
        }
        # Extract the best match, and report
        best <- as.character(df[df$assign == "yes"][1,1])
       
        if (verbose >= 3) {
            cat(
                report(
                    "  Best assignment is the population with the larges probability of assignment, in this case",
                    best,
                    "\n"
                )
            )
        }
    }
    
    # FLAG SCRIPT END
    
    if (verbose > 0) {
        cat(report("Completed:", funname, "\n"))
    }
    
    return(df)
}