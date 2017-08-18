# .utilities.R
#
# Miscellaneous R code to suppport the project
#
# Version: 1.0
# Date:    2017 08 15
# Author:  Boris Steipe
#
# V 1.0    First code
#
# ToDo:
# Notes:
#
# ==============================================================================

source("include.R")
source("src2wtxt.R")
source("parseAPIresponse.R")
source("getMWedittoken.R")
source("postSRCtoMW.R")


vspace <- function() {
  return("\n{{Vspace}}\n\n")
}


renameUnitABCunitsStatus <- function(oldID, newID) {
  load("ABCunitsStatus.Rdata")

  oldFile <- ID2SRC(oldID)
  if (! any(ABCunitsStatus$file == oldFile)) {
    stop("renameUnitABCunitsStatus > PANIC: no file with oldIDin ABCunitsStatus")
  }

  ABCunitsStatus$file[ABCunitsStatus$file == oldFile] <- ID2SRC(newID)

  # Save updated status file
  save(ABCunitsStatus, file = "ABCunitsStatus.Rdata")
}


addUnitABCunitsStatus <- function(newID) {

  load("ABCunitsStatus.Rdata")

  newRow <- data.frame(file = ID2SRC(newID),
                       lastUpload = as.POSIXct(0, origin = "1970-01-01"),
                       stringsAsFactors = FALSE)
  ABCunitsStatus <- rbind(ABCunitsStatus, newRow)

  save(ABCunitsStatus, file = "ABCunitsStatus.Rdata")
}


deleteUnitABCunitsStatus <- function(ID) {

  load("ABCunitsStatus.Rdata")

  SRC <- ID2SRC(ID)
  idx <- which(ABCunitsStatus$file == SRC)

  if (length(idx) != 1) {
    stop("PANIC: Not exactly one instance of ID in ABCunitsStatus.")
  }

  ABCunitsStatus <- ABCunitsStatus[- idx, ]

  save(ABCunitsStatus, file = "ABCunitsStatus.Rdata")
}


ID2SRC <- function(ID, CPATH = "../components/", EXT = ".components.wtxt") {
  # Expand a unit ID to a components file in CPATH directory
  SRC <- paste0(CPATH, ID, EXT)
  return(SRC)
}


SRC2ID <- function(SRC, CPATH = "../components/", EXT = ".components.wtxt") {
  # Extract the unit ID from a components file path
  ID <- gsub(paste0("^", CPATH), "", SRC)
  ID <- gsub(paste0(EXT, "$"), "", ID)
  return(ID)
}


# [END]
