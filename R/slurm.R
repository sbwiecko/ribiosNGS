#' Export an DGEList, designMatrix, and contrastMatrix to files and return the command to run the edgeR script
#' @param dgeList An \code{DGEList} object with \code{counts}, \code{genes}, and \code{samples}
#' @param designMatrix The design matrix to model the data
#' @param contrastMatrix The contrast matrix matching the design matrix
#' @param outfilePrefix Prefix of the output files. It can include directories, e.g. \code{"data/outfile-"}. In case of \code{NULL}, temporary files will be created.
#' @param outdir Output directory of the edgeR script. Default value "edgeR_output".
#' @param mps Logical, whether molecular-phenotyping analysis is run.
#' 
#' @note
#' Following checks are done internally:
#' \itemize{
#'   \item The design matrix must have the same number of rows as the columns of the count matrix.
#'   \item The contrast matrix must have the same number of rows as the columns of the design matrix.
#'   \item Row names of the design matrix match the column names of the expression matrix. In case of suspect, the program will stop and report.
#' }
#' 
#' The output file names start with the outfilePrefix, followed by '-' and customed file suffixes. 
#' 
#' @examples
#'  mat <- matrix(rnbinom(100, mu=5, size=2), ncol=10)
#'  rownames(mat) <- sprintf("gene%d", 1:nrow(mat))
#'  myFac <- gl(2,5, labels=c("Control", "Treatment"))
#'  y <- edgeR::DGEList(counts=mat, group=myFac)
#'  myDesign <- model.matrix(~myFac); colnames(myDesign) <- levels(myFac)
#'  myContrast <- limma::makeContrasts(Treatment, levels=myDesign)
#'  edgeRcommand(y, designMatrix=myDesign, contrastMatrix=myContrast, 
#'      outfilePrefix=NULL, outdir=tempdir())
edgeRcommand <- function(dgeList, designMatrix, contrastMatrix,
                         outfilePrefix=NULL,
                         outdir="edgeR_output",
                         mps=FALSE) {
  if(is.null(outfilePrefix) || is.na(outfilePrefix)) {
    outfilePrefix <- tempfile(pattern="edgeRslurm")
  }
  
  ## remove trailing -s if any
  outfilePrefix <- gsub("-$", "", outfilePrefix)
  
  ## check consistency between names
  exprsMat <- dgeList$counts
  if(!identical(rownames(designMatrix), colnames(exprsMat)) &&
     (is.null(rownames(designMatrix)) || identical(rownames(designMatrix), 
                                                   as.character(1:nrow(designMatrix))))) {
    rownames(designMatrix) <- colnames(exprsMat)
  }
  haltifnot(nrow(designMatrix) == ncol(exprsMat),
            msg="The design matrix must have the same number of rows as the columns of the count matrix.")
  haltifnot(identical(rownames(designMatrix), colnames(exprsMat)),
            msg="Row names of the design matrix not matching column names of the expression matrix.")
  haltifnot(ncol(designMatrix) == nrow(contrastMatrix),
            msg="The contrast matrix must have the same number of rows as the columns of the design matrix.")
  
  exprsFile <- paste0(outfilePrefix, "-counts.gct")
  fDataFile <- paste0(outfilePrefix, "-featureAnno.txt")
  pDataFile <- paste0(outfilePrefix, "-sampleAnno.txt")
  groupFile <- paste0(outfilePrefix, "-sampleGroup.txt")
  groupLevelFile <- paste0(outfilePrefix, "-sampleGroupLevels.txt")
  designFile <- paste0(outfilePrefix, "-designMatrix.txt")
  contrastFile <- paste0(outfilePrefix, "-contrastMatrix.txt")
  
  writeDGEList(dgeList, exprs.file=exprsFile,
               fData.file = fDataFile,
               pData.file = pDataFile,
               group.file = groupFile,
               groupLevels.file = groupLevelFile)
  writeMatrix(designMatrix, designFile)
  writeMatrix(contrastMatrix, contrastFile)
  
  logFile <- paste0(gsub("\\/$", "", outdir), ".log")
  mpsComm <- ifelse(mps, "-mps", "")
  command <- paste("/pstore/apps/bioinfo/geneexpression/bin/ngsDge_edgeR.Rscript",
                   sprintf("-infile %s", exprsFile),
                   sprintf("-designFile %s", designFile),
                   sprintf("-contrastFile %s", contrastFile),
                   sprintf("-sampleGroups %s", groupFile),
                   sprintf("-groupLevels %s", groupLevelFile),
                   sprintf("-featureAnnotationFile %s", fDataFile),
                   sprintf("-phenoData %s", pDataFile),
                   sprintf("-outdir %s", outdir),
                   sprintf("-log %s", logFile),
                   sprintf("-writedb"),
                   mpsComm)
  return(command)
}

