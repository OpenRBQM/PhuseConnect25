SaveData <- function(lData) {
    iwalk(
        lData,
        function(dfData, strDomain) {
            strLayerName <- sub('_.*$', '', strDomain)
            strDomainName <- sub('^.*_', '', strDomain)

            saveRDS(
                dfData,
                file.path(
                    'data',
                    strLayerName,
                    paste0(strDomainName, '.rds')
                )
            )
        }
    )
}

ReadData <- function(strLayer, strDomain) {
  fs::path("data", strLayer, strDomain, ext = "rds") %>%
    readRDS() %>%
    dplyr::as_tibble()
}

ReadAnalysisData <- function() {
  fs::dir_ls("data/Analysis") %>%
    purrr::map(function(rdsFile) {
      metricName <- fs::path_file(rdsFile) %>%
        fs::path_ext_remove()
      readRDS(rdsFile)$Analysis_Input %>%
        dplyr::mutate(MetricID = paste0("Analysis_", metricName)) %>%
        dplyr::as_tibble()
    }) %>%
    purrr::list_rbind()
}
