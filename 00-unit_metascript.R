# unit-metascript.R
# This script will access the global variables ID and KEYWORDS.
# It will then generate a wikitext file that contains the contents
# components for a BCH441 knowledge network learning unit.
#
# V 0.1
#
# Versions:
#    0.1 First version
# Author:
#    Boris Steipe
# Date:
#    2017-08-05
# ==============================================================================

OUTFILE <- sprintf("../components/%s.components.wtxt", ID)

out <- character()

out <- c(out, "== ID ==")
out <- c(out, "<section begin=id />")
out <- c(out, ID)
out <- c(out, "<section end=id />")
out <- c(out, "")

out <- c(out, "== Keywords ==")
out <- c(out, "<section begin=keywords />")
out <- c(out, KEYWORDS)
out <- c(out, "<section end=keywords />")
out <- c(out, "")

txt <- '
== Title ==
<section begin=title />
Title
<section end=title />

== Status ==
STUB / DEV / LIVE / REVISE
<section begin=status />
STUB
<section end=status />

== Abstract ==
<section begin=abstract />
...
<section end=abstract />

== Authors ==
<section begin=authors />
Boris Steipe <boris.steipe@utoronto.ca>
<section end=authors />

== Created ==
<section begin=created />
2017-08-05
<section end=created />

== Modified ==
<section begin=modified />
2017-08-05
<section end=modified />

== Version ==
<section begin=version />
0.1
<section end=version />

== Version history ==
<section begin=version_history />
0.1 First stub
<section end=version_history />

== Prerequisites ==
<section begin=prerequisites />
<!--
include("ABC-unit_components.wtxt", section = "notes-no_prerequisites")
include("ABC-unit_components.wtxt", section = "notes-external_prerequisites")
include("ABC-unit_components.wtxt", section = "notes-prerequisites")
*[[...]]
-->
<section end=prerequisites />

== Objectives ==
<section begin=objectives />
...
<section end=objectives />

== Outcomes ==
<section begin=outcomes />
...
<section end=outcomes />

== Deliverables ==
<section begin=deliverables />
include("ABC-unit_components.wtxt", section = "deliverables-time_management")
include("ABC-unit_components.wtxt", section = "deliverables-journal")
include("ABC-unit_components.wtxt", section = "deliverables-insights")
<section end=deliverables />

== Evaluation ==
<section begin=evaluation />
include("ABC-unit_components.wtxt", section = "eval-none")
<section end=evaluation />

== Contents ==
<section begin=contents />
...
<section end=contents />

== Self evaluation ==
<section begin=self-evaluation />
<!--
=== Question 1===

Question ...

<div class="toccolours mw-collapsible mw-collapsed" style="width:800px">
Answer ...
<div class="mw-collapsible-content">
Answer ...

</div>
  </div>

  {{Vspace}}

-->
<section end=self-evaluation />

== Further reading, links and resources ==
<section begin=further_reading />
<!-- {{#pmid: 19957275}} -->
<!-- {{WWW|WWW_GMOD}} -->
<!-- <div class="reference-box">[http://www.ncbi.nlm.nih.gov]</div> -->
<section end=further_reading />

== Notes ==
<section begin=notes />
include("ABC-unit_components.wtxt", section = "notes")
<section end=notes />

== Categories ==
<section begin=categories />
[[Category:ABC-units]]
<section end=categories />

== Footer ==
<section begin=footer />
include("ABC-unit_components.wtxt", section = "ABC-unit_footer")
<section end=footer />

'
out <- c(out, txt)

out <- c(out, "<!-- [END] -->")

writeLines(out, con = OUTFILE)



# [END]
