library(purrr)
library(dplyr)
load_all('~/dev/gsm.kri') # library(gsm.kri)
load_all('~/dev/gsm.app') # library(gsm.app)
# load_all('~/dev/gsm.ae') # library(gsm.ae)

lAnalysisData <- 'data/Analysis' %>%
    list.files(full.names = TRUE) %>%
    setNames(basename(.) %>% sub('\\..*$', '', .)) %>%
    map(readRDS)

dfAnalysisInput <- lAnalysisData %>%
    imap(~
        .x$Analysis_Input %>%
            mutate(MetricID = .y )
    ) %>%
    list_rbind()

lReportingData <- 'data/Reporting' %>%
    list.files(full.names = TRUE) %>%
    setNames(basename(.) %>% sub('\\..*$', '', .)) %>%
    map(readRDS)

# shiny::shinyApp
run_gsm_app(
    dfAnalysisInput,
    lReportingData$Bounds,
    lReportingData$Groups,
    lReportingData$Metrics,
    lReportingData$Results,
    function(
        strDomain,
        strSiteID = NULL,
        strSubjectID = NULL
    ) {
        strDomain <- switch(strDomain,
            SUBJ = 'DM',
            strDomain
        )

        # Load data.
        dfDomain <- file.path('data', 'Mapped', paste0(strDomain, '.rds')) %>%
            readRDS() %>%
            mutate(
                SubjectID = USUBJID,
                across(ends_with('date'), as.Date),
                across(ends_with('dt'), as.Date)
            )

        # Subset on site ID, if available.
        if (!is.null(strSiteID)) {
            dfDomain <- dfDomain %>%
                dplyr::filter(
                    .data$SITEID == strSiteID
                )
        }

        # Subset on subject ID, if available.
        if (!is.null(strSubjectID)) {
            dfDomain <- dfDomain %>%
                dplyr::filter(
                    .data$USUBJID == strSubjectID
                )
        }

        return(dfDomain)
    },
    chrDomains = c(
        #'SUBJ',
        #'DS',
        #'LB',
        #'AE'
        'SUBJ' = 'Subjects',
        'DS' = 'Disposition',
        'LB' = 'Labs',
        'AE' = 'Adverse Events'
    ),
    lPlugins = list(pluginAE())
)
