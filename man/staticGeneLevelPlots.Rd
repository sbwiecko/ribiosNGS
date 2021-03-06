% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/staticGeneLevelPlots.R
\name{staticGeneLevelPlots}
\alias{staticGeneLevelPlots}
\title{Make static gene-level plots of an EdgeResult object}
\usage{
staticGeneLevelPlots(edgeResult)
}
\arguments{
\item{edgeResult}{An EdgeResult object}
}
\value{
\code{NULL}, side effect is used
}
\description{
Make static gene-level plots of an EdgeResult object
}
\examples{
edgeObj <- exampleEdgeObject()
edgeRes <- dgeWithEdgeR(edgeObj)
staticGeneLevelPlots(edgeRes)

limmaVoomRes <- dgeWithEdgeR(edgeObj)
staticGeneLevelPlots(limmaVoomRes)
}
