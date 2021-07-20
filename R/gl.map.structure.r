#' @name gl.plot.structure
#'
#' @title Map a STRUCTURE plot using a genlight object
#'
#' @description 
#' This function takes the output of plotstructure (the q matrix) and maps the q-matrix across using the population centers from the genlight object that was used to run the structure analysis via
#'  \code{\link{gl.run.structure}}) and plots the typical structure bar
#'   plots on a spatial map, providing a barplot for each subpopulation. Therefore it requires coordinates from a genlight object. This kind of plots should support the interpretation of the spatial structure of a population, but in principle is not different from \code{\link{gl.plot.structure}}
#' @param qmat q-matrix from a structure run followed by a clumpp run object [from \code{\link{gl.run.structure}} and \code{\link{gl.plot.structure}}] [required].
#'  @param x name of the genlight object containing the coordinates in the \code{\@other$latlon} slot to calculate the population centers [required]
#'  @param scalex scaling factor to determine the size of the bars in x direction
#'  @param scaley scaling factor to determine the size of the bars in y direction
#' @return an interactive map that shows the structure plots broken down by population
#'
#' @author Bernd Gruber (Post to \url{https://groups.google.com/d/forum/dartr})
#'
#' #@examples
#' \dontrun{
#' #CLUMPP needs to be installed to be able to run the example
#' #only the first 100 loci
#' #bc <- bandicoot.gl[,1:100]
#' #sr <- gl.run.structure(bc, k.range = 2:5, num.k.rep = 3, exec = "./structure.exe")
#' #qmat <- gl.plot.structure(sr, k=3, CLUMPP="d:/structure/")
#' #gl.map.structure(qmat, bc, scalex=1, scaley=0.5)
#' }
#' @export
#' @importFrom leaflet addRectangles
#' @seealso \code{\link{gl.run.structure}},  \link[strataG]{clumpp}, \code{\link{gl.plot.structure}}
#' @references 
#' Pritchard, J.K., Stephens, M., Donnelly, P. (2000) Inference of population structure using multilocus genotype data. Genetics 155, 945-959.
#' 
#' Archer, F. I., Adams, P. E. and Schneiders, B. B. (2016) strataG: An R package for manipulating, summarizing and analysing population genetic data. Mol Ecol Resour. doi:10.1111/1755-0998.12559
#' 
#' Evanno, G., Regnaut, S., and J. Goudet. 2005. Detecting the number of clusters of individuals using the software STRUCTURE: a simulation study. Molecular Ecology 14:2611-2620.


gl.map.structure <- function(qmat, x, scalex =1, scaley=1) {


  ff <-qmat[,4:(ncol(qmat))]

  
  
  df <- x@other$latlon
  centers <- apply(df, 2, function(xx) tapply(xx, pop(x), mean, na.rm=TRUE))
  cx <- centers[,"lon"]
  cy <- centers[,"lat"]
  sx <- abs(diff(range(centers[,"lon"])))/(100)*scalex
  sy <- 20*sx*scaley
# 
  qmat$orig.pop <- factor(qmat$orig.pop) 
   npops <- length(levels(qmat$orig.pop))
   ll <- data.frame(cbind(as.numeric(qmat$orig.pop),ff))
   zz <- do.call(order,  unname(as.list(ll)))
   bb <- qmat[zz,]
   bb$orig.pop <- factor(bb$orig.pop)
   ff <-bb[,4:(ncol(bb))]
   
   
   m1 <- leaflet::leaflet() %>% leaflet::addTiles()
  for (p in 1:npops)
  {
  qmi <- ff[bb$orig.pop==levels(bb$orig.pop)[p],]
  
  qmi1 <- cbind(rep(0,nrow(qmi)),qmi)
  for (xx in 1:nrow(qmi1)) qmi1[xx,] <- cumsum(as.numeric(qmi1[xx,]))
  
  
  for (ii in 1:nrow(qmi1)) {
   for ( i in 1:(ncol(qmi1)-1)) {
     oo <- (ii-nrow(qmi)/2)*sx
   
     m1 <- m1   %>% addRectangles(cx[p]+oo, cy[p]+qmi1[ii,i]*sy, cx[p]+oo+sx, cy[p]+qmi1[ii,i+1]*sy, opacity = 0, color =  rainbow(ncol(ff))[i], fillOpacity = 0.8)
     
   }
 }

}


 m1 %>% leaflet::addProviderTiles("Esri.WorldImagery")
 
 #%>% addLegend(labels=paste("Group",1:ncol(ff)), colors=rainbow(ncol(ff)),position ="topright" )
 
}

