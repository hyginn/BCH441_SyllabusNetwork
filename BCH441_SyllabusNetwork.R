# BCH441_SyllabusNetwork.R
#
# Purpose: Initialize and build a syllabus network as a series of R-scripts
#             and contents-files that create Wikitext.
#
# Version: 0.1
#
# Date:    2017-08-06
# Author:  Boris Steipe <boris.steipe@utoronto.ca>
#
# V 0.1    First code
#
# TODO:
#    Explore MediaWiki API to upload files from components directory
#

# == FUNCTIONS =================================================================

# utility functions are loaded from .utilities.R

# == PROCESS ===================================================================

# 1: generating components files from topics
# Initial expansion of topics to .wtxt files in the ../components directory
# The components structure is taken from the 00-unit-metascript file. It
# is populated only with ID and keywords from the 01-topics file. The result
# is a set of component files that contain the contents for the unit.

# myTopics <- readLines(con = "../units/01-topics.txt")
# for (topic in myTopics) {
#   s <- unlist(strsplit(topic, "\t"))
#   ID <- s[1]
#   KEYWORDS <- s[2]
#   source("00-unit_metascript.R")
# }

# 2: manually edit components. Add prerequisites, title ...

# 3: generate wikitext
# Process components to wikitext, overwrite. Open all components-files in the
# directory and build a wikitext source file according to the structure and
# include-directives specified in src2wtext.R
mySources <- list.files(path = "../components",
                        pattern = ".*\\.components\\.wtxt$",
                        full.names = TRUE)

for (SRC in mySources) {
  source("src2wtxt.R")
}

# === PATCHES ==================================================================
# Patches of components files.


## === Patch in separate ask! section before footer
#mySources <- list.files(path = "../test",
# mySources <- list.files(path = "../components",
#                         pattern = ".*\\.components\\.wtxt$",
#                         full.names = TRUE)
#
# for (SRC in mySources) {
#   txt <- readLines(SRC)
#
#   # identify section to be patched:
#   #    first is first line to remove.
#   #    last is last line to remove.
#   patt <- "^== Footer ==$"
#   first <- grep(patt, txt)
#   if (length(first) == 0) {
#     stop("PANIC: remove anchor beginning not found.")
#   } else if (length(first) > 1) {
#     stop("PANIC: remove anchor beginning found more than once.")
#   }
#   pre <- txt[1:(first - 1)]
#
#   patt <- "^<section begin=footer />$"
#   last <- grep(patt, txt)
#   if (length(last) == 0) {
#     stop("PANIC: remove anchor end not found.")
#   } else if (length(last) > 1) {
#     stop("PANIC: remove anchor end found more than once.")
#   }
#   post <- txt[(last + 1):length(txt)]
#
#   insert <- character()
#   insert <- c(insert, "== ask! ==")
#   insert <- c(insert, "<section begin=ask! />")
#   insert <- c(insert,
#               'include("ABC-unit_components.wtxt", section = "ABC-unit_ask")')
#   insert <- c(insert, "<section end=ask! />")
#   insert <- c(insert, "")
#   insert <- c(insert, "== Footer == <!-- patched 01 -->")
#   insert <- c(insert, "<section begin=footer />")
#
#   txt <- c(pre, insert, post)
#
#   writeLines(txt, SRC)
# }
## === end ask! section patch

## === Patch in new type section before status
# mySources <- list.files(path = "../test",
# mySources <- list.files(path = "../components",
#                         pattern = ".*\\.components\\.wtxt$",
#                         full.names = TRUE)
#
# for (SRC in mySources) {
#   txt <- readLines(SRC)
#
#   # identify section to be patched:
#   #    first is first line to remain.
#   #    last is last line to remain.
#   patt <- "^<section end=title />$"
#   first <- grep(patt, txt)
#   if (length(first) == 0) {
#     stop("PANIC: anchor beginning not found.")
#   } else if (length(first) > 1) {
#     stop("PANIC: anchor beginning found more than once.")
#   }
#   pre <- txt[1:first]
#
#   patt <- "^== Status ==$"
#   last <- grep(patt, txt)
#   if (length(last) == 0) {
#     stop("PANIC: anchor end not found.")
#   } else if (length(last) > 1) {
#     stop("PANIC: anchor end found more than once.")
#   }
#   post <- txt[last:length(txt)]
#
#   insert <- character()
#   insert <- c(insert, "")
#   insert <- c(insert, "== Type ==")
#   insert <- c(insert, "UNIT / INTEGRATOR / MILESTONE")
#   insert <- c(insert, "<section begin=type />")
#   insert <- c(insert, "UNIT")
#   insert <- c(insert, "<section end=type />")
#   insert <- c(insert, "")
#
#   txt <- c(pre, insert, post)
#
#   writeLines(txt, SRC)
# }
# === end type section patch


# === UPDATE THE UNITS MAP =====================================================

# create a label-width attribute column for cytoscape

# setup a dummy plot for calculating strwidth in user coordinates
# This is scaled so that the string "BIN-PDB" comes out at 120 units.
plot(1, xlim=c(0,784), ylim=c(0,784))
# strwidth("BIN-PDB")
OUTFILE <- "ABC-units.strwidth.txt"
SIFfileName <- "ABC-units.sif_4.sif"
SIFdf <- read.delim(SIFfileName,
                    header = FALSE,
                    stringsAsFactors = FALSE)