#' Return the SLURM command to run the edgeR script
#' @param dgeList An \code{DGEList} object with \code{counts}, \code{genes}, and \code{samples}
#' @param designMatrix The design matrix to model the data
#' @param contrastMatrix The contrast matrix matching the design matrix
#' @param outfilePrefix Prefix of the output files. It can include directories, e.g. \code{"data/outfile-"}. In case of \code{NULL}, temporary files will be created.
#' @param outdir Output directory of the edgeR script. Default value "edgeR_output".
#' @param mps Logical, whether molecular-phenotyping analysis is run.
#' 
#' This function wraps the function \code{\link{edgeRcommand}} to return the command needed to start a SLURM job.
#' 
#' It uses \code{outdir} to specify slurm output and error files as in the same directory of \code{outdir}. And the job name is set as the name of the output directory.
#' 
#' @seealso \code{\link{edgeRcommand}}
#' @examples 
#'  mat <- matrix(rnbinom(100, mu=5, size=2), ncol=10)
#'  rownames(mat) <- sprintf("gene%d", 1:nrow(mat))
#'  myFac <- gl(2,5, labels=c("Control", "Treatment"))
#'  y <- edgeR::DGEList(counts=mat, group=myFac)
#'  myDesign <- model.matrix(~myFac); colnames(myDesign) <- levels(myFac)
#'  myContrast <- limma::makeContrasts(Treatment, levels=myDesign)
#'  slurmEdgeRcommand(y, designMatrix=myDesign, contrastMatrix=myContrast, 
#'      outfilePrefix=NULL, outdir=tempdir())
slurmEdgeRcommand <- function(dgeList, designMatrix, contrastMatrix,
                              outfilePrefix=NULL,
                              outdir="edgeR_output",
                              mps=FALSE) {
  comm <- edgeRcommand(dgeList=dgeList, designMatrix=designMatrix, contrastMatrix=contrastMatrix,
                       outfilePrefix=outfilePrefix,
                       outdir=outdir,
                       mps=mps)
  outdirBase <- basename(gsub("\\/$", "", outdir))
  outfile <- file.path(dirname(outdir), paste0("slurm-", outdirBase, ".out"))
  errfile <- file.path(dirname(outdir), paste0("slurm-", outdirBase, ".err"))
  res <- paste("sbatch -c 1",
               sprintf("-e %s", errfile),
               sprintf("-J %s", outdirBase),
               sprintf("-o %s", outfile),
               comm)
  return(res)
}

#' Send an edgeR analysis job to SLURM
#' @param dgeList An \code{DGEList} object with \code{counts}, \code{genes}, and \code{samples}
#' @param designMatrix The design matrix to model the data
#' @param contrastMatrix The contrast matrix matching the design matrix
#' @param outfilePrefix Prefix of the output files. It can include directories, e.g. \code{"data/outfile-"}. In case of \code{NULL}, temporary files will be created.
#' @param outdir Output directory of the edgeR script. Default value "edgeR_output".
#' @param overwrite If \code{ask}, the user is asked before an existing output directory is overwritten. If \code{yes}, the job will start and an existing directory will be overwritten anyway. If \code{no}, and if an output directory is present, the job will not be started.
#' @param mps Logical, whether molecular-phenotyping analysis is run.
#' 
#' @return A list of two items, \code{command}, the command line call, and \code{output}, the output of the SLURM command in bash
#' 
#' @note 
#' Even if the output directory is empty, if \code{overwrite} is set to \code{no} (or if the user answers \code{no}), the job will not be started.
#' 
#' @examples 
#'  mat <- matrix(rnbinom(100, mu=5, size=2), ncol=10)
#'  rownames(mat) <- sprintf("gene%d", 1:nrow(mat))
#'  myFac <- gl(2,5, labels=c("Control", "Treatment"))
#'  y <- edgeR::DGEList(counts=mat, group=myFac)
#'  myDesign <- model.matrix(~myFac); colnames(myDesign) <- levels(myFac)
#'  myContrast <- limma::makeContrasts(Treatment, levels=myDesign)
#'  \dontrun{
#'  slurmEdgeR(y, designMatrix=myDesign, contrastMatrix=myContrast, 
#'    outfilePrefix=NULL, outdir=tempdir())
#'  }
slurmEdgeR <- function(dgeList, designMatrix, contrastMatrix,
                       outfilePrefix=NULL,
                       outdir="edgeR_output",
                       overwrite=c("ask", "yes", "no"),
                       mps=FALSE) {
  overwrite <- match.arg(overwrite)
  ans <- NA
  if(overwrite=="ask") {
    if(dir.exists(outdir)) {
      msg <- sprintf("Directory %s exists. Overwritte(y/N)?[N]", outdir)
      while(!ans %in% c("N",  "y")) {
        if(!is.na(ans)) {
          message(sprintf("Invalid input %s", ans))
        }
        ans <- readline(msg)
        if(ans=="" || ans=="n") {
          ans <- "N"
        }
      }
    } else {
      ans <- "y"
    }
  } else if (overwrite=="no") {
    ans <- "N"
  } else if (overwrite=="yes") {
    ans <- "y"
  }

  doOverwrite <- switch(ans,
                        "N"=FALSE,
                        "y"=TRUE)
  if(!doOverwrite & dir.exists(outdir)) {
    return(invisible(NULL))
  }
  
  comm <- slurmEdgeRcommand(dgeList=dgeList, designMatrix=designMatrix, contrastMatrix=contrastMatrix,
                            outfilePrefix=outfilePrefix,
                            outdir=outdir,
                            mps=mps)
  res <- system(comm, intern=TRUE)
  return(list(command=comm, output=res))
}