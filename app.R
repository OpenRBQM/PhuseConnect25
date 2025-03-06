library(gsm.app)
library(fs)
library(purrr)
library(dplyr)
source('R/DataIO.R')

# library(gsm.ae)
dfAnalysisInput <- ReadAnalysisData()

dfBounds <- ReadData("Reporting", "Bounds")
dfGroups <- ReadData("Reporting", "Groups")
dfMetrics <- ReadData("Reporting", "Metrics")
dfResults <- ReadData("Reporting", "Results")

fetchData <- function(strDomain, strSiteID = NULL, strSubjectID = NULL) {
  strDomain <- switch(strDomain, SUBJ = 'DM', STUDCOMP = 'DS', strDomain)
  # Load data.
  dfDomain <- ReadData("Mapped", strDomain) %>%
    mutate(
      SubjectID = USUBJID
    )

  # Subset on site ID, if given.
  if (!is.null(strSiteID)) {
    dfDomain <- dplyr::filter(dfDomain, .data$SITEID == strSiteID)
  }

  # Subset on subject ID, if given.
  if (!is.null(strSubjectID)) {
    dfDomain <- dplyr::filter(dfDomain, .data$USUBJID == strSubjectID)
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
  # TODO: figure out how to add new domains
  chrDomains = c(
    'SUBJ',
    'STUDCOMP',
    'LB',
    'AE'
  ) #,
  # lPlugins = list(pluginAE())
)
