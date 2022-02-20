#' @name gl.pcoa.plot
#' @title Bivariate or trivariate plot of the results of an ordination generated
#' using gl.pcoa()
#' @description
#' This script takes output from the ordination generated by gl.pcoa() and plots
#' the individuals classified by population.
#' @details
#' The factor scores are taken from the output of gl.pcoa() and the population
#' assignments are taken from from the original data file. In the bivariate
#' plots, the specimens are shown optionally with adjacent labels and enclosing
#' ellipses. Population labels on the plot are shuffled so as not to overlap
#' (using package \{directlabels\}).
#' This can be a bit clunky, as the labels may be some distance from the points
#' to which they refer, but it provides the opportunity for moving labels around
#'  using graphics software (e.g. Adobe Illustrator).
#'
#' 3D plotting is activated by specifying a zaxis.
#'
#' Any pair or trio of axes can be specified from the ordination, provided they
#' are within the range of the nfactors value provided to gl.pcoa().
#' In the 2D plots, axes can be scaled to represent the proportion of variation
#' explained. In any case, the proportion of variation explained by each axis is
#' provided in the axis label.
#'
#' Colors and shapes of the points can be altered by passing a vector of shapes
#' and/or a vector of colors. These vectors can be created with
#' gl.select.shapes() and gl.select.colors() and passed to this script using the
#'  pt.shapes and pt.colors parameters.
#'
#' Points displayed in the ordination can be identified if the option
#'  interactive=TRUE is chosen, in which case the resultant plot is ggplotly()
#'  friendly. Identification of points is by moving the mouse over them. Refer
#'  to the plotly package for further information.
#' The interactive option is automatically enabled for 3D plotting.
#'
#' @param glPca Name of the PCA or PCoA object containing the factor scores and
#' eigenvalues [required].
#' @param x Name of the genlight object or fd object containing the SNP
#' genotypes or Tag P/A (SilicoDArT) genotypes or the Distance Matrix used to
#' generate the ordination [required].
#' @param scale If TRUE, scale the x and y axes in proportion to \% variation
#' explained [default FALSE].
#' @param ellipse If TRUE, display ellipses to encapsulate points for each
#'  population [default FALSE].
#' @param plevel Value of the percentile for the ellipse to encapsulate points
#' for each population [default 0.95].
#' @param pop.labels How labels will be added to the plot
#' ['none'|'pop'|'legend', default = 'pop'].
#' @param hadjust Horizontal adjustment of label position in 2D plots
#' [default 1.5].
#' @param vadjust Vertical adjustment of label position in 2D plots [default 1].
#' @param interactive If TRUE then the populations are plotted without labels,
#' mouse-over to identify points [default FALSE].
#' @param as.pop Assign another metric to represent populations for the plot
#' [default NULL].
#' @param xaxis Identify the x axis from those available in the ordination
#'  (xaxis <= nfactors) [default 1].
#' @param yaxis Identify the y axis from those available in the ordination
#' (yaxis <= nfactors) [default 2].
#' @param zaxis Identify the z axis from those available in the ordination for a
#' 3D plot (zaxis <= nfactors) [default NULL].
#' @param pt.size Specify the size of the displayed points [default 2].
#' @param pt.colors Optionally provide a vector of nPop colors
#' (run gl.select.colors() for color options) [default NULL].
#' @param pt.shapes Optionally provide a vector of nPop shapes
#'  (run gl.select.shapes() for shape options) [default NULL].
#' @param label.size Specify the size of the point labels [default 1].
#' @param axis.label.size Specify the size of the displayed axis labels
#' [default 1.5].
#' @param save2tmp If TRUE, saves any ggplots and listings to the session
#' temporary directory (tempdir) [default FALSE].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log; 3, progress and results summary; 5, full report
#'  [default 2 or as specified using gl.set.verbosity].
#'
#' @return NULL
#'
#' @author Custodian: Arthur Georges -- Post to
#'  \url{https://groups.google.com/d/forum/dartr}
#'
#' @examples
#' # SET UP DATASET
#' gl <- testset.gl
#' levels(pop(gl))<-c(rep('Coast',5),rep('Cooper',3),rep('Coast',5),
#' rep('MDB',8),rep('Coast',7),'Em.subglobosa','Em.victoriae')
#' # RUN PCA
#' pca<-gl.pcoa(gl,nfactors=5)
#' # VARIOUS EXAMPLES
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, plevel=0.95, pop.labels='pop', 
#' axis.label.size=1, hadjust=1.5,vadjust=1)
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, plevel=0.99, pop.labels='legend', 
#' axis.label.size=1)
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, plevel=0.99, pop.labels='legend', 
#' axis.label.size=1.5,scale=TRUE)
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, axis.label.size=1.2, xaxis=1, yaxis=3, 
#' scale=TRUE)
#' gl.pcoa.plot(pca, gl, pop.labels='none',scale=TRUE)
#' gl.pcoa.plot(pca, gl, axis.label.size=1.2, interactive=TRUE)
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, plevel=0.99, xaxis=1, yaxis=2, zaxis=3)
#' # color AND SHAPE ADJUSTMENTS
#' shp <- gl.select.shapes(select=c(16,17,17,0,2))
#' col <- gl.select.colors(library='brewer',palette='Spectral',ncolors=11,
#' select=c(1,9,3,11,11))
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, plevel=0.95, pop.labels='pop', 
#' pt.colors=col, pt.shapes=shp, axis.label.size=1, hadjust=1.5,vadjust=1)
#' gl.pcoa.plot(pca, gl, ellipse=TRUE, plevel=0.99, pop.labels='legend',
#'  pt.colors=col, pt.shapes=shp, axis.label.size=1)
#'
#' @seealso \code{\link{gl.pcoa}}
#' @family Exploration/visualisation functions
#' @rawNamespace import(data.table, except = c(melt,dcast))
#' @export

