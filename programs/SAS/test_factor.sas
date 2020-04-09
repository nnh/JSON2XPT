libname test xport "\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\test\factor_test\test.xpt" access=readonly;
proc copy in=test out=work;
run;    
proc format lib=work cntlin=test.formats;
run;
