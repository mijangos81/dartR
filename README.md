
<!-- badges: start -->
Main repository: 
  [![](https://www.r-pkg.org/badges/version/dartR?color=blue)](https://cran.r-project.org/package=dartR)
  [![CRAN checks](https://cranchecks.info/badges/summary/dartR)](https://cran.r-project.org/web/checks/check_results_dartR.html)
  [![R-CMD-check](https://github.com/green-striped-gecko/dartR/workflows/R-CMD-check/badge.svg)](https://github.com/green-striped-gecko/dartR/actions)
  [![R-CMD-check-beta](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-beta.yaml/badge.svg?branch=beta)](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-beta.yaml)
  [![](https://img.shields.io/badge/doi-10.1111/1755--0998.12745-00cccc.svg)](https://doi.org/10.1111/1755-0998.12745)
  [![](http://cranlogs.r-pkg.org/badges/last-week/dartR?color=orange)](https://cran.r-project.org/package=dartR)
  
  <!-- badges: end -->


<!-- badges: start -->
Dev repositories: 
[![R-CMD-check-dev](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev.yaml/badge.svg?branch=dev)](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev.yaml)
[![R-CMD-check-dev_Arthur](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Arthur.yaml/badge.svg?branch=dev_arthur)](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Arthur.yaml)
[![R-CMD-check-dev_Bernd](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Bernd.yaml/badge.svg?branch=dev_bernd)](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Bernd.yaml)
[![R-CMD-check-dev_Luis](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Luis.yaml/badge.svg?branch=dev_luis)](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Luis.yaml)
[![R-CMD-check-dev_Carlo](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Carlo.yaml/badge.svg?branch=dev_carlo)](https://github.com/green-striped-gecko/dartR/actions/workflows/R-CMD-check-dev_Carlo.yaml)
 <!-- badges: end -->



![][id]

### Importing and Analysing Snp and Silicodart Data Generated by Genome-Wide-Restriction Fragment Analysis

---

#### Changelog (list of newly integrated functions)

[Changelog](https://github.com/green-striped-gecko/dartR/wiki/dartR-wiki)

----

#### Installation via CRAN

The package is now on CRAN, so to install simply type:

```{r}
install.packages("dartR")
library(dartR)
```
The latest version 1.9.9.1 introduces a two tier system as CRAN is limiting the numbers of packages that can be installed with a package. So the install.packages command above, installs only the base packages that are needed for the import, filter and report functions to work. For many other advanced functions additional packages are needed. To automate this process you need to invoke the gl.install.vanilla.dartR function. 


```{r}
gl.install.vanilla.dartR(flavour="CRAN")
```
You can install different flavours (repositories) as well, so for the "dev" version from github you can use: 

```{r}
gl.install.vanilla.dartR(flavour="dev")
```
"master" installs the master version from Github, which is 99.9% percent of the time identical with CRAN. There is a slight delay for new versions to appear on CRAN so the master version can be slightly newer than the CRAN version. Be aware the "dev" versions are not fully tested yet and function may not work as intended. You can see if a current version runs all checks successfully by checking the banners at the top of this page.


The package also includes a nice introdcutory tutorial (called vignette in R terminology). Once installed type:

```{r}
browseVignettes("dartR")
```
to access it.


----

#### Manual installation of the latest version (R>3.5)

To install the latest package manually follow the description below:

The installation of the package might not run smoothly, as it requires additional bioconductor packages that need to be installed. 
To install the packages and all dependencies copy paste the script below into your R-console. (If you are lucky it simply installs all packages without any error message and you are done):


```{r}
install.packages("devtools")
library(devtools)
install.packages("BiocManager")
BiocManager::install(c("SNPRelate", "qvalue"))
install_github("green-striped-gecko/dartR")
library(dartR)
```
You may need to install additional packages either manually or using the gl.install.vanilla() function.


#### Manual installation of the latest version  (R<3.5)

The BiocManager package is not available for R<3.5, hence you may need to use the following code:


```{r}
source("https://bioconductor.org/biocLite.R")
BiocInstaller::biocLite(c("SNPRelate", "qvalue"))
install.packages("dartR")
library(dartR)
```

Unfortunately sometimes to us unkown reasons R is not able to install all dependent packages and breaks with an error message. 
Then you need to install packages "by hand". For example you may find:

```
ERROR: dependency 'seqinr' is not available for package 'dartR'
removing 'C:/Program Files/R/library/dartR'
Error: Command failed (1)
```

Then you need to install the package ```seqinr``` via: 

```install.packages("seqinr")```

And run the last line of code again:

```install_github("green-striped-gecko/dartR")```

This "game"  of ```install.packages()``` and ```install_github()``` [the last two steps] might need to be repeated for additional packages as for whatever reason R does no longer install all packages (if anyone could tell me a way to fix this, it would be highly appreciated). Finally you should be able to run:

```{r}
install_github("green-striped-gecko/dartR")
library(dartR)
```

**without any error** (warnings if you are using an older version of R are okay) and you are done. 

In case you want to have the latest version of the package you can download the developer version via:

```{r}I
install_github("green-striped-gecko/dartR@dev")
```
**!!Please note the here it is quite likely that some functions might not work, or even the install might break with an error.!!**


Have fun working with dartR! Any issues you encounter please use the issues tab on github or contact us via email under glbugs@aerg.canberra.edu.au


Cheers, Bernd & Arthur

[id]: vignettes/figures/dartRlogo.png ""
