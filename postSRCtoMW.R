# postSRCtoMW.R
#

postSRCtoMW <- function(ID,
                        API,
                        ET,
                        PATH = "../components/",
                        silently = FALSE) {
  #
  # Upload a page constructed from components at SRC to the MediaWiki
  # instance identified with the URL API using the edittoken ET.
  #
  # Uses package::httr functions.
  #
  # Parameters: ID         char   The page ID
  #             API        char   The URL of the API script
  #             ET         char   The edittoken
  #             PATH       char   path for the components file
  #             silently   bool   Whether to supress printing result status
  #
  # Value: char  return-status
  #        Invoked for the side-effect of creating or overwriting
  #          the page with name ID on the Wiki and printing the
  #          status of the POST response.
  #
  # V 1.0
  #
  # Versions:
  #    1.0 Final version
  # Author:
  #    Boris Steipe
  # Date:
  #    2017-08-18
  # ============================================================================

  SRC <- paste0(PATH, ID, ".components.wtxt")

  POSTbody <- list(action = "edit",
                   title = ID,
                   text = src2wtxt(SRC),
                   format = "xml",
                   token = ET)

  # Form encoded
  r <- POST(API, body = POSTbody, encode = "form")
  result <- parseAPIresponse(r, "result")
  if (! silently) {
    cat(sprintf("postSRCtoMW > %s: \"%s\"\n", ID, result))
  }
  return(result)
}

# [END]
