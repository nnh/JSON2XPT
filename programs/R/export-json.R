# ------
# Program Name : export-json.R
# Purpose : Create JSON from current CSV data
# Author : Mariko Ohtsuka
# Date : 2020-03-16
# ------
library(here)
source(here("programs", "R", "common.R"), encoding="utf-8")
file_list <- list.files(rawdata_path)
rawdata_json_list <- lapply(file_list, function(x){
  temp <- read.table(str_c(rawdata_path, x), fileEncoding="cp932", as.is=T, sep=",", header=T, na.strings="")
  if (colnames(temp)[1] == kCol1Name) {
    temp <- temp %>% select(c(1:11), starts_with("field"))
  }
  return(list(temp[1, 1], toJSON(temp, na="null", null="null")))
})
options_csv <- read.table(str_c(ext_path, "options.csv"), fileEncoding="UTF-8-BOM", as.is=T, sep=",", header=T, na.strings="")
sheets_csv <- read.table(str_c(ext_path, "sheets.csv"), fileEncoding="cp932", as.is=T, sep=",", skip=1, header=F, na.strings="")
sheets_csv_colname <- read.table(str_c(ext_path, "sheets.csv"), fileEncoding="cp932", as.is=T, nrows=1, header=F,
                                 sep=",", comment.char="*")
names(sheets_csv) <- sheets_csv_colname[1, ]
option_json <- toJSON(options_csv, na="null")
sheets_json <- toJSON(sheets_csv, na="null")
# Export JSON file
for (i in 1:length(rawdata_json_list)){
  append_f <- T
  if (i == 1){
    append_f <- F
    temp_str <- str_c("{", '"rawdata":{"', rawdata_json_list[[i]][[1]], '":', as.character(rawdata_json_list[[i]][[2]]), ",")
  } else if (i == length(rawdata_json_list)){
    temp_str <- str_c('"', rawdata_json_list[[i]][[1]], '":', as.character(rawdata_json_list[[i]][[2]]),"},")
  } else{
    temp_str <- str_c('"', rawdata_json_list[[i]][[1]], '":', as.character(rawdata_json_list[[i]][[2]]),"," )
  }
  str_replace_all(temp_str, "\\\\", "") %>%
    write.table(output_json_file, row.names=F, col.names=F, quote=F, append=append_f, fileEncoding="utf-8")
}
str_c('"options":{"options":', as.character(option_json), "},") %>% str_replace_all("\\\\", "") %>%
  write.table(output_json_file, row.names=F, col.names=F, quote=F, append=T, fileEncoding="utf-8")
str_c('"sheets":{"sheets":', as.character(sheets_json), "}", "}") %>% str_replace_all("\\\\", "") %>%
  write.table(output_json_file, row.names=F, col.names=F, quote=F, append=T, fileEncoding="utf-8")


