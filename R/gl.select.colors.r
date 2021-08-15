#' @name gl.select.colors
#' @title Select colors from one of several palettes and output as a vector
#' @description
#' This script draws upon a number of specified colour libraries to extract a vector of colours for plotting, where
#' the script that follows has a colour parameter expecting a vector of colours.
#' @details
#' The available colour libraries include base R, RColorBrewer, gr.palette (grDevice palette) and gr.hcl (grDevice hcl).
#' Each of these libraries have a set of palettes, which will be listed if the nominated palette is not specified. A
#' default palette will then be chosen.
#' 
#' The colour palette will be displayed in the graphics window for the requested number of colours (or 9 if not specified),
#' and the vector of colours returned for later use.
#' 
#' The select parameter can be used to select colours from the specified ncolors. For example, select=c(1,1,3) will
#' select colour 1, 1 again and 3 to retain in the final vector. This can be useful for fine-tuning colour selection, and
#' matching colours and shapes.
#'
#' @param x Optionally, provide a gl object from which to determine the number of populations [default NULL]
#' @param library Name of the colour library to be used [default scales::hue_pl]
#' @param palette Name of the colour palette to be pulled from the specified library [default is library specific] 
#' @param ncolors number of colours to be displayed and returned [default 9]
#' @param select select the colours to retain in the output vector [default NULL] 
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2 or as specified using gl.set.verbosity]
#'
#' @import scales
#' @import RColorBrewer  
#' @return A vector with the requried number of colours
#' 
#' @author Custodian: Arthur Georges -- Post to \url{https://groups.google.com/d/forum/dartr}
#' 
#' @examples
#' # SET UP DATASET 
#' gl <- testset.gl
#' levels(pop(gl))<-c(rep("Coast",5),rep("Cooper",3),rep("Coast",5),
#' rep("MDB",8),rep("Coast",7),"Em.subglobosa","Em.victoriae")
#' # EXAMPLES -- SIMPLE
#' colors <- gl.select.colors()
#' colors <- gl.select.colors(library="brewer",palette="Spectral",ncolors=6)
#' colors <- gl.select.colors(library="baseR",palette="terrain.colors",ncolors=6)
#' colors <- gl.select.colors(library="baseR",palette="rainbow",ncolors=12)
#' colors <- gl.select.colors(library="gr.hcl",palette="RdBu",ncolors=12)
#' colors <- gl.select.colors(library="gr.palette",palette="Pastel 1",ncolors=6)
#' # EXAMPLES -- SELECTING COLOURS
#' colors <- gl.select.colors(library="baseR",palette="rainbow",ncolors=12,select=c(1,1,1,5,8))
#' # EXAMPLES -- CROSS-CHECKING WITH A GENLIGHT OBJECT
#' colors <- gl.select.colors(x=gl,library="baseR",palette="rainbow",ncolors=12,select=c(1,1,1,5,8))
#' 
#' @seealso \code{\link{gl.select.shapes}}
#' @family Exploration/visualisation functions
#' 
#' @export


