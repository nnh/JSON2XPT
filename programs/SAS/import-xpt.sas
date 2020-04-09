/******************************************************
Program Name : import-xpt.sas
Author : Ohtsuka Mariko
Date : 2020-03-23
SAS version : 9.4
*******************************************************/
options mprint mlogic symbolgen minoperator noautocorrect noquotelenmax;
%global temp_ds_name format_f;
%let parent_path=\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\xpt\;
libname library "\\ARONAS\Datacenter\Users\ohtsuka\2019\20200316\test\xpt\temp\sasxport\";
%let havenv5_path=&parent_path.haven_v5\;
%let sasxport_path=&parent_path.sasxport\;
%let temp_path=&parent_path.temp\;
%macro GET_FILENAME(input_path, out_dfname);
    /*  *** Functional argument *** 
        input_path : Directory path string 
        out_dfname : Dataset name to output file name
        *** Example ***
        %GET_FILENAME(&havenv5_path., &havenv5_filename.);
    */
    %local n dir;
    %let n=4;
    filename _path "&input_path.";
    data _NULL_;
        folder=pathname("_path");
        dir="'dir /a "||tranwrd(strip(folder), ' ', '" "')||"'";
        call symputx("dir", dir);
    run;
    filename in Pipe &dir.;
    * Output only files with the extension 'xpt' ;
    data &out_dfname.;
        infile in pad;
        input text $300.;
        length f_name $20.;
        f_name=scan(text,4," ");
        length=length(trim(f_name));
        if length > 4 then do;
            ext=substr(f_name, length(trim(f_name)) -&n. + 1, &n.);
        end;
        else do;
            ext='';
        end;
        keep f_name;
        if ext='.xpt' then output;
    run;
%mend GET_FILENAME;
%macro RENAME_FORMAT(input_ds, input_lib, seq);
    /*  *** Functional argument *** 
        input_ds : Target dataset 
        input_lib : Library where the target dataset resides
        seq : Number to make format name unique
        *** Example ***
        %RENAME_FORMAT(&temp_ds_name., &out_libname., &i.);
    */
    %local i row_cnt var_name bef_fmt aft_fmt;
    /* Get format catalog name */
    proc contents data=&input_lib..&input_ds. out=work.temp_contents varnum noprint; run;
    /* Generate a renamed name */
    data work.temp_contents;
        set work.temp_contents;
        where format is not missing;
        aft_fmt=cat(trim(format), trim(symget('seq')), '_');
    run;
    %let row_cnt=0;
    data _NULL_;
        set work.temp_contents nobs=row_cnt;
        call symputx('row_cnt', row_cnt);
    run;
    /* Rename the format catalog and rename the corresponding dataset format */
    %do i = 1 %to &row_cnt.;
        data _NULL_;
            set work.temp_contents;
            if _N_=&i. then do;
                call symputx('var_name', name);
                call symputx('bef_fmt', format);
                call symputx('aft_fmt', aft_fmt);
            end;
        run;
        proc catalog catalog=&input_lib..formats;
            change &bef_fmt.=&aft_fmt. (et=format);
        run;
        data &input_lib..&input_ds.;
            set &input_lib..&input_ds.;
            format &var_name. &aft_fmt..;
        run;
    %end; 
%mend RENAME_FORMAT;
%macro GET_DATASET_NAME(input_libname);
    /*  *** Functional argument *** 
        input_libname : Target library
        *** Example ***
        %GET_DATASET_NAME(wk_sasxp);
    */
    /* Output dataset information in 'xxx.xpt' */
    libname temp_lib "&temp_path." access=temp;
    proc copy in=&input_libname. out=temp_lib;
    run; 
    ods noresults;
    ods output members=work.tempmem;
        proc datasets lib=temp_lib  memtype=data;
        quit;
    ods output close;
    ods results;
    /* Output to tempmem1 for rawdata name, output to tempmem2 for formats */
    data work.tempmem1 work.tempmem2;
        set work.tempmem;
        if name^='FORMATS' then do;
            output work.tempmem1;
        end;
        else if name='FORMATS' then do;
            output work.tempmem2;
        end;
    run;
    /* Set dataset name to macro variable */
    data _NULL_;
        set work.tempmem1 nobs=row_cnt;
        if row_cnt=1 then do;
            call symputx('temp_ds_name', name);
        end;
    run;
    data _NULL_;
        set work.tempmem2 nobs=row_cnt;
        if row_cnt=1 then do;
            call symputx('format_f', name);
        end;
    run;
    proc datasets lib=temp_lib kill nolist; quit;
%mend GET_DATASET_NAME;
%macro IMPORT_V5(prt_path, input_libname, out_libname, out_lib_dir, encode);
    /*  *** Functional argument *** 
        prt_path : Directory path string 
        input_libname : Input library name
        out_libname : Output library name
        out_lib_dir : Directory path string 
        encode : Input file encoding
        *** Example ***
        %IMPORT_V5(&havenv5_path., haven_v5, wk_h_v5, "&temp_path.havenv5", "utf-8");
    */
    libname &out_libname. &out_lib_dir. inencoding=&encode.;
    proc datasets lib=&out_libname. kill nolist; quit;
    %local i;
    options nodsnferr;
    %do i = 1 %to &file_cnt.;
        libname &input_libname. xport "&prt_path.&&f_&i." access=readonly;
        proc copy in=&input_libname. out=&out_libname.;
        run;    
        %let temp_ds_name='';
        %let format_f='';
        %GET_DATASET_NAME(&input_libname.);
        %if &format_f.^='' %then %do;
            proc format lib=&out_libname. cntlin=&input_libname..formats;
            run;
            %RENAME_FORMAT(&temp_ds_name., &out_libname., &i.);
        %end;
    %end;
    options dsnferr;
%mend IMPORT_V5;
************;
* haven v5 *;
************;
%let havenv5_filename=file_haven_v5;
%GET_FILENAME(&havenv5_path., &havenv5_filename.);
data _NULL_;
    set &havenv5_filename. CUROBS=cobs NOBS=nobs;
    i=cobs;
    call symputx('f_'||cat(i), f_name);
    call symputx('file_cnt', nobs);
run;
%IMPORT_V5(&havenv5_path., haven_v5, wk_h_v5, "&temp_path.havenv5", "utf-8");
%IMPORT_V5(&havenv5_path., haven_v5, wk_hv5_2, "&temp_path.havenv5_2", "cp932");
************;
* sasxport *;
************;
%let sasxport_filename=file_sasxport;
%GET_FILENAME(&sasxport_path., &sasxport_filename.);
data _NULL_;
    set &sasxport_filename. CUROBS=cobs NOBS=nobs;
    i=cobs;
    call symputx('f_'||cat(i), f_name);
    call symputx('file_cnt', nobs);
run;
%IMPORT_V5(&sasxport_path., sasxport, wk_sasxp, "&temp_path.sasxport", "cp932");
************;
* haven v8 *;
************;
/*
OPTIONS NOFMTERR; 
%xpt2loc(filespec='\\ARONAS\Datacenter\Users\ohtsuka\2019\20200316\test\xpt\haven_v8\baseline.xpt');
%xpt2loc(filespec='\\ARONAS\Datacenter\Users\ohtsuka\2019\20200316\test\xpt\haven_v8\bak.SBC.xpt');
%xpt2loc(filespec='\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\xpt\haven_v5\SBC.xpt');

*/
