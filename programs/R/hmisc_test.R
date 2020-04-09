# 下記問題の検証
# https://stackoverflow.com/questions/48223067/error-in-loading-package-sasxport-object-label-data-frame-is-not-exported-b?noredirect=1&lq=1
# ACQ_I.XPT
# https://wwwn.cdc.gov/Nchs/Nhanes/Search/DataPage.aspx?Component=Questionnaire&CycleBeginYear=2015
library("here")
input_file_path <- here("test", "hmisc_test", "input", "ACQ_I.XPT")
library("Hmisc")
hmisc_df <- sasxport.get(input_file_path)
library("SASxport")
sasxport_df <- read.xport(input_file_path)
s_info <- sessionInfo()
save.image(file=here("test", "hmisc_test", "hmisc_test.Rda"))

