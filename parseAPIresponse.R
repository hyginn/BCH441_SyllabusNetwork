# parseAPIresponse.R
#

parseAPIresponse <- function(r, key) {
  # Parse the MediaWiki API response r for the value associated with key.
  #
  # This function needs library(httr)
  #
  # Parameters:   r     the response returned from a GET or POST call to the
  #                        MediaWiki API.
  #               key   a key in the response
  # Value: char         the value associated with the key or character() if
  #                        the key was not found
  #
  # V 1.0
  #
  # Versions:
  #    1.0 First version
  # Author:
  #    Boris Steipe
  # Date:
  #    2017-08-16
  # ============================================================================

  s <- content(r, "text")

  patt <- sprintf('%s\\s*=\\s*\\"([^\\"]*)', key)
  m <- regexec(patt, s, perl = TRUE)
  val <- regmatches(s, m)[[1]][2]

  if(is.na(val)) {
    val <- character()
  }

  return(val)
}

# [END]
