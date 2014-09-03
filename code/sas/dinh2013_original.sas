**SAS CODE FOR SHORT STAY PREDICTION RULE PROJECT**;
**from "trauma calls only admitted" worksheet;
data shortstay; set WORK.shortstay;
 
los48=0; if LOS le 2 and died=0 and icu=0 then los48=1;
 
**randomise the dataset into training and testing dataset**;
 
if ranuni(20) le .5 then group=1;
   else group=2;
xlos48=los48;
if group=2 then xlos48=.;
 
*categorise variables;
if bodyregions le 1 then singleregion=1;
if bodyregions gt 1 then singleregion=0;
if arrivalmode=0 then ambo=0;
if arrivalmode gt 0 then ambo=1;
 
**create binary indicator variables for mechanism of injury;
mva=0; if mechcode=2 then mva=1;
mba=0; if mechcode=3 then mba=1;
pedestrian=0; if mechcode=4 then pedestrian=1;
cyclist=0; if mechcode=5 then cyclist=1;
fallsonly=0; if mechcode=1 then fallsonly=1;
 
**categorise all comorbidities;
cva=0; if tiacva gt 0 or hemiplegia gt 0 then cva=1;
malignancy=0; if cancernomets gt 0 or lymphoma gt 0 or leukemia gt 0 or metastatic gt 0 then malignancy = 1;
diabetic=0; if diabetes gt 0 or diabeticcomp gt 0 then diabetic=1;
renal1=0; if modrenal gt 0 then renal1=1;
liver=0; if mildliver = 1 or 'moderate liver disease' gt 0 then liver=1;
hiv=0; if hivaids gt 0 then hiv=1;
 
comorbidnumber = AMI + CCF + PVD + cva + dementia + liver + renal1 + diabetic + malignancy + hiv + CTD + PUD + COPD;
 
ISS8=0; if ISS gt 8 then ISS8=1;
ISS15=0; if ISS gt 15 then ISS15=1;
 
**convert normal respiratory rate;
rr1=0; if rr4=4 then rr1=1;
 
**categorize gcs into three categories**;
gcs3=0; if GCS gt 13 then gcs3=0; if 9 le GCS le 13 then gcs3=1; if GCS le 8 then gcs3=2;
run;
 
**population stats;
proc freq;
tables (icu died)*los48;
run;
 
proc freq;
tables died age65 anymedical ISS8 ISS15 penetrating singleregion headany chestany abdoany upperlimbany spineany lowerlimbnopelvis anypelvis;
run;
 
proc freq;
tables mechcode;
run;
 
proc means;
var age;
run;
 
proc univariate plots;
var iss;
run;
 
**table 1 derivation versus validation baselines;
proc freq;
tables (age65 male gcs1 normalvitals singleregion icu iss8 bodyregions penetrating fall mba mva cyclist pedestrian traumatier operation icu anymedical)*group/norow nopercent chisq;
run;
 
proc univariate;
var iss charlson bodyregions gcs;
class group;
run;
 
proc npar1way wilcoxon;
var iss charlson bodyregions gcs;
class group;
run;
 
proc ttest;
var age bp rr pr;
class group;
run;
 
 
**table two baseline characteristics;
 
proc freq;
tables los48*icu;
run;
 
proc freq;
tables (age65 male gcs1 normalvitals singleregion icu iss8 bodyregions penetrating fall mba mva cyclist pedestrian traumatier operation icu anymedical)*los48/norow nopercent chisq;
run;
 
proc univariate;
var iss charlson bodyregions gcs;
class los48;
run;
 
proc npar1way wilcoxon;
var iss charlson bodyregions gcs;
class los48;
run;
 
proc ttest;
var age bp rr pr;
class los48;
run;
 
**logistic regression on training dataset;
**run stepwise selection algorithm logistic model on training dataset**;
 
proc logistic descending data=shortstay;
class age65 (param=ref ref='1') gcs1 (param=ref ref='0')singleregion (param=ref ref='0')fallsonly (param=ref ref='0')normalvitals (param=ref ref='0')ISS8 (param=ref ref='0')operation (param=ref ref='0') mva (param=ref ref='0') mba (param=ref ref='0') pedestrian (param=ref ref='0') cyclist (param=ref ref='0')fall (param=ref ref='0') penetrating (param=ref ref='0') traumatier (param=ref ref='2') fallsonly (param=ref ref='1') ;
model xlos48= age65 gcs1 operation iss8 normalvitals anymedical mentalhealth penetrating mva mba pedestrian fallsonly cyclist pedestrian headany chestany abdoany spineany lowerlimbany upperlimbany/selection=s details
sls=0.05 sle=0.05 lackfit;
roc;
output out=traintest pred=phat;
run;
 
