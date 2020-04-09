library(dplyr)
library(here)
library(stringr)
file_list <- list.files(here("input", "rawdata"))
file_path_list <- str_c(here("input", "rawdata"), "/", file_list)
input_csv <- lapply(file_path_list, function(x){
  temp <- read.csv(file=x, stringsAsFactors=F, as.is=T)
  # Convert all columns to string type
  temp <- temp %>% lapply(as.character) %>% as.data.frame(stringsAsFactors=F)
  temp_const_col <- str_c("v", rep(1:11))
  temp_colnames <- colnames(temp)
  if (length(temp_colnames) > 11){
    temp_colnames <- c(temp_const_col, temp_colnames[12:length(temp_colnames)])
  } else {
    temp_colnames <- temp_const_col[1:length(temp_colnames)]
  }
  colnames(temp) <- temp_colnames
  return(temp)
  }
)

output_path <- here("test", "csv_rawdata", "for_sasxport")
temp <- lapply(input_csv, function(x){
  filename <- x[1,1]
  if (nchar(filename) > 8){
    filename <- str_c(str_sub(filename, 1, 4), str_sub(filename, -4, -1))
  }
  filename <- str_pad(filename, 8, side="right", pad=" ")
  if (ncol(x) > 7){
    ds_common <- x %>% select(c(1:11))
    ds_field <- x %>% select(starts_with("field"))
    ds_conbine_field <- cbind(ds_common, ds_field)
    ds_label <- x[ , -which(colnames(x) %in% colnames(ds_field))]
  } else {
    ds_conbine_field <- x
    ds_label <- x
  }
  # Match format
  # checkbox
  if (filename == "baseline"){
    ds_label$転移臓器の部位 <- x$field25
  }
  # NA -> "."
  if (filename == "floweet2"){
    ds_label$化学療法の種類 <- ifelse(ds_label$化学療法の種類 == "", ".", ds_label$化学療法の種類)
    ds_label$化学療法.1コース完遂した <- ifelse(ds_label$化学療法.1コース完遂した == "", ".", ds_label$化学療法.1コース完遂した)
    ds_conbine_field$field8 <- ifelse(is.na(ds_conbine_field$field8), ".", ds_conbine_field$field8)
    ds_conbine_field$field338 <- ifelse(is.na(ds_conbine_field$field338), ".", ds_conbine_field$field338)
  }
  if (filename == "floweet3"){
    ds_label$手術の根治度 <- ifelse(ds_label$手術の根治度 == "", ".", ds_label$手術の根治度)
    ds_conbine_field$field3 <- ifelse(is.na(ds_conbine_field$field3), ".", ds_conbine_field$field3)
  }
  if (filename == "floweet4"){
    ds_label$術後補助化学療法の種類 <- ifelse(ds_label$術後補助化学療法の種類 == "", ".", ds_label$術後補助化学療法の種類)
    ds_label$術後補助化学療法が6ヵ月間未満で終了した <- ifelse(ds_label$術後補助化学療法が6ヵ月間未満で終了した == "", ".", ds_label$術後補助化学療法が6ヵ月間未満で終了した)
    ds_conbine_field$field339 <- ifelse(is.na(ds_conbine_field$field339), ".", ds_conbine_field$field339)
    ds_conbine_field$field340 <- ifelse(is.na(ds_conbine_field$field340), ".", ds_conbine_field$field340)
  }
  if (filename == "regition"){
    ds_label$性別 <- ifelse(ds_label$性別 == "男性", "0", "1")
  }
  # ctcae
  if (filename == "withawal"){
    ds_label <- ds_label[ , c(1:18)] %>% cbind(ds_conbine_field[ , c(19:27)])
  }
  ####### NG ITEMS ######
  if (filename == "baseline"){
    ds_label$原発性小腸癌の部位 <- ifelse(ds_label$原発性小腸癌の部位 == "十二指腸", "十二指", ds_label$原発性小腸癌の部位)
  }
  if (filename == "floweet2"){
    ds_label$化学療法の種類 <- ifelse(ds_label$化学療法の種類 == "Other regimens", "Other", ds_label$化学療法の種類)
    ds_label$化学療法の種類 <- ifelse(ds_label$化学療法の種類 == "FOLFOX/CapeOX/SOX", "FOLFOX", ds_label$化学療法の種類)
  }
  if (filename == "floweet4"){
    ds_label$術後補助化学療法の種類 <- ifelse(ds_label$術後補助化学療法の種類 == "Other regimens", "Other", ds_label$術後補助化学療法の種類)
  }
  if (filename == "regition"){
    ds_conbine_field$field8 <- ifelse(ds_conbine_field$field8 == "2", "1", ds_conbine_field$field8)
  }
  if (filename == "withawal"){
    ds_label$死亡 <- ifelse(ds_label$死亡 == "死亡", "1", ds_label$死亡)
    ds_conbine_field$field320 <- ifelse(ds_conbine_field$field320 == "0", "1", "2")
  }
  #######
  write.csv(ds_conbine_field, file=str_c(output_path, "/", filename, "_num.csv"), na='""', row.names=F)
  write.csv(ds_label, file=str_c(output_path, "/", filename, "_lbl.csv"), na='""', row.names=F)
  return(NULL)
})

output_path <- here("test", "csv_rawdata", "for_havenv5")
temp <- lapply(input_csv, function(x){
  filename <- x[1,1]
  if (nchar(filename) > 8){
    filename <- str_c(str_sub(filename, 1, 4), str_sub(filename, -4, -1))
  }
  filename <- str_pad(filename, 8, side="right", pad=" ")
  if (ncol(x) > 7){
    ####### Match format
    x[ , 5] <- ifelse(x[ , 5] == "消化器内科", "消化器内　", x[ , 5])
    x[ , 5] <- ifelse(x[ , 5] == "消化器外科", "消化器外　", x[ , 5])
    x[ , 5] <- ifelse(x[ , 5] == "肝胆膵外科", "肝胆膵外　", x[ , 5])
    x[ , 7] <- stringr::str_replace(x[ , 7], "雄", "　")
    #######
    ds_common <- x %>% select(c(1:11))
    ds_field <- x %>% select(starts_with("field"))
    ds_conbine_field <- cbind(ds_common, ds_field)
    ds_label <- x[ , -which(colnames(x) %in% colnames(ds_field))]
  } else {
    ds_conbine_field <- x
    ds_label <- x
  }
  ####### Match format
  if (filename == "regition"){
    ds_conbine_field$field8 <- ifelse(ds_conbine_field$field8 == "2", "1", ds_conbine_field$field8)
  }
  if (filename == "withawal"){
    ds_conbine_field$field3 <- ifelse(is.na(ds_conbine_field$field3), "", ds_conbine_field$field3)
    ds_conbine_field$field4 <- ifelse(is.na(ds_conbine_field$field4), "", ds_conbine_field$field4)
    ds_conbine_field$field320 <- ifelse(ds_conbine_field$field320 == "0", "1", "2")
  }
  #######
  write.csv(ds_conbine_field, file=str_c(output_path, "/", filename, "_num.csv"), na='"."', row.names=F)
  return(NULL)
})
