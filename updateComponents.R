# updateComponents.R
#
# update all recently edited component files by uploading wikitext to the Wiki.
#

CPATH <- "../components"
myComponents <- list.files(path = CPATH,
                           pattern = ".*\\.components\\.wtxt$",
                           full.names = TRUE)

load("ABCunitsStatus.Rdata")

for (SRC in myComponents) {

  lastUpload <- ABCunitsStatus$lastUpload[ABCunitsStatus$file == SRC]
  lastModified <- file.mtime(SRC)

  if (lastModified > lastUpload) { # upload this unit
    ID <- gsub(paste0(CPATH, "/"), "", SRC)
    ID <- gsub("\\.components\\.wtxt$", "", ID)

    if (postSRCtoMW(ID, API, MWEDITTOKEN) == "Success") {
      # update Status file
      ABCunitsStatus$lastUpload[ABCunitsStatus$file == SRC] <- Sys.time()
    }
  }
}

# Save updated status file
save(ABCunitsStatus, file = "ABCunitsStatus.Rdata")


# [END]
