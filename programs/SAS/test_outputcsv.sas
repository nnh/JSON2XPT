/******************************************************
Program Name : test_outputcsv.sas
Author : Ohtsuka Mariko
Date : 2020-04-01
SAS version : 9.4
*******************************************************/
%macro OUTPUT_CSV(input_lib, folder_name);
    %local i output_ds;
    ods noresults;
    ods output members=work.wk_output;
        proc datasets lib=&input_lib.  memtype=data;
        quit;
    ods output close;
    ods results;
    proc sql noprint;
        select count(*) into:row_cnt from work.wk_output;
    quit;
    %do i=1 %to &row_cnt.;
        data _NULL_;
            set work.wk_output;
            if _N_=&i. then do;
                call symput('output_ds', name);
            end;
        run;
        %ds2csv(data=&input_lib..&output_ds., runmode=b, formats=N, labels=N, csvfile=\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\test\&folder_name.\&output_ds._num.csv);
        %ds2csv(data=&input_lib..&output_ds., runmode=b, csvfile=\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\test\&folder_name.\&output_ds._lbl.csv);
    %end;
%mend OUTPUT_CSV;
%OUTPUT_CSV(wk_h_v5, csv_haven_v5);
%OUTPUT_CSV(wk_sasxp, csv_sasxport);
