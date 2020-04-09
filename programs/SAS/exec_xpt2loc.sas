data test;
    do i = 1 to 4;
        X1='a';
        X2=1;
        X3='bbb';
        output;
    end;
    drop i;
run;
* output xpt files;
%loc2xpt(memlist=test, filespec='\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\test\haven_v8_test\fromsas5.xpt', format=v5);
%loc2xpt(memlist=test, filespec='\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\test\haven_v8_test\fromsas8.xpt', format=v8);

* sasxport input test;
OPTIONS NOFMTERR; 
%xpt2loc(filespec='\\aronas\Datacenter\Users\ohtsuka\2019\20200316\test\xpt\sasxport\sbc.xpt');

