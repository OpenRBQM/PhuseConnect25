library(purrr)
library(dplyr)
library(gsm.core)
library(gsm.mapping)
library(gsm.kri)
library(gsm.reporting)
library(magrittr)
library(here)
source('R/DataIO.R')

# 0. Input data
# ----

# Create a data specification from the data mapping workflows.
lDataSpec <- CombineSpecs(
    gsm.core::MakeWorkflowList(
        strPath = 'workflows/1_mappings',
        strPackage = NULL
    )
)

# Ingest each data domain and apply its data specification.
lRawData <- Ingest(
    list(
        SDTM_TS = readRDS('data/SDTM/ts.rds'),
        SDTM_DM = readRDS('data/SDTM/dm.rds'),
        SDTM_DS = readRDS('data/SDTM/ds.rds'),
        SDTM_LB = readRDS('data/SDTM/lb.rds'),
        SDTM_AE = readRDS('data/SDTM/ae.rds')
    ),
    lDataSpec,
    'SDTM'
)

# 1. Mapped data
# ----

lMappingWorkflows <- gsm.core::MakeWorkflowList(
    strPath = 'workflows/1_mappings',
    strPackage = NULL
)

lMappedData <- lMappingWorkflows %>%
    gsm.core::RunWorkflows(lRawData) %T>%
    SaveData()

# 2. Analysis Data
# ----

lAnalysisWorkflows <- gsm.core::MakeWorkflowList(
    strPath = 'workflows/2_metrics',
    strPackage = NULL
)

lAnalysisData <- lAnalysisWorkflows %>%
    gsm.core::RunWorkflows(lMappedData) %T>%
    SaveData()

# 3. Reporting data
# ----

lReportingWorkflows <- gsm.core::MakeWorkflowList(
    strPath = 'workflows/3_reporting',
    strPackage = NULL
)

lReportingData <- lReportingWorkflows %>%
    gsm.core::RunWorkflows(
        c(
            lMappedData, # mapped CTMS data
            list(
                lAnalysisWorkflows = lAnalysisWorkflows, # metric metadata
                lAnalysisData = lAnalysisData # analysis data
            )
        )
    ) %T>%
    SaveData()

# 4. Output
# ----

lModuleWorkflows <- gsm.core::MakeWorkflowList(
    strPath = 'workflows/4_modules',
    strPackage = NULL
)

gsm.core::RunWorkflows(
    lModuleWorkflows,
    lReportingData
)
