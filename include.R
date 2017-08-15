# include.R

include <- function(fn, section = "", addMarker = TRUE) {
  # include a source-document or a section from a components document.
  # Function handles expansion of recursive included text.
  # fn:        char  file name of the source file
  # section:   char  section name of a component to be included. If empty, the
  #                      whole document will be included
  # addMarker: bool  if TRUE, add a marker to indicate where the included
  #                      text came from.
  #
  # value: character() if nothing is to be included, a vector of character
  #            otherwise.

  # read file from fn, validate
  s <- readLines(con = fn)
  first <- 1
  last <- length(s)
  # ToDo: validate ...

  # if section is not empty, find section first and last element
  if (section != "") {

    patt <- paste0("<section\\s+begin\\s*=\\s*", section, "\\s+/\\s*>")
    first <- grep(patt, s) + 1
    if (length(first) == 0) {
      stop("PANIC: section begin-tag not found.")
    } else if (length(first) > 1) {
      stop("PANIC: section begin-tag found more than once.")
    }

    patt <- paste0("<section\\s+end\\s*=\\s*", section, "\\s+/\\s*>")
    last <- grep(patt, s) - 1
    if (length(last) == 0) {
      stop("PANIC: matching section end-tag not found.")
    } else if (length(last) > 1) {
      stop("PANIC: matching section end-tag found more than once.")
    }
  }

  # Shortcut: if there is not at least one line of contents, return
  # a 0-length vector
  if (last < first) {
    return(character())
  }

  # Create inclusion marker
  if (addMarker == TRUE) {
    txt <- sprintf("<!-- included from \"%s\", section: \"%s\" -->",
                   fn,
                   section)
  } else {
    txt <- character()
  }

  # add subset of s from first to last
  txt <- c(txt, s[first:last])

  # iterate and recurse: assign index of first match while
  # there are matches found to include() commands
  while (! is.na(iInc <- grep("^\\s*include(.+)\\s*$", txt)[1]) )  {

    includeExpression <- txt[iInc]

    # expand this inclusion recursively
    expanded <- eval(parse(text = includeExpression))

    # splice expanded inclusion(s) into txt
    if (iInc == 1) {
      pre <- character()
    } else {
      pre <- txt[1:(iInc - 1)]
    }

    if (iInc == length(txt)) {
      post <- character()
    } else {
      post <- txt[(iInc + 1):length(txt)]
    }

    txt <- c(pre, expanded, post)
  } # end while (...)

  return(txt)
}

# [END]
