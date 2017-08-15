# wtxt2graph.R
#
# Create a graph from unit relationships and plot to svg
# ==============================================================================
#

library(igraph)

myComponentDirectory <- "../components"
allComponentFiles <- list.files(path = myComponentDirectory,
                                pattern = "\\.components\\.wtxt$",
                                full.names = TRUE)

# First test: are the filenames and Unit-IDs the same?
allIDs <- gsub(paste0(myComponentDirectory, "/"), "", allComponentFiles)
allIDs <- gsub("\\.components\\.wtxt$", "", allIDs)

for (i in seq_along(allComponentFiles)) {
  # fetch the ID
  myID <- include(allComponentFiles[i], section = "id", addMarker = FALSE)
  if (myID != allIDs[i]) {
    stop(sprintf("PANIC: Mismatch of filename and unit ID in %s",
                 allComponentFiles[i]))
  }
}
# =====
# Second test: do all the referenced internal prerequisite links have
# corresponding filenames?

pattern <- "\\[{2}(.+)(]{2}|\\|)"  # match between two opening brackets
                                   # and two closing brackets or |
for (i in seq_along(allComponentFiles)) {
  # fetch the prerequisites section
  myPrereq <- include(allComponentFiles[i],
                      section = "prerequisites",
                      addMarker = FALSE)

  for (j in seq_along(myPrereq)) {
    M <- regexec(pattern, myPrereq[j])
    myPage <- regmatches(myPrereq[j], M)[[1]][2]
    if (! is.na(myPage)) {
      pagePatt <- sprintf("^")
      if (! myPage %in% allIDs) {
        stop(sprintf("Prerequisite %s referenced in %s not found.",
                     myPrereq[j],
                     allComponentFiles[i]))
      }
    }
  }
}

# build edgelist
myEdgelist <- data.frame(unit = character(),
                         prereq = character(),
                         stringsAsFactors = FALSE)

pattern <- "\\[{2}(.+)(]{2}|\\|)"  # match between two opening brackets
                                   # and two closing brackets or |
for (i in seq_along(allComponentFiles)) {
  # fetch the prerequisites section
  myPrereq <- include(allComponentFiles[i],
                      section = "prerequisites",
                      addMarker = FALSE)

  for (j in seq_along(myPrereq)) {
    M <- regexec(pattern, myPrereq[j])
    myPage <- regmatches(myPrereq[j], M)[[1]][2]
    if (! is.na(myPage)) {
      myEdgelist <- rbind(myEdgelist,
                          data.frame(unit = include(allComponentFiles[i],
                                                    section = "id",
                                                    addMarker = FALSE),
                                     prereq = myPage,
                                     stringsAsFactors = FALSE))
    }
  }
}

# ====
# export graph to cytoscape .sif

mySIF <- character()
for (i in 1:nrow(myEdgelist)) {
  mySIF[i] <- sprintf("%s\trequires\t%s",
                      myEdgelist$unit[i],
                      myEdgelist$prereq[i])
}

writeLines(mySIF, con = "ABC-units.sif")

# =====
#  Update unit prerequisites from sif file produced by cytoscape. This updates
#  the listed prerequisites in the components if any new edges have been added
#  and/or existing edges have been deleted. It does not create new components
#  files, if new nodes have been introduced, rather the existence of new node
#  names throwas an error - create new nodes by hand first.
# ==============================================================================
# 1. step: import .sif file into SIFdf

SIFfileName <- "ABC-units.sif_4.sif"
SIFdf <- read.delim(SIFfileName,
                    header = FALSE,
                    stringsAsFactors = FALSE)

# Cytoscape added new edges are not of type "requires" - so the following test
# does not work. #e merely drop the relationship column.
# if (! all(SIFdf$V2 == "requires")) {
#   stop("PANIC: At least one relationship is not \"requires\".")
# }
SIFdf <- SIFdf[,-2]
colnames(SIFdf) <- c("unit", "prereq")
SIFdf <- SIFdf[order(paste0(SIFdf$unit, SIFdf$prereq)),]

# 2. step: verify that component files exist for all nodes mentioned in
# sif file

myComponentDirectory <- "../components"
# myComponentDirectory <- "../test"
allComponentFiles <- list.files(path = myComponentDirectory,
                                pattern = "\\.components\\.wtxt$",
                                full.names = TRUE)

allUnits <- gsub(paste0(myComponentDirectory, "/"), "", allComponentFiles)
allUnits <- gsub("\\.components\\.wtxt$", "", allUnits)
any(duplicated(allUnits))

SIFunits <- unique(SIFdf$unit)
for (i in seq_along(SIFunits)) {
  if (! SIFunits[i] %in% allUnits) {
    stop(sprintf("PANIC: SIF unit %s not in component directory.",
                 SIFunits[i]))
  }
}

SIFprereqs <- unique(SIFdf$prereq)
for (i in seq_along(SIFprereqs)) {
  if (! SIFprereqs[i] %in% allUnits) {
    stop(sprintf("PANIC: prereq %s not in component directory.",
                 SIFprereqs[i]))
  }
}

# 3. step: verify that all component files are referenced in SIF file
allNodes <- unique(c(SIFunits, SIFprereqs))
for (i in seq_along(allUnits)) {
  if (! allUnits[i] %in% allNodes) {
    cat(sprintf("CAVE: component file %s not referenced in SIF file.\n",
                 allUnits[i]))
  }
}

# for each unique unit that has prerequisites
for (id in SIFunits) {
  # read the components file into txt
  currentFile <- paste0(myComponentDirectory, "/", id, ".components.wtxt")
  txt <- readLines(currentFile)

  # Identify the prerequisites block: It follows the notes-prerequisistes
  # include-statement and has at least one *[[...]] link
  patt <- 'include\\("ABC-unit_components.wtxt", section = "notes-prerequisites"\\)'
  first <- grep(patt, txt)

  last <- first + 1
  while(grepl("*\\[{2}", txt[last])) {
    last <- last + 1
  }

  if(length(first) != 1 || length(last) != 1 || (! last > (first + 1))) {
    stop(sprintf("PANIC: %s%s%s",
                 "Error identifying prerequisites block for id:",
                 id,
                 ". Review source file."))
  }

  # make a new prerequisites block
  pBlock <- sprintf("*[[%s]]", SIFdf$prereq[SIFdf$unit == id])

  # splice the new prerequisites block into txt
  txt <- c(txt[1:first], pBlock, txt[last:length(txt)])

  # write txt to components file
  writeLines(txt, currentFile)
}




# [END]



