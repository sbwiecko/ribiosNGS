% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pca.R
\name{prcomp.DGEList}
\alias{prcomp.DGEList}
\title{Principal component analysis of DGEList}
\usage{
\method{prcomp}{DGEList}(x, ntop = NULL, scale = FALSE, verbose = FALSE, ...)
}
\arguments{
\item{x}{A \code{DGEList} object}

\item{ntop}{Integer, how many top-variable features should be used? If \code{NULL}, all features are used}

\item{scale}{Logical, whether variance of features should be scaled to 1. \code{FALSE} by default (recommended!); set it to \code{TRUE} only if you are sure what you are doing}

\item{verbose}{Logical, whether the function should print messages.}

\item{...}{Other parameters passed to \code{\link[vsn]{vsnMatrix}}

The function first remove all-zero-count features, because they can make the PCA plot of samples delusive. 

Next, it applies \code{vsn} transformation implemented in the \code{vsn} package to the count matrix. 

Finally, PCA is applied to the vsn-transformed matrix.}
}
\value{
The function returns a \code{prcomp} object. The fit object is saved in the \code{vsnFit} field in the returned object, and the transformed matrix is saved in the \code{vsnMat} field.
}
\description{
Principal component analysis of DGEList
}
\examples{

myCounts <- matrix(rnbinom(10000, 3, 0.25), nrow=1000)
myDgeList <- DGEList(counts=myCounts,
  samples=data.frame(group=gl(5,2)))
myPrcomp <- prcomp(myDgeList)

\dontrun{
  vsn::meanSdPlot(myPrcomp$vsnFit)
}

## features with zero count in all samples do not contribute to the PCA analysis
myDgeList2 <- DGEList(counts=rbind(myCounts, rep(0, 10)),
  samples=data.frame(group=gl(5,2)))
myPrcomp2 <- prcomp(myDgeList2)
stopifnot(identical(myPrcomp, myPrcomp2))

}
\seealso{
\code{\link{prcompExprs}}
}