allNodes <- sort(unique(c(SIFdf$V1, SIFdf$V3)))

nodeWidths <- "name\tstrwidth" # strwidth attribute vector header row

for (i in seq_along(allNodes)) {
  nodeWidths[(i + 1)] <- paste0(allNodes[i],
                          "\t",
                          as.character(round(strwidth(allNodes[i]))))
}
writeLines(nodeWidths, OUTFILE)
# Next, use the file -> import -> Table -> File option in cytoscape to read the
# file. We created the correct header row, so just use default options and click
# ok. Then click on the "mapping" field of the style, select the column you just
# imported, and select "passtrough mapping". The value in the column for each
# node is then "passed through" directly to be used as the style attribute for
# that node.


# create a color attribute column for cytoscape labels

OUTFILE <- "ABC-units.label-colours.txt"
SIFfileName <- "ABC-units.sif_4.sif"
SIFdf <- read.delim(SIFfileName,
                    header = FALSE,
                    stringsAsFactors = FALSE)
allNodes <- sort(unique(c(SIFdf$V1, SIFdf$V3)))

colour <- "name\tcolour" # colour attribute vector header row

for (i in seq_along(allNodes)) {
  SRC <- sprintf("../components/%s.components.wtxt", allNodes[i])
  status <- include(SRC, section = "status", addMarker = FALSE)
  type   <- include(SRC, section = "type",   addMarker = FALSE)

  if (type == "INTEGRATOR") {
    nodeColour <- "#e19fa7"
  } else if (type == "MILESTONE") {
    nodeColour <- "#97bed5"
  } else if (type == "UNIT") {
    if (status == "STUB") {
      nodeColour <- "#f2fafa"
    } else if (status == "DEV") {
      nodeColour <- "#d9ead5"
    } else if (status == "LIVE") {
      nodeColour <- "#b3dbce"
    } else if (status == "REVISE") {
      nodeColour <- "#f4d7b7"
    } else {
      stop(sprintf("PANIC: Status attribute not recognized in %s"), SRC)
    }
  } else {
    stop(sprintf("PANIC: Type attribute not recognized in %s"), SRC)
  }
  colour[(i + 1)] <- paste0(allNodes[i],
                          "\t",
                          nodeColour)
}
writeLines(colour, OUTFILE)

# Next, use the file -> import -> Table -> from File option in cytoscape to read
# the file, click ok. Then click on the "mapping" field of the style, select the
# column you just imported, and select "passtrough mapping". The value in the
# column for each node is then "passed through" directly to be used as the style
# attribute for that node.


# === WORKFLOWS ================================================================

# === UPDATE MAP ===============================================================

# Edit unit components in components directory
# Edit Network in Cytoscape
#
# Export Network to File -> SIF
#
# Update prerequisites: step through the section in wtxt2graph.R to compute
#    a new prereq block from the information found in the SIF file and
#    overwrite the original components file with the new block.
#
# Create new label box sizes:
#    Execute the code above to produce a new "ABC-units.strwidth.txt"
# Create new label colours:
#    Execute the code above to produce a new "ABC-units.label-colours.txt"
# Add attribute columns to cytoscape session: delete existing and import new.
#    Since the styles have already been defined, that should automatically
#    update the display.
#
# Use the zoom-out-to-display-all option.
# Rename the existing "ABC-units_map.svg" to a backup version.
# Export Network to file, choose SVG format.
#
# Run the code in linkSVG.R
#
# Upload "ABC-units_map.svg" to the Wiki.
#

# ==== ADD A NEW UNIT ================================================
#
# - copy an existing component file with STUB status
# - give it the new name
# - add a record to ABCunitsStatus
# - add a node by that name in Cytoscape
# - add the relationships
# - update the map
# - edit contents ...
#

# ==== DELETE A UNIT ================================================
# - delete the components file
# - delete the record in ABCunitsStatus
# - delete the node in cytoscape
# - update the map
# - delete the page on the Wiki
#

# ==== RENAME A UNIT ================================================
# - rename the components file
# - rename the file in ABCunitsStatus
# - rename the node in Cytoscape
# - update the map
# - move the page on the Wiki



# ==== UPLOAD FILES TO THE WIKI ================================================
# Upload a wikitext file to the Wiki via the text API
#

# Prepare connection
API  <- include("~/.MWcredentials.txt",
                section = "course_api",
                addMarker = FALSE)
MWEDITTOKEN <- getMWedittoken(API)

# update all units on the Wiki for which the modified date is after the update
# date recorded in ABCunitsStatus
source("updateComponents.R")





# === TESTS ====================================================================
SRC <- "testComponents.txt"

include(SRC, section = "missing-begin")
include(SRC, section = "more-than-one-begin")
include(SRC, section = "missing-end")
include(SRC, section = "more-than-one-end")

include(SRC, section = "single-value")
as.numeric(include(SRC, section = "single-value", addMarker = FALSE))

include(SRC, section = "two-lines")

include(SRC, section = "one-level-include-beginning")
include(SRC, section = "one-level-include-middle")
include(SRC, section = "one-level-include-ending")
include(SRC, section = "one-level-include-two-includes")

include(SRC, section = "infinite-recursion")
include(SRC, section = "circular-recursion-A")

include(SRC, section = "two-level-include-A")

# [END]