proc contents position data=traintest;
run;
 
proc print data=traintest;
var los48 xlos48 phat;
run;
 
 
data traintest;
set traintest;
if 0 le phat le .25 then phatcat=1;
else if .25 lt phat le .50 then phatcat=2;
else if .50 lt phat le .75 then phatcat=3;
else if phat gt .75 then phatcat=4;
 
proc sort data=traintest;
by group phatcat;
run;
*calibration table;
 
proc freq data=traintest;
tables phat*los48/measures noprint;
by group;
run;
 
proc means n sum mean data=traintest;
class group phatcat;
var phat los48;
by group;
run;
 
 
proc freq;
tables phatcat*los48;
where group=2;
run;
 
***********************************************************;
************** ROC Derivation vs Validation ************************;
*******************************************************************;
ods listing close;
ods html style=journal;
ods graphics on;
      ods select roccurve ;
proc logistic descending data=shortstay ;
title 'The Derivation Dataset';
model xlos48=age65 gcs1 operation normalvitals iss8 mentalhealth penetrating fallsonly pedestrian  singleregion chestany spineany lowerlimbany upperlimbany  / outroc =roc_der;
output out=traintest pred=phat_der;
run;
      ods select roccurve ;
  proc logistic descending data=traintest;
title 'The Validation Dataset';
model los48=phat_der / outroc=roc_val ;
where group=2;
run;
       data roc;
       set roc_der(in=der) roc_val(in=val);
       if der then group='derivation';
       else if val then group='validation';
       run;
       symbol1 interpol=spline  ;
   proc sgplot data=roc;
   title 'Receiver Operator Characteristic (ROC) Curve for trauma short stay prediction model';
     series x=_1mspec_  y=_sensit_  / group=group;
       series x=_1mspec_  y=_1mspec_  ;
       XAXIS label = "1 - Specificity";
       YAXIS label = "Sensitivity";
      run;
   ods graphics off;
   ods html close;
   title ' ';
   title2 ' ';
   ods listing;
 
*********************************************************;
*  "OPTIMISM" Bootstrap Estimate Program                      ;
*  PRODUCT:     STAT                                          ;
*  SYSTEM:      ALL                                               ;
*  PROCS:       LOGISTIC, MEANS, FREQ                         ;
*  WRITTEN BY:  SHIMON SHAYKEVICH                             ; 
*  EMAILE:      sshaykev@hsph.harvard.edu                     ;
*  INSTITUTION: BWH                                           ;                     
*  REVISED:     07/24/2008                                    ;
*********************************************************;
*filename shimon dummy;
*proc printto log=shimon;
*run;
 
 
***!!!MACRO for a given dataset!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!***;
   %LET OUTCOME = los48 ;                    *?????????????????;
   %LET MYMODEL = age65 gcs1 operation normalvitals iss8 mentalhealth penetrating fallsonly pedestrian  chestany spineany lowerlimbany upperlimbany ;                    *?????????????????;
   %LET MYDATA  = shortstay ;                    *?????????????????;
   %LET SAMPNUM = 500 ;                    *?????????????????;
   %LET MYTITLE = BOOTSTRAP OPTIMISM ; *?????????????????;                            
   %LET ORDER   = DESCENDING;          *?????????????????;
   %LET PATH =   u: ;                    *?????????????????;
   %LET CLASS   = %STR() ;              *??????????????????;
 *******************************************************************;
 *******************************************************************;
*     NO CHANGES SHOULD BE DONE AFTER THIS LINE;
******************************************************;
      *****************;
    proc datasets lib=work;
    delete _boot;
    run;
      quit;
   *****************;
*****************;
proc datasets lib=work;
delete  _test1  _pool _prob _d _d1 _d2 _temp1 _temp2 ;
run;
quit;
*****************;
      
 
title ' ';
  options nomprint formdlim='';
