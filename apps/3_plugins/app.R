# Launch the ShinyApp
library(gsm.app)
library(gsm.ae)
library(fs)
library(purrr)
library(dplyr)
library(here)
source(here::here("R/DataIO.R"))

# (re)Load Workshop Data ----
dfAnalysisInput <- ReadAnalysisData()
dfBounds <- ReadData("Reporting", "Bounds")
dfGroups <- ReadData("Reporting", "Groups")
dfMetrics <- ReadData("Reporting", "Metrics")
dfResults <- ReadData("Reporting", "Results")

# Tell the app how to fetch domain data ----
fetchData <- function(strDomain, strSiteID = NULL, strSubjectID = NULL) {
  # gsm.ae plugin has a requirement for a "SUBJ" domain
  if (strDomain == "SUBJ") {
    strDomain <- "DM"
  }

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
    AE = "Adverse Events",
    LB = "Lab",
    SUBJ = "Subject Metadata",
    DS = "Study Completion"
  ),
  lPlugins = list(pluginAE()),
  strTitle = "Plugin Example",
  strFaviconColor = "purple"
)
