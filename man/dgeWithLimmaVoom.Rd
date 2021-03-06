% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dge.R
\name{dgeWithLimmaVoom}
\alias{dgeWithLimmaVoom}
\title{Perform differential gene expression analysis with edgeR-limma}
\usage{
dgeWithLimmaVoom(edgeObj, ...)
}
\arguments{
\item{edgeObj}{An object of \code{EdgeObject}}

\item{...}{Passed to \code{voom}

The function performs end-to-end differential gene expression (DGE) analysis
with common best practice using voom-limma}
}
\value{
An \code{EdgeResult} object
}
\description{
Perform differential gene expression analysis with edgeR-limma
}
\examples{

set.seed(1887)
exObj <- exampleEdgeObject()
exLimmaVoomRes <- dgeWithLimmaVoom(exObj)
dgeTable(exLimmaVoomRes)

## compare with edgeR
dgeTable(dgeWithEdgeR(exObj))

## LimmaVoomResult can be also used with exportEdgeResult
exportEdgeResult(exLimmaVoomRes, paste0(tempdir(), "test"), "overwrite")
}
