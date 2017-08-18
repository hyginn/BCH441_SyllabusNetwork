# getMWedittoken.R
#

getMWedittoken <- function(API, credentials = "~/.MWcredentials.txt") {
  # Login to a MediaWiki instance at API and return an edittoken.
  # Uses package::httr functions.
  #
  # Parameters: API   char  The URL of the API script
  # Value:   char   The edittoken.
  #
  # Note: Edittokens that are passed in the URL (e.g. for GET) need to be
  #         URLencoded. Edittokens that are passed in the body of a POST
  #         are passed as-is.
  #
  # Note: This process is specific to the MW instance currently running
  #         the ABC Wiki. Later instances have changed the process.
  #         Cf: https://www.mediawiki.org/wiki/API:Tokens
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

  USER <- include(credentials, section = "user", addMarker = FALSE)
  PASS <- include(credentials, section = "pass", addMarker = FALSE)

  # request a login token
  CMD <- sprintf("action=login&lgname=%s", USER)
  r <- POST(paste0(API, "?", CMD, "&format=xml"))
  result <- parseAPIresponse(r, "result")
  if ( length(result) == 0 || result != "NeedToken") {
    stop("PANIC: Failed to retrieve login token from API.")
  }
  TOKEN <- parseAPIresponse(r, "token")

  # use the login token to log in
  CMD <- sprintf("action=login&lgtoken=%s&lgname=%s&lgpassword=%s%s",
                 TOKEN,
                 USER,
                 URLencode(PASS),
                 "&rememberMe=1")
  r <- POST(paste0(API, "?", CMD, "&format=xml"))
  result <- parseAPIresponse(r, "result")
  if ( length(result) == 0 || result != "Success") {
    stop("PANIC: Failed to login via API.")
  }

  # Request an edit token
  CMD <- sprintf("action=tokens")
  r <- POST(paste0(API, "?", CMD, "&format=xml"))
  ET <- parseAPIresponse(r, "edittoken")
  if ( length(result) == 0 ) {
    stop("PANIC: Failed to retrieve edittoken.")
  }
  if ( ! grepl("^[0-9a-f]+\\+\\\\$", ET)) {
    stop(sprintf("PANIC: edittoken \"%s\" malformed.", ET))
  }
  return(ET)
}

# [END]