gl.pcoa.plot <- function(glPca,
                         x,
                         scale = FALSE,
                         ellipse = FALSE,
                         plevel = 0.95,
                         pop.labels = "pop",
                         interactive = FALSE,
                         as.pop = NULL,
                         hadjust = 1.5,
                         vadjust = 1,
                         xaxis = 1,
                         yaxis = 2,
                         zaxis = NULL,
                         pt.size = 2,
                         pt.colors = NULL,
                         pt.shapes = NULL,
                         label.size = 1,
                         axis.label.size = 1.5,
                         save2tmp = FALSE,
                         verbose = NULL) {
    
    hold_x <- x
    hold_glPca <- glPca
    
    # SET VERBOSITY
    verbose <- gl.check.verbosity(verbose)
    
    # FLAG SCRIPT START
    funname <- match.call()[[1]]
    utils.flag.start(func = funname,
                     build = "Jody",
                     verbosity = verbose)
    
    # CHECK DATATYPE
    datatype1 <-
        utils.check.datatype(glPca, accept = c("glPca","list"), verbose = verbose)
    datatype2 <-
        utils.check.datatype(x,
                             accept = c("SNP", "SilicoDArT", "fd", "dist","list"),
                             verbose = verbose)
    
    # SCRIPT SPECIFIC ERROR CHECKING
    
    if (interactive | !is.null(zaxis)) {
        pkg <- "plotly"
        if (!(requireNamespace(pkg, quietly = TRUE))) {
            stop(
                error(
                    "Package ",
                    pkg,
                    " needed for this function to work. Please install it."
                )
            )
        }
    }
    
    if (datatype1=="list") {
        pkg <- "gganimate"
        if (!(requireNamespace(pkg, quietly = TRUE))) {
            stop(
                error(
                    "Package ",
                    pkg,
                    " needed for this function to work. Please install it."
                )
            )
        }
        pkg <- "tibble"
        if (!(requireNamespace(pkg, quietly = TRUE))) {
            stop(
                error(
                    "Package ",
                    pkg,
                    " needed for this function to work. Please install it."
                )
            )
        }
        x <- x[[1]]
        glPca <- glPca[[1]]
    }
    
    if (pop.labels != "none" &&
        pop.labels != "ind" &&
        pop.labels != "pop" && pop.labels != "legend") {
        cat(
            warn(
                "  Warning: Parameter 'pop.labels' must be one of none|ind|pop|legend, set to 'pop'\n"
            )
        )
        pop.labels <- "pop"
    }
    if (plevel < 0 | plevel > 1) {
        cat(warn(
            "  Warning: Parameter 'plevel' must fall between 0 and 1, set to 0.95\n"
        ))
        plevel <- 0.95
    }
    if (hadjust < 0 | hadjust > 3) {
        cat(warn(
            "  Warning: Parameter 'hadjust' must fall between 0 and 3, set to 1.5\n"
        ))
        hadjust <- 1.5
    }
    if (vadjust < 0 | hadjust > 3) {
        cat(warn(
            "  Warning: Parameter 'vadjust' must fall between 0 and 3, set to 1.5\n"
        ))
        vadjust <- 1.5
    }
    if (xaxis < 1 | xaxis > ncol(glPca$scores)) {
        cat(
            warn(
                "  Warning: X-axis must be specified to lie between 1 and the number of retained dimensions of the ordination",
                ncol(glPca$scores),
                "; set to 1\n"
            )
        )
        xaxis <- 1
    }
    if (yaxis < 1 | yaxis > ncol(glPca$scores)) {
        cat(
            warn(
                "  Warning: Y-axis must be specified to lie between 1 and the number of retained dimensions of the ordination",
                ncol(glPca$scores),
                "; set to 2\n"
            )
        )
        yaxis <- 2
    }
    if (!is.null(zaxis)) {
        if (zaxis < 1 | zaxis > ncol(glPca$scores)) {
            cat(
                warn(
                    "  Warning: Z-axis must be specified to lie between 1 and the number of retained dimensions of the ordination",
                    ncol(glPca$scores),
                    "; set to 3\n"
                )
            )
            zaxis <- 3
        }
    }
    
    # Assign the new population list if as.pop is specified
    pop.hold <- pop(x)
    if (!is.null(as.pop)) {
        if (as.pop %in% names(x@other$ind.metrics)) {
            pop(x) <- as.matrix(x@other$ind.metrics[as.pop])
            if (verbose >= 2) {
                cat(
                    report(
                        "  Temporarily setting population assignments to",
                        as.pop,
                        "as specified by the as.pop parameter\n"
                    )
                )
            }
        } else {
            stop(
                error(
                    "Fatal Error: individual metric assigned to 'pop' does not exist. Check names(gl@other$loc.metrics) and select again\n"
                )
            )
        }
    }
    
    # If an fd object, pull out the genlight object
    if (datatype2 == "fd") {
        x <- x$fd
        datatype2 <- utils.check.datatype(x, verbose = 0)
    }
    axis.label.size <- axis.label.size * 10
    
    # DO THE JOB
    # Set NULL to variables to pass CRAN checks
    gen <- NULL  
    
    if(datatype1=="list"){
        
        gen_number <- length(hold_x)
        df_sim <- as.data.frame(matrix(ncol = 5))
        colnames(df_sim) <- c("PCoAx","PCoAy","ind","pop","gen")
        
        test_pos_neg <- as.data.frame(matrix(nrow = gen_number,ncol = 3 ))
        colnames(test_pos_neg) <- c("gen","test_x","test_y")
        
        # the direction of the PCA axes are chosen at random 
        # this is to set the same direction in every generation
        # first get the individual with more variance for axis x and y 
        # for the first generation of the simulations
        ind_x_axis <- which.max(abs(hold_glPca[[1]]$scores[,xaxis]))
        ind_y_axis <- which.max(abs(hold_glPca[[1]]$scores[,yaxis]))
        
        # check whether is positive or negative
        test_pos_neg[1, "test_x"] <- 
            if(hold_glPca[[1]]$scores[ind_x_axis,xaxis]>=0)"positive"else"negative"
        test_pos_neg[1, "test_y"]  <- 
            if(hold_glPca[[1]]$scores[ind_y_axis,yaxis]>=0)"positive"else"negative"
        for(sim_i in 1:gen_number){
            glPca <- hold_glPca[[sim_i]]
            x <- hold_x[[sim_i]]
            m <- cbind(glPca$scores[, xaxis], glPca$scores[, yaxis])
            df <- data.frame(m)
            # Convert the eigenvalues to percentages
            # s <- sum(glPca$eig[glPca$eig >= 0])
            # e <- round(glPca$eig * 100 / s, 1)
            # Labels for the axes and points
                xlab <- paste("PCA Axis", xaxis)
                ylab <- paste("PCA Axis", yaxis)
                ind <- indNames(x)
                pop <- factor(pop(x))
                gen <- unique(x$other$sim.vars$generation)
                df <- cbind(df, ind, pop,unique(x$other$sim.vars$generation))
                colnames(df) <- c("PCoAx", "PCoAy", "ind", "pop","gen")

                test_pos_neg[ sim_i, "test_x"] <- 
                    if(hold_glPca[[sim_i]]$scores[ind_x_axis,xaxis]>=0)"positive"else"negative"
                test_pos_neg[ sim_i, "test_y"]  <- 
                    if(hold_glPca[[sim_i]]$scores[ind_y_axis,yaxis]>=0)"positive"else"negative"
                
        if(test_pos_neg[1, "test_x"] != test_pos_neg[ sim_i, "test_x"]){
                    df$PCoAx <- df$PCoAx * -1
                    # test_pos_neg[ sim_i, "test_x"] <- test_pos_neg[ axis_ind-1, "test_x"] 
                }

                if(test_pos_neg[ 1, "test_y"] != test_pos_neg[ sim_i, "test_y"]){
                    df$PCoAy <- df$PCoAy * -1
                    
                    # test_pos_neg[ sim_i, "test_y"] <- test_pos_neg[ axis_ind-1, "test_y"] 
                }

                df_sim <- rbind(df_sim,df)
        }
         df_sim <- tibble::as_tibble(df_sim)
         df_sim <- df_sim[-1,]
        
        p  <- ggplot(df_sim, aes(PCoAx, PCoAy, colour = pop)) +
                        geom_point(size=3) +
            labs(title = 'Generation: {frame_time}', x = xlab, y = ylab) +
            gganimate::transition_time(gen) +
            gganimate::ease_aes('linear')
        return(p)
        }
    
    PCoAx <- PCoAy <- NULL
    
    # Create a dataframe to hold the required scores
    if (is.null(zaxis)) {
        m <- cbind(glPca$scores[, xaxis], glPca$scores[, yaxis])
    } else {
        m <-
            cbind(glPca$scores[, xaxis], glPca$scores[, yaxis], glPca$scores[, zaxis])
    }
    df <- data.frame(m)
    
    # Convert the eigenvalues to percentages
    s <- sum(glPca$eig[glPca$eig >= 0])
    e <- round(glPca$eig * 100 / s, 1)
    
    # Labels for the axes and points
    
    if (datatype2 == "SNP" | datatype2 == "SilicoDArT") {
        xlab <- paste("PCA Axis", xaxis, "(", e[xaxis], "%)")
        ylab <- paste("PCA Axis", yaxis, "(", e[yaxis], "%)")
        if (!is.null(zaxis)) {
            zlab <- paste("PCA Axis", zaxis, "(", e[zaxis], "%)")
        }
        
        ind <- indNames(x)
        pop <- factor(pop(x))
        df <- cbind(df, ind, pop)
        if (is.null(zaxis)) {
            colnames(df) <- c("PCoAx", "PCoAy", "ind", "pop")
        } else {
            colnames(df) <- c("PCoAx", "PCoAy", "PCoAz", "ind", "pop")
        }
        
    } else {
        # datatype2 == 'dist'
        xlab <- paste("PCoA Axis", xaxis, "(", e[xaxis], "%)")
        ylab <- paste("PCoA Axis", yaxis, "(", e[yaxis], "%)")
        if (!is.null(zaxis)) {
            zlab <- paste("PCA Axis", zaxis, "(", e[zaxis], "%)")
        }
        
        ind <- rownames(as.matrix(x))
        pop <- ind
        df <- cbind(df, ind, pop)
        if (is.null(zaxis)) {
            colnames(df) <- c("PCoAx", "PCoAy", "ind", "pop")
        } else {
            colnames(df) <- c("PCoAx", "PCoAy", "PCoAz", "ind", "pop")
        }
        if (interactive) {
            cat(
                warn(
                    "  Sorry, interactive labels are not available for an ordination generated from a Distance Matrix\n"
                )
            )
            cat(warn(
                "  Labelling the plot with names taken from the Distance Matrix\n"
            ))
        }
        pop.labels <- "pop"
    }
    
    ####### 2D PLOT
    if (is.null(zaxis)) {
        # If population labels
        
        if (pop.labels == "pop") {
            if (datatype2 == "SNP") {
                if (verbose >= 2)
                    cat(report(
                        "  Plotting populations in a space defined by the SNPs\n"
                    ))
            } else if (datatype2 == "SilicoDArT") {
                if (verbose >= 2)
                    cat(
                        report(
                            "  Plotting populations in a space defined by the presence/absence data\n"
                        )
                    )
            } else {
                if (verbose >= 2)
                    cat(report("  Plotting entities from the Distance Matrix\n"))
            }
            
            # Plot
            if (is.null(pt.shapes)) {
                plott <-
                    ggplot(df,
                           aes(
                               x = PCoAx,
                               y = PCoAy,
                               group = pop,
                               color = pop
                           ))
            } else {
                plott <-
                    ggplot(df,
                           aes(
                               x = PCoAx,
                               y = PCoAy,
                               group = pop,
                               color = pop,
                               shape = pop
                           ))
            }
            plott <- plott + geom_point(size = pt.size, aes(color = pop)) + 
                directlabels::geom_dl(aes(label = pop),
                                      method = list("smart.grid", 
                                                    cex = label.size)) + 
                theme(axis.title = element_text(face = "bold.italic", 
                                                size = axis.label.size,
                                                color = "black"),
                      axis.text.x = element_text(face = "bold", 
                                                 angle = 0,
                                                 vjust = 0.5,
                                                 size = axis.label.size),
                      axis.text.y = element_text(face = "bold", 
                                                 angle = 0,
                                                 vjust = 0.5,
                                                 size = axis.label.size)) +
                labs(x = xlab, y = ylab)
            
            if (!is.null(pt.shapes)) {
                plott <- plott + scale_shape_manual(values = pt.shapes)
            }
            if (!is.null(pt.colors)) {
                plott <- plott + scale_color_manual(values = pt.colors)
            }
            plott <-
                plott + geom_hline(yintercept = 0) + 
                geom_vline(xintercept = 0) + 
                theme(legend.position = "none")
            # Scale the axes in proportion to % explained, if requested if(scale==TRUE) { plott <- plott +
            # coord_fixed(ratio=e[yaxis]/e[xaxis]) }
            if (scale == TRUE) {
                plott <- plott + coord_fixed(ratio = 1)
            }
            # Add ellipses if requested
            if (ellipse == TRUE) {
                plott <- plott + stat_ellipse(type = "norm", level = plevel)
            }
        }
        
        # If interactive labels
        
        if (interactive) {
            cat(report("  Displaying an interactive plot\n"))
            cat(
                warn(
                    "  NOTE: Returning the ordination scores, not a ggplot2 compatable object\n"
                )
            )
            
            # Plot
            plott <-
                ggplot(df, aes(
                    x = PCoAx,
                    y = PCoAy,
                    label = ind
                )) + geom_point(size = pt.size, aes(color = pop)) + theme(
                    axis.title = element_text(
                        face = "bold.italic",
                        size = axis.label.size,
                        color = "black"
                    ),
                    axis.text.x = element_text(
                        face = "bold",
                        angle = 0,
                        vjust = 0.5,
                        size = axis.label.size
                    ),
                    axis.text.y = element_text(
                        face = "bold",
                        angle = 0,
                        vjust = 0.5,
                        size = axis.label.size
                    ),
                    legend.title = element_text(
                        color = "black",
                        size = axis.label.size,
                        face = "bold"
                    ),
                    legend.text = element_text(
                        color = "black",
                        size = axis.label.size,
                        face = "bold"
                    )
                ) +
                labs(x = xlab, y = ylab) + geom_hline(yintercept = 0) + geom_vline(xintercept = 0) + theme(legend.position = "none")
            # Scale the axes in proportion to % explained, if requested if(scale==TRUE) { plott <- plott +
            # coord_fixed(ratio=e[yaxis]/e[xaxis]) }
            if (scale == TRUE) {
                plott <- plott + coord_fixed(ratio = 1)
            }
            # Add ellipses if requested
            if (ellipse == TRUE) {
                plott <-
                    plott + stat_ellipse(aes(color = pop),
                                         type = "norm",
                                         level = plevel)
            }
            cat(warn(
                "  Ignore any warning on the number of shape categories\n"
            ))
        }
        
        # If labels = legend
        
        if (pop.labels == "legend") {
            if (verbose >= 2)
                cat(report("  Plotting populations identified by a legend\n"))
            
            # Plot
            Population <- pop
            if (is.null(pt.shapes)) {
                plott <-
                    ggplot(df,
                           aes(
                               x = PCoAx,
                               y = PCoAy,
                               group = Population,
                               color = Population
                           ))
            } else {
                plott <-
                    ggplot(
                        df,
                        aes(
                            x = PCoAx,
                            y = PCoAy,
                            group = pop,
                            color = Population,
                            shape = Population
                        )
                    )
            }
            plott <-
                plott + geom_point(size = pt.size, aes(color = pop)) + theme(
                    axis.title = element_text(
                        face = "bold.italic",
                        size = axis.label.size,
                        color = "black"
                    ),
                    axis.text.x = element_text(
                        face = "bold",
                        angle = 0,
                        vjust = 0.5,
                        size = axis.label.size
                    ),
                    axis.text.y = element_text(
                        face = "bold",
                        angle = 0,
                        vjust = 0.5,
                        size = axis.label.size
                    ),
                    legend.title = element_text(
                        color = "black",
                        size = axis.label.size,
                        face = "bold"
                    ),
                    legend.text = element_text(
                        color = "black",
                        size = axis.label.size,
                        face = "bold"
                    )
                ) + labs(x = xlab, y = ylab)
            if (!is.null(pt.shapes)) {
                plott <- plott + scale_shape_manual(values = pt.shapes)
            }
            if (!is.null(pt.colors)) {
                plott <- plott + scale_color_manual(values = pt.colors)
            }
            plott <-
                plott + geom_hline(yintercept = 0) + geom_vline(xintercept = 0)
            # Scale the axes in proportion to % explained, if requested if(scale==TRUE) { plott <- plott +
            # coord_fixed(ratio=e[yaxis]/e[xaxis]) }
            if (scale == TRUE) {
                plott <- plott + coord_fixed(ratio = 1)
            }
            # Add ellipses if requested
            if (ellipse == TRUE) {
                plott <- plott + stat_ellipse(type = "norm", level = plevel)
            }
        }
        
        # If labels = none
        
        if (pop.labels == "none" | pop.labels == FALSE) {
            if (verbose >= 0)
                cat(report("  Plotting points with no labels\n"))
            
            # Plot
            if (is.null(pt.shapes)) {
                plott <- ggplot(df, aes(
                    x = PCoAx,
                    y = PCoAy,
                    color = pop
                ))
            } else {
                plott <-
                    ggplot(df,
                           aes(
                               x = PCoAx,
                               y = PCoAy,
                               color = pop,
                               shape = pop
                           ))
            }
            plott <-
                plott + geom_point(size = pt.size, aes(color = pop)) + theme(
                    axis.title = element_text(
                        face = "bold.italic",
                        size = axis.label.size,
                        color = "black"
                    ),
                    axis.text.x = element_text(
                        face = "bold",
                        angle = 0,
                        vjust = 0.5,
                        size = axis.label.size
                    ),
                    axis.text.y = element_text(
                        face = "bold",
                        angle = 0,
                        vjust = 0.5,
                        size = axis.label.size
                    )
                ) + labs(x = xlab, y = ylab)
            if (!is.null(pt.shapes)) {
                plott <- plott + scale_shape_manual(values = pt.shapes)
            }
            if (!is.null(pt.colors)) {
                plott <- plott + scale_color_manual(values = pt.colors)
            }
            plott <-
                plott + geom_hline(yintercept = 0) + geom_vline(xintercept = 0) + theme(legend.position = "none")
            # Scale the axes in proportion to % explained, if requested if(scale==TRUE) { plott <- plott +
            # coord_fixed(ratio=e[yaxis]/e[xaxis]) }
            if (scale == TRUE) {
                plott <- plott + coord_fixed(ratio = 1)
            }
            # Add ellipses if requested
            if (ellipse == TRUE) {
                plott <- plott + stat_ellipse(type = "norm", level = plevel)
            }
        }
        
        if (verbose >= 2) {
            cat(report("  Preparing plot .... please wait\n"))
        }
        if (interactive) {
            plott <- plotly::ggplotly(plott)
            show(plott)
        } else {
            show(plott)
        }
    }  # End 2D plot
    
    ##### IF 3D PLOT
    if (!is.null(zaxis)) {
        if (verbose >= 2) {
            cat(
                report(
                    "  Displaying a three dimensional plot, mouse over for details for each point\n"
                )
            )
        }
        plott <-
            plotly::plot_ly(
                df,
                x = ~ PCoAx,
                y = ~ PCoAy,
                z = ~ PCoAz,
                marker = list(size = pt.size * 2),
                colors = pt.colors,
                text = ind
            ) %>%
            plotly::add_markers(color = ~ pop) %>%
            plotly::layout(
                legend = list(title = list(text = "Populations")),
                scene = list(
                    xaxis = list(
                        title = xlab,
                        titlefont = list(size = axis.label.size / 2)
                    ),
                    yaxis = list(
                        title = ylab,
                        titlefont = list(size = axis.label.size / 2)
                    ),
                    zaxis = list(
                        title = zlab,
                        titlefont = list(size = axis.label.size / 2)
                    )
                )
            )
        show(plott)
        if (verbose >= 2) {
            cat(warn("  May need to zoom out to place 3D plot within bounds\n"))
        }
    }
    
    # creating temp file names
    if (save2tmp) {
        temp_plot <- tempfile(pattern = "Plot_")
        match_call <-
            paste0(names(match.call()),
                   "_",
                   as.character(match.call()),
                   collapse = "_")
        # saving to tempdir
        saveRDS(list(match_call, plott), file = temp_plot)
        if (verbose >= 2) {
            cat(report("  Saving the ggplot to the session tempfile\n"))
        }
        temp_table <- tempfile(pattern = "Table_")
        saveRDS(list(match_call, df), file = temp_table)
        if (verbose >= 2) {
            cat(report("  Saving tabulation to the session tempfile\n"))
            # cat(report(' NOTE: Retrieve output files from tempdir using gl.list.reports() and gl.print.reports()\n'))
        }
    }
    # FLAG SCRIPT END
    
    # # Reassign the initial population list if as.pop is specified if (!is.null(as.pop)){ pop(x) <- pop.hold if (verbose >= 3)
    # {cat(report(' Resetting population assignments to initial state\n'))} }
    
    if (verbose >= 1) {
        cat(report("Completed:", funname, "\n"))
    }
    
    invisible(NULL)
}
