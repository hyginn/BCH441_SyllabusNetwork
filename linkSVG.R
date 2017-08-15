# linkSVG.R
# Create hyperlinks to all SVG text elements.
#
# V 0.1
#
# Versions:
#    0.1 First version
# Author:
#    Boris Steipe
# Date:
#    2017-08-13
# ==============================================================================

SVGFILE <- "ABC-units.sif_4.svg"
LINKEDFILE <- "ABC-units_map.svg"

WIKIURL <- "http://steipe.biochemistry.utoronto.ca/abc"


svg <- readLines(SVGFILE)


patt <- "^<text "
for (i in grep(patt, svg) ) {

  textLine <- svg[i]

  # extract the ID
  M <- regexec(">(.+) *</text>$", textLine, perl = TRUE)
  ID <- regmatches(textLine, M)[[1]][2]
  ID <- gsub("^\\s*", "", ID)
  ID <- gsub("\\s*$", "", ID)
  KW <- include(sprintf("../components/%s.components.wtxt", ID),
                section = "keywords",
                addMarker = FALSE)
  TOOLTIP <- sprintf("xlink:title=\"%s\"", KW)
  # add a link tag
  aBegin <- sprintf("<a xlink:href=\"%s/index.php/%s\" %s>",
                    WIKIURL,
                    ID,
                    TOOLTIP)
  aEnd <- "</a>"

  # write it back to svg
  svg[i] <- paste0(aBegin, textLine, aEnd)
}

writeLines(svg, LINKEDFILE)


# [END]