%macro _init;
data _null_;
array _myvar   &mymodel;
call symput('vnum',dim(_myvar));
run;
data _POOL;
set &mydata;
keep &outcome;
keep &mymodel;
run;
 
%mend _init;
%_init
 
%macro _loop;
 
%do j = 1 %to &sampnum;
 
data _test1;
drop i;
do i = 1 to _n;
_iobs=int(ranuni(0)*_n)+1;
set _pool point=_iobs nobs=_n;
output;
end;
stop;
run;
*********************************;
data _test1;
set _test1 _pool(in=_p);
_xmi=&outcome;
_grp=1;
if _p then
do;
_xmi=.;
_grp=2;
end;
run;
***************************************;
proc logistic data=_test1 outest=_temp1(drop=_link_ _type_
_name_  _lnlike_ ) noprint &order;
&class
 model _xmi = &mymodel ;
output out=_prob p=_predict;
run;
proc freq data=_prob noprint;
tables _predict*_xmi / measures;
output out=_d smdrc;
run;
***********************************;
proc freq data=_prob noprint;
tables _predict*&outcome / measures;
output out=_d1 smdrc;
where _grp=2;
run;
***********************************;
proc transpose data=_temp1 out=_sh1(keep=col1 rename=col1=_betas);
run;
 
data _null_;
set _sh1;
call symput('_beta'||left(_n_-1),_betas);
run;
***************************************;
/*
data _pool_p(drop=i);
set _pool;
array _betas1 {%sysevalf(&vnum+1)} _b0 - _b%sysevalf(&vnum);
do i=1 to %sysevalf(&vnum+1);
_betas1 [i]=symget('_beta' || left(put(i-1,2.)));
end;
array _model &mymodel;
array _betas2 _b1 - _b%sysevalf(&vnum);
_log=_b0;
do over _betas2;
_log=_log+_betas2*_model;
end;
_prob=exp(_log)/(1+exp(_log));
run;
*/
 
 
data _d2;
set _d1;
c_temp=(1+abs(_smdrc_))/2;
drop _smdrc_ e_smdrc;
run;
 
data _temp2;
merge _temp1 _d _d2;
c=(1+abs(_smdrc_))/2;
drop _smdrc_ e_smdrc;
c_dif_=(c-c_temp);
drop c_temp;
run;
 
proc append data=_temp2 out= _boot ;
run;
 
%end;
 
%mend _loop;
%_loop;
 
 proc sql noprint;
  select distinct upcase(name) into :NVARS separated by ' = ' from
dictionary.columns
   where libname=upcase("work") and memname=upcase("_boot") and
trim(type)='num';
quit;
 
proc datasets lib=work;
 modify _boot;
 label &nvars =;
  run;
   quit;
ods listing close;
************  new code starts here ******;
proc freq data=_boot;
tables c;
ods output onewayfreqs=_c_value(keep=c cumpercent);
run;
proc sql noprint;
select  min(c)as min_c format=5.3 ,max(c)as max_c format=5.3 into: low_cl_c,: up_cl_c 
from _c_value
where  2.5 le  _c_value.cumpercent le 97.5
;
quit;
 
******************;
*ods listing close;
*filename body "&path\optimism.html";
*ODS HTML BODY= body ;
ODS HTML BODY="&path\optimism.html"; ;
ods noproctitle;
proc means data=_boot maxdec=3 ;
title " &mytitle ";
footnote "95% Confidence Limits for C_stat: LOW_C=&low_cl_c  UP_C=&up_cl_c";
run;
ods html close;
footnote;
 
ods listing;
*options source notes;
 
*****************;
proc datasets lib=work;
delete  _test1  _pool _prob _d _d1 _d2 _temp1 _temp2 _c_value;
run;
quit;
*****************;
***!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!***;
   %LET OUTCOME =%STR()  ;                    *?????????????????;
   %LET MYMODEL =%STR()  ;                    *?????????????????;
   %LET MYDATA  =%STR()  ;                    *?????????????????;
   %LET SAMPNUM = %STR() ;                    *?????????????????;
   %LET MYTITLE = %STR()  ; *?????????????????;                           
   %LET ORDER   = %STR() ;          *?????????????????;
   %LET PATH =   %STR()  ;                    *?????????????????;
   %LET CLASS   = %STR() ;             *?????????????????;
   %LET NVARS   = %STR() ;             *?????????????????;
   *********!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!************;
proc printto ;  run;
