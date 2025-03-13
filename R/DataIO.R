SaveData <- function(lData, root = here::here()) {
  iwalk(
    lData,
    function(dfData, strDomain) {
      strLayerName <- sub('_.*$', '', strDomain)
      strDomainName <- sub('^.*_', '', strDomain)

      saveRDS(
        dfData,
        file.path(
          root,
          'data',
          strLayerName,
          paste0(strDomainName, '.rds')
        )
      )
    }
  )
}

ReadData <- function(strLayer, strDomain, root = here::here()) {
  fs::path(root, "data", strLayer, strDomain, ext = "rds") %>%
    readRDS() %>%
    dplyr::as_tibble()
}

ReadAnalysisData <- function(root = here::here()) {
  fs::path(root, "data", "Analysis") %>%
  fs::dir_ls() %>%
    purrr::map(function(rdsFile) {
      metricName <- fs::path_file(rdsFile) %>%
        fs::path_ext_remove()
      readRDS(rdsFile)$Analysis_Input %>%
        dplyr::mutate(MetricID = paste0("Analysis_", metricName)) %>%
        dplyr::as_tibble()
    }) %>%
    purrr::list_rbind()
}
