# ------
# Program Name : export-xpt.R
# Purpose : Export XPT file
# Author : Mariko Ohtsuka
# Date : 2020-03-30
# ------ library, common process
library(here)
library(haven)
library(SASxport)
source(here("programs", "R", "common.R"), encoding="utf-8")
# ------ function
#' @title ConvertVariableName
#' @param target_df : Data frame for converting variable name
#' @param sheets :  Sheet information of data frame to convert label
#' @return A data frame
ConvertVariableName <- function(target_df, sheets){
  temp_colnames <- colnames(target_df)
  for (i in 1:length(temp_colnames)){
    if (temp_colnames[i] %in% sheets$fieldname){
      temp <- sheets %>% filter(fieldname == temp_colnames[i])
      temp_colnames[i] <- temp$sheets.variable
    } else {
      temp_colnames[i] <- str_c("v", i)
    }
  }
  colnames(target_df) <- temp_colnames
  return(target_df)
}
#' @title SetLabelToVariable
#' @param target_df : Data frame for setting label
#' @param sheets : Sheet information of data frame to set label
#' @param option : Information about options
#' @return A data frame
SetLabelToVariable <- function(target_df, df_name, options){
  sheets <- input_json[[3]] %>% as.data.frame(stringsAsFactors=F) %>%
              filter(sheets.Sheet.alias_name == df_name & !is.na(sheets.FieldItem.field_type))
  res_df <- target_df
  if (nrow(sheets) > 0){
    sheets$fieldname <- str_c("field", str_trim(sheets$sheets.FieldItem.name.tr..field......))
    for (i in 1:nrow(sheets)){
      fieldname <- sheets[i, "fieldname"]
      if ((!is.na(sheets[i, "sheets.Option.name"])) &&
          (is.character(target_df[ , fieldname]) || is.numeric(target_df[ , fieldname])) &&
          (sheets[i, "sheets.FieldItem.field_type"] != "checkbox")) {
        target_option_name <- sheets[i, "sheets.Option.name"]
        target_option <- options %>% filter(options.Option.name == target_option_name)
        temp_labels <- target_option$options.Option..Value.code
        names(temp_labels) <- target_option$options.Option..Value.name
      } else {
        temp_labels <- NULL
      }
      # If the type of a variable is logical, convert it to a string
      if (is.logical(target_df[ , fieldname])){
        res_df[ , fieldname] <- as.character(target_df[ , fieldname])
      }
      temp_label <- sheets[i, "sheets.FieldItem.label"]
      res_df[ , fieldname] <- labelled(res_df[ , fieldname], temp_labels, temp_label)
      # Convert to factor
      if (!is.null(temp_labels)){
        res_df[ , fieldname] <- haven::as_factor(res_df[ , fieldname])
      }
    }
    # Set a variable name
    sheets <- sheets %>% filter(!is.na(sheets.variable))
    res_df <- ConvertVariableName(res_df, sheets)
  } else {
    colnames(res_df) <- str_c("v", seq(ncol(res_df)))
  }
  return(res_df)
}
# ------
# Import JSON file
input_json <- fromJSON(output_json_file)
options <- input_json[[2]] %>% as.data.frame(stringsAsFactors=F)
for (i in 1:length(input_json[[1]])){
  df_name <- names(input_json[[1]][i])
  temp_df <- SetLabelToVariable(input_json[[1]][[i]], df_name, options)
  assign(df_name, temp_df)
}
# Export XPT file
output_df_name_list <- names(input_json[[1]])
output_list <- NULL
output_list <- sapply(output_df_name_list, function(x){ return(list(get(x))) })
# Create a data set name of 8 characters or less
df_name_8 <- ifelse(str_length(output_df_name_list) <= 8, output_df_name_list,
                    str_c(str_sub(output_df_name_list, 1, 4), str_sub(output_df_name_list, -4, -1)))
for (i in 1:length(output_list)){
  # haven v8
  #  write_xpt(zap_label(zap_labels(output_list[[i]])), path=str_c(output_haven_v8_path, names(output_list)[i], ".xpt"), version=8,
  #                   name=names(output_list)[i])
  write_xpt(output_list[[i]], path=str_c(output_haven_v8_path, names(output_list)[i], ".xpt"), version=8,
            name=names(output_list)[i])
  # Convert column names to 8 characters or less
  colnames(output_list[[i]]) <- colnames(output_list[[i]]) %>% makeSASNames(quiet=T) %>% str_replace("\\.", "_")
  # sasxport
  write.xport(list=setNames(list(output_list[[i]]), df_name_8[i]),
              file=str_c(output_sasxport_path, names(output_list)[i], ".xpt"))
  # haven v5
  write_xpt(output_list[[i]], path=str_c(output_haven_v5_path, names(output_list)[i], ".xpt"), version=5,
                   name=df_name_8[i])
}