gl.select.colors <- function(x=NULL,
                             library=NULL, 
                             palette=NULL,
                             ncolors=NULL,
                             select=NULL,
                             verbose=NULL){

  # SET VERBOSITY
  verbose <- gl.check.verbosity(verbose)
  
  # FLAG SCRIPT START
  funname <- match.call()[[1]]
  utils.flag.start(func=funname,build="Jackson",v=verbose)
  
  # SCRIPT SPECIFIC ERROR CHECKING

  if(!is.null(x)){
    datatype <- utils.check.datatype(x)
  }
  
  if(is.null(ncolors)){
    if(!is.null(x)){
      ncolors <- pop(x)
      if(verbose >= 2){cat(warn("  Warning: Number of required colors not specified, set to number of pops",nPop(x),"in gl object\n"))}
    } else {
      # if(!is.null(select)){
      #   ncolors <- length(select)
      #   if(verbose >= 2){cat(warn("  Warning: Number of required colors not specified, set to number colours,",length(select),", selected for display\n"))}
      # } else {
        if(verbose >= 2){cat(warn("  Warning: Number of required colors not specified, set to 9 to display the colors\n"))}
        ncolors <- 9
      }
    }  

  if(!is.null(select)){
    if(!is.null(x)){
      if(nPop(x) != length(select)){
        stop(error("Fatal Error: Number of specified colours",length(select),"does not correspond to number of populations",nPop(x),"in supplied genlight object\n"))
      } else {
        cat(report("  Number of specified colours",length(select),"corresponds to number of populations in supplied genlight object\n"))
      }
    }
  }
  
  # DO THE JOB
  
  if(is.null(library)){
    palette=NULL
    if(verbose >= 2){
      cat(warn("  Warning: No colour library or palette specified, set to default\n"))
      cat(warn("    Select one of baseR, brewer, gr.palette or gr.hcl\n"))
    }
    library <- "scales"
    palette <- "hue_pal"
    colors <- scales::hue_pal()(ncolors)
    cat(report(("  Library: scale\n")))
    cat(report(("  Palette: hue_pal\n")))
    
  } else {
    if(library=="brewer"){
    if(is.null(palette)){
      if(verbose >= 2){cat(warn("  Warning: Palette not specified, set to Spectral\n"))}
      palette <- "Spectral"
    }
    if(!(palette %in% row.names(brewer.pal.info))){
      if(verbose >= 2){
        cat (warn("  Warning: Nominated palette not available in RColorBrewer, should be one of\n"))
        cat(warn(paste(row.names(brewer.pal.info),collapse=", "),"\n"))
        cat(warn("  Set to Spectral\n"))
      }
      palette <- "Spectral"
    }
    colors <- RColorBrewer::brewer.pal(ncolors,palette)
    cat(report(("  Library: RColorBrewer\n")))
    cat(report(("  Palette: brewer.pal\n")))
    
  } else if(library=="gr.palette"){
    if(is.null(palette)){
      if(verbose >= 2){cat(warn("  Warning: Palette not specified, set to Tableau 10\n"))}
      palette <- "Tableau 10"
    }
    if(!(palette %in% grDevices::palette.pals())){
      if(verbose >= 2){
        cat (warn("  Warning: Nominated palette not available in grDevices::palette, should be one of\n"))
        cat(warn(paste(palette.pals(),collapse=", "),"\n"))
        cat(warn("  Set to Tableau 10\n"))
      }
      palette <- "Tableau 10"
    }
    colors <- grDevices::palette.colors(n = ncolors, palette = palette)
    cat(report(("  Library: grDevices\n")))
    cat(report(("  Palette: palette.pals\n")))
    
  } else if(library=="gr.hcl"){
    if(is.null(palette)){
      palette <- "Spectral"
      if(verbose >= 2){cat(warn("  Warning: Palette not specified, set to Spectral\n"))}
    }
    if(!(palette %in% grDevices::hcl.pals())){
      if(verbose >= 2){
        cat (warn("  Warning: Nominated palette not available in grDevices::hcl, should be one of\n"))
        cat(warn(paste(hcl.pals(),collapse=", "),"\n"))
        cat(warn("  Set to Spectral\n"))
      }
      palette <- "Spectral"
    }
    colors <- grDevices::hcl.colors(n = ncolors, palette = palette)
    cat(report(("  Library: grDevices\n")))
    cat(report(("  Palette: hcl.pals\n")))

  } else if(library=="baseR"){
    if(is.null(palette)){
      if(verbose >= 2){cat(warn("  Warning: Palette not specified, set to rainbow\n"))}
      palette <- "rainbow"
    }
    if(!(palette %in% c("rainbow","heat","topo.colors","terrain.colors","cm.colors"))){
      if(verbose >= 2){
        cat (warn("  Warning: Nominated palette not available in base R, should be one of\n"))
        cat(warn("  rainbow, heat.colors, topo.colors, terrain.colors, cm.colors\n"))
        cat(warn("  Set to rainbow\n"))
      }  
      palette <- "rainbow"
    }
    if(palette=="rainbow"){
      colors <- rainbow(n = ncolors)
      cat(report(("  Library: baseR\n")))
      cat(report(("  Palette: rainbow\n")))
    # } else if(palette=="heat.colors"){
    #   colors <- heat.colors(n = ncolors)
    #   cat(report(("  Library: baseR\n")))
    #   cat(report(("  Palette: heat.colors\n")))
    } else if(palette=="topo.colors"){
      colors <- topo.colors(n = ncolors)
      cat(report(("  Library: baseR\n")))
      cat(report(("  Palette: topo.colors\n")))
    } else if(palette=="terrain.colors"){
      colors <- terrain.colors(n = ncolors)
      cat(report(("  Library: baseR\n")))
      cat(report(("  Palette: terrain.colors\n")))
    } else if(palette=="cm.colors"){
      colors <- cm.colors(n = ncolors)
      cat(report(("  Library: baseR\n")))
      cat(report(("  Palette: cm.colors\n")))
    } else {
      if(verbose >= 2){cat(warn("  Warning: nominated palette not in Base R, selecting rainbow\n"))}
      colors <- rainbow(n = ncolors)
    }
  } 
  }
  if(verbose >= 1){
    if(library=="brewer"){library <- "RColorBrewer"}
    if(library=="gr.hcl"){library <- "grDevice-hcl"}
    if(library=="gr.palette"){library <- "grDevice-palette"}
    if(!is.null(select)){
      colors <- colors[c(select)]
      cat("  Showing and returning",length(select),"of",ncolors,"colours for library",library,": palette",palette,"\n")
    } else {
      cat("  Showing and returning",ncolors,"colours for library",library,": palette",palette,"\n")
    }

    show_col(colors)
  }
  
  # FLAG SCRIPT END

  if (verbose >= 1) {
    cat(report("Completed:",funname,"\n"))
  }
  
  return(colors)
}
