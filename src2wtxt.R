# src2wtxt.R
#

src2wtxt <- function(SRC) {
  # src2wtxt.R
  # Get components from the source components file passed in the parameter
  # SRC to create a BCH441 knowledge network learning unit as wikitext.
  #
  # This file implements the actual structure of the Wiki page.
  #
  # Parameters: SRC char fully qualified path of the components file.
  # Value:   char   the Wikitext
  #
  # V 1.1
  #
  # Versions:
  #    1.1 Return character string, don't write to file.
  #    1.0 Final version
  #    0.1 First version
  # Author:
  #    Boris Steipe
  # Date:
  #    2017-08-15
  # ============================================================================

  out <- character()

  txt <- '<div id="BIO">
  <div class="b1">'
  out <- c(out, txt)
  out <- c(out, include(SRC, section = "title", addMarker = FALSE))

  txt <- '  </div>

  {{Vspace}}
  '
  out <- c(out, txt)

  out <- c(out, '<div class="keywords">')
  out <- c(out, '<b>Keywords:</b>&nbsp;')
  out <- c(out, sprintf("%s", include(SRC,
                                      section = "keywords",
                                      addMarker = FALSE)))

  out <- c(out, '</div>')
  out <- c(out, vspace())

  out <- c(out, '__TOC__')
  out <- c(out, vspace())

  out <- c(out, sprintf("{{%s}}", include(SRC,
                                          section = "status",
                                          addMarker = FALSE) ))
  out <- c(out, vspace())

  out <- c(out, '</div>') # End BIO div
  out <- c(out, "<div id=\"ABC-unit-framework\">")   # Framework div to style
  # non-contents Headings

  out <- c(out, "== Abstract ==")
  out <- c(out, "<section begin=abstract />")
  out <- c(out, include(SRC, section = "abstract"))
  out <- c(out, "<section end=abstract />")
  out <- c(out, vspace())

  out <- c(out, "== This unit ... ==")
  txt <- include(SRC, section = "prerequisites")
  if (length(txt) > 0) {
    out <- c(out, "=== Prerequisites ===")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  txt <- include(SRC, section = "objectives")
  if (length(txt) > 0) {
    out <- c(out, "=== Objectives ===")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  txt <- include(SRC, section = "outcomes")
  if (length(txt) > 0) {
    out <- c(out, "=== Outcomes ===")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  txt <- include(SRC, section = "deliverables")
  if (length(txt) > 0) {
    out <- c(out, "=== Deliverables ===")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  txt <- include(SRC, section = "evaluation")
  if (length(txt) > 0) {
    out <- c(out, "=== Evaluation ===")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  out <- c(out, '</div>') # End framework div
  out <- c(out, "<div id=\"BIO\">")   # Restart BIO div

  txt <- include(SRC, section = "contents")
  if (length(txt) > 0) {
    out <- c(out, "== Contents ==")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  txt <- include(SRC, section = "further_reading", addMarker = FALSE)
  if (length(txt) > 0) {
    out <- c(out, "== Further reading, links and resources ==")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  txt <- include(SRC, section = "notes")
  if (length(txt) > 0) {
    out <- c(out, "== Notes ==")
    out <- c(out, txt)
    out <- c(out, vspace())
  }

  out <- c(out, "</div>")   # End BIO div
  out <- c(out, "<div id=\"ABC-unit-framework\">")   # Framework div part 2

  txt <- include(SRC, section = "self-evaluation")
  if (length(txt) > 0) {
    out <- c(out, "== Self-evaluation ==")
    out <- c(out, txt)
    out <- c(out, vspace())
  }
  out <- c(out, vspace())

  out <- c(out, include(SRC, section = "ask!", addMarker = FALSE))

  out <- c(out, '<div class="about">')
  out <- c(out, "<b>About ... </b><br />")
  out <- c(out, "&nbsp;<br />")

  txt <- include(SRC,
                 section = "authors",
                 addMarker = FALSE)
  if (length(txt) < 2) {
    out <- c(out, '<b>Author:</b><br />')
    out <- c(out, sprintf(":%s", txt))
  } else {
    out <- c(out, '<b>Authors:</b><br />')
    for (author in txt) {
      out <- c(out, sprintf(":%s", author))
    }
  }

  out <- c(out, '<b>Created:</b><br />')
  out <- c(out, sprintf(":%s", include(SRC,
                                       section = "created",
                                       addMarker = FALSE)))

  out <- c(out, '<b>Modified:</b><br />')
  out <- c(out, sprintf(":%s", include(SRC,
                                       section = "modified",
                                       addMarker = FALSE)))

  out <- c(out, '<b>Version:</b><br />')
  out <- c(out, sprintf(":%s", include(SRC,
                                       section = "version",
                                       addMarker = FALSE)))

  txt <- include(SRC,
                 section = "version_history",
                 addMarker = FALSE)
  out <- c(out, '<b>Version history:</b><br />')
  for (vHist in txt) {
    out <- c(out, sprintf("*%s", vHist))
  }

  out <- c(out, '</div>')

  out <- c(out, include(SRC, section = "categories", addMarker = FALSE))
  out <- c(out, include(SRC, section = "footer", addMarker = FALSE))
  out <- c(out, '</div>')  # End Framework div
  out <- c(out, '<!-- [END] -->')

  return(paste0(out, collapse = "\n"))

}

# === Legacy: function to break up contents into chunks. This never worked well
#       because MW parses upon save ... and it's not necessary since
#       text length in POST body is not limited, only in GET or POST URLs
#       (8910 characters).
#
# chunkContents <- function(s, mode = "lines") {
#   # break the string s into chunks of lines that are not longer
#   # than MAXLINES lines
#
#
#   if (mode == "lines") {
#     MAXLINES <- 10
#     v <- unlist(strsplit(s, "\n"))
#     idx <- seq(1, length(v), by = MAXLINES)
#     nBlocks <- length(idx)
#     idx <- c(idx, (length(v) + 1))
#     blocks <- character()
#     for (i in 1:nBlocks) {
#       blocks[i] <- paste0(v[idx[i]:(idx[(i+1)] - 1)], collapse = "\n")
#     }
#   } else if (mode == "sections") {
#     s  <- gsub("<!--.+?-->", "", s) # strip comments
#     blocks <- unlist(strsplit(s, "(?=\\n=)", perl = TRUE))
#     blocks <- blocks[- grep("^\\n$", blocks)]
#   } else {
#     stop("PANIC: Unknown mode")
#   }
#
#   return(blocks)
# }

# [END]
