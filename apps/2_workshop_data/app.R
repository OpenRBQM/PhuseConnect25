# Launch the ShinyApp (Do not remove this comment )
library(gsm.app)
library(gsm.ae) # load_all('../gsm.ae')
library(fs)
library(purrr)
library(dplyr)
library(here)
source(here::here("R/DataIO.R"))

# library(gsm.ae)
dfAnalysisInput <- ReadAnalysisData()

dfBounds <- ReadData("Reporting", "Bounds")
dfGroups <- ReadData("Reporting", "Groups")
dfMetrics <- ReadData("Reporting", "Metrics")
dfResults <- ReadData("Reporting", "Results")

fetchData <- function(strDomain, strSiteID = NULL, strSubjectID = NULL) {
  if (strDomain == 'SUBJ')
    strDomain <- 'DM'

  # Load data.
  dfDomain <- ReadData("Mapped", strDomain)

  dfDomain <- dfDomain %>%
    dplyr::rename(
      "SubjectID" = "USUBJID"
    )

  # Subset on site ID, if given.
  if (!is.null(strSiteID) && "SITEID" %in% colnames(dfDomain)) {
    dfDomain <- dplyr::filter(dfDomain, .data$SITEID == strSiteID)
  }

  # Subset on subject ID, if given.
  if (!is.null(strSubjectID) && "SubjectID" %in% colnames(dfDomain)) {
    dfDomain <- dplyr::filter(dfDomain, .data$SubjectID == strSubjectID)
  }

  return(dfDomain)
}

run_gsm_app(
  dfAnalysisInput,
  dfBounds,
  dfGroups,
  dfMetrics,
  dfResults,
  fetchData,
  chrDomains = c(
    SUBJ = "Subject Metadata",
    DS = "Study Disposition",
    LB = "Labs",
    AE = "Adverse Events"
  ),
  lPlugins = list(pluginAE())
)
