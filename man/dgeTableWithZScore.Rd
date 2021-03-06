% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/appendZScore.R
\name{dgeTableWithZScore}
\alias{dgeTableWithZScore}
\title{Append dgeTable with z-scores}
\usage{
dgeTableWithZScore(edgeResult, contrast = NULL)
}
\arguments{
\item{edgeResult}{An \code{EdgeResult} object.}

\item{contrast}{A character string, or integer index, or \code{NULL}, to specify the contrast. If \code{NULL}, results of all contrasts are returned.}
}
\value{
Similar as \code{dgeTable}, a \code{data.frame}, with an additional column \code{zScore}.
}
\description{
Append dgeTable with z-scores
}
\seealso{
\code{\link{dgeTablesWithZScore}}, \code{\link{dgeTable}}, \code{\link{dgeTableWithPseudoT}}
}
