# ------
# Program Name : common.R
# Purpose : Common processing
# Author : Mariko Ohtsuka
# Date : 2020-03-16
# ------
library(dplyr)
library(stringr)
library(jsonlite)
os <- .Platform$OS.type  # mac or windows
parent_path <- ""
if (os == "unix"){
  volume_str <- "/Volumes"
} else{
  volume_str <- "//aronas"
}
parent_path <- "/Datacenter/Users/ohtsuka/2019/20200316/test/"
input_path <- str_c(volume_str, parent_path, "input/")
output_json_file <- str_c(volume_str, parent_path, "json/jsonByR.json")
rawdata_path <- str_c(input_path, "rawdata/")
ext_path <- str_c(input_path, "ext/")
output_sasxport_path <- str_c(volume_str, parent_path, "xpt/sasxport/")
output_haven_v5_path <- str_c(volume_str, parent_path, "xpt/haven_v5/")
output_haven_v8_path <- str_c(volume_str, parent_path, "xpt/haven_v8/")
kCol1Name <- "シート名英数字別名"
