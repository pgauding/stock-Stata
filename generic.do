* nihilistspicer template
* https://twitter.com/nihilistspicer/status/1130872644126105601

version 15.1
clear all
set more off

/******************************************************************************
*
* Title
*
* AUTH: Patrick Gauding <patrick.gauding@ku.edu>
* DATE: 2019-06-08
* FILE: 00-Proj-name.do
*
* STEPS:
*    1. Import data
*    2. Test data
*    3. Analysis
*
******************************************************************************/

/* Static Directories */
global PROJECT_DIR "~/Documents/foo/bar/baz"
global DATA_DIR "${PROJECT_DIR}/data/dta"
global CODE_DIR "${PROJECT_DIR}/code"
global OUTPUT_DIR "${PROJECT_DIR}/output"
global RAW_DATA_DIR "${PROJECT_DIR}/data/raw"
cd "${PROJECT_DIR}"

/* Data Files */
global MY_DATA "${DATA_DIR}/some random data.dta"
global MORE_DATA "${MORE_DATA}/other random data.dta"

/* Parameters */
global MY_ASSUMPTION = 5

/*****************************************************************************/

do "${CODE_DIR}/01 - Import data.do"
do "${CODE_DIR}/02 - Test data.do"
do "${CODE_DIR}/03 - Analysis.do"
