%macro rocplot ( version, inroc=, inpred=, p=, id=, idstat=, plottype=high, 
                 linecolor=, linepattern=, linethickness=1, labelstyle=, markersymbol=circle, markers=yes, 
                 outrocdata=_rocplot, offsetmin=0.1, offsetmax=0.1, grid=yes, 
                 mindist=, round=1e-12, thinsens=0.05, thinvar=, 
                 format=best5., charlen=5, split=%str( ), altaxislabel=no,
                 
                 out=, outroc=, plotchar=, roffset=, font=, size=, color=
               );

%let _version=1.2;
%if &version ne %then %put ROCPLOT macro Version &_version;

%let opts = %sysfunc(getoption(notes));
%if &version ne debug %then %str(options nonotes;);

/* -------------- Check for newer version -------------- */
 %if %sysevalf(&sysver >= 8.2) %then %do;
  %let _notfound=0;
  filename _ver url 'http://ftp.sas.com/techsup/download/stat/versions.dat' termstr=crlf;
  data _null_;
    infile _ver end=_eof;
    input name:$15. ver;
    if upcase(name)="&sysmacroname" then do;
       call symput("_newver",ver); stop;
    end;
    if _eof then call symput("_notfound",1);
    run;
  %if &syserr ne 0 or &_notfound=1 %then
    %put &sysmacroname: Unable to check for newer version;
  %else %if %sysevalf(&_newver > &_version) %then %do;
    %put &sysmacroname: A newer version of the &sysmacroname macro is available.;
    %put %str(         ) You can get the newer version at this location:;
    %put %str(         ) http://support.sas.com/ctx/samples/index.jsp;
  %end;
 %end;

/* -------------------- Check inputs -------------------- */

/* Convert pre-v1.2 syntax as possible */
%if %quote(&out) ne and %quote(&inpred)= %then %let inpred=&out;
%if %quote(&outroc) ne and %quote(&inroc)= %then %let inroc=&outroc;
%if %quote(&plotchar) ne and %quote(&markersymbol)= %then %let markersymbol=&plotchar;
%if %quote(&roffset) ne and (&offsetmin= and &offsetmax=) %then %do;
  %let offsetmin=&roffset; %let offsetmax=&roffset;
%end;
%if %quote(&font) ne and %index(&labelstyle,family)=0 %then 
  %let labelstyle=&labelstyle family=&font;
%if %quote(&size) ne and %index(&labelstyle,size)=0 %then 
  %let labelstyle=&labelstyle size=&size;
%if %quote(&color) ne and %index(&labelstyle,color)=0 %then 
  %let labelstyle=&labelstyle color=&color;

/* Verify ID= is specified */
%if %quote(&id)= %then %do;
  %put ERROR: At least one ID= variable is required.;
  %goto exit;
%end;

/* Verify P= is specified */
%if %quote(&p)= %then %do;
  %put ERROR: The P= option is required.;
  %goto exit;
%end;

/* Verify INROC= is specified and the data set exists */
%if %quote(&inroc) ne %then %do;
  %if %sysfunc(exist(&inroc)) ne 1 %then %do;
    %put ERROR: INROC= data set &inroc not found.;
    %goto exit;
  %end;
%end;
%else %do;
  %put ERROR: The INROC= option is required.;
  %goto exit;
%end;

/* Verify INPRED= is specified and the data set exists */
%if %quote(&inpred) ne %then %do;
  %if %sysfunc(exist(&inpred)) ne 1 %then %do;
    %put ERROR: INPRED= data set &inpred not found.;
    %goto exit;
  %end;
%end;
%else %do;
  %put ERROR: The INPRED= option is required.;
  %goto exit;
%end;

/* Verify THINSENS= is valid */
%if %sysevalf(&thinsens<0) or %sysevalf(&thinsens>1) %then %do;
  %put ERROR: The THINSENS= value must be between 0 and 1.;
  %goto exit;
%end;

/* Verify THINVAR= specified if MINDIST= is specified */
%if &mindist ne and &thinvar= %then %do;
  %put ERROR: THINVAR= must be specified when MINDIST= is specified;
  %goto exit;
%end;

/* Verify MINDIST= specified if THINVAR= is specified */
%if &mindist= and &thinvar ne %then %do;
  %put ERROR: MINDIST= must be specified when THINVAR= is specified;
  %goto exit;
%end;

/* Verify MINDIST= is valid */
%if &mindist ne and %sysevalf(&mindist<0) %then %do;
  %put ERROR: The MINDIST= value must be zero or greater.;
  %goto exit;
%end;

/* Verify CHARLEN= is valid */
%if &charlen ne and (%sysevalf(&charlen<1) or %index(&charlen,%str(.)) ne 0) %then %do;
  %put ERROR: The CHARLEN= value must an integer greater than 0.;
  %goto exit;
%end;

/* Verify P=,ID=, THINVAR= variables exist. Create IDCHAR and IDNUM macro 
   variables for char. and num. ID variables 
*/
%let idchar=; %let idcstat=; 
%let idnum=; %let idnstat=;
%let idnc=;
%let dsid=%sysfunc(open(&inpred));
%if &dsid %then %do;
  %if %sysfunc(varnum(&dsid,%upcase(&p)))=0 %then %do;
    %put ERROR: P= variable &p not found.;
    %goto exit;
  %end;
  %if %quote(&thinvar) ne %then %do;
    %let tvnum=%sysfunc(varnum(&dsid,%upcase(&thinvar)));
    %if &tvnum=0 %then %do;
      %put ERROR: THINVAR= variable &thinvar not found.;
      %goto exit;
    %end;
    %else %if %sysfunc(vartype(&dsid,&tvnum))=C %then %do;
      %put ERROR: THINVAR= variable must be numeric.;
      %goto exit;
    %end;
  %end;
  %let i=1;
  %do %while (%scan(&id,&i) ne %str() );
    %let var=%scan(&id,&i);
    %let stat=%scan(&idstat,&i,%str( ));
    %let idnc=&idnc C;
    %if &idstat ne and &stat= %then %do;
        %put ERROR: You must specify a statistic for each ID variable.;
        %goto exit;
    %end;
    %if %substr(&var,1,1) ne _ or %substr(&var,%length(&var),1) ne _
    %then %do;
       %let vnum=%sysfunc(varnum(&dsid,&var));
       %if &vnum=0 %then %do;
          %put ERROR: Variable &var not found.;
          %goto exit;
       %end;
       %if %sysfunc(vartype(&dsid,&vnum))=C %then %do;
           %let idchar=&idchar &var;
           %let idcstat=&idcstat &stat;
       %end;
       %else %do;
           %let idnum=&idnum &var;
           %let idnstat=&idnstat &stat;
           %if &i=1 %then %let idnc=N;
           %else %let idnc=%substr(&idnc,1,%length(&idnc)-1)N;
       %end;
    %end;
    %let i=%eval(&i+1);
  %end;
  %let rc=%sysfunc(close(&dsid));
%end;

/* Construct char variable list for PROC SORT BY statement */
%let sortby=; %let i=1;
%do %while (%scan(&idchar,&i) ne %str() );
   %let stat=%scan(&idcstat,&i);
   %if &stat= %then %let sortby=&sortby %scan(&idchar,&i);
   %else %if %upcase(%substr(&stat,1,1))=F %then 
     %let sortby=&sortby %scan(&idchar,&i);
   %else %if %upcase(%substr(&stat,1,1))=L %then 
     %let sortby=&sortby descending %scan(&idchar,&i);
   %else %do;
     %put ERROR: IDSTAT= option value for &idchar must be FIRST or LAST.;
     %goto exit;
   %end;
   %let i=%eval(&i+1);
%end;

/* Construct num variable statistic list for PROC SUMMARY OUTPUT statement */
%let labstats=; %let i=1;
%do %while (%scan(&idnum,&i) ne %str() );
   %let stat=%scan(&idnstat,&i);
   %if &stat= %then %let labstats=&labstats median(%scan(&idnum,&i))=;
   %else %let labstats=&labstats &stat(%scan(&idnum,&i))=;
   %let i=%eval(&i+1);
%end;

/* --------------------- Create plot data ------------------------ */

data _inpred;
   set &inpred;
   _OBS_=_n_;
   _prob_=round(&p,&round);
   run;
proc sort data=_inpred;
   by _prob_ &sortby;
   run;

%if &idnum ne %then %do;   
  proc summary data=_inpred;
     by _prob_;
     var &idnum;
     output out=_labstats (drop=_TYPE_)
     &labstats
     ;
     run;
     %if &syserr ne 0 %then %do;
        %put ERROR: Specify a valid statistic:;
        %goto exit;
     %end;
  data _labstats;
     set _labstats;
     _prob_=round(_prob_,&round);
     run;
%end;

data _inroc;
   set &inroc;
   _prob_=round(_prob_,&round);
   run;
proc sort data=_inroc;
   by _prob_;
   run;

/* Merge the original and ROC data by the predicted probabilities 
   and create formatted statistic variables 
*/
data &outrocdata;
   merge _inroc(in=_inroc) 
         _inpred 
         %if &idnum ne %then _labstats;
         ;
   by _prob_;
   if _inroc and first._prob_;
   length _id $ 200;
   _SENS_=put(_sensit_,&format);
   _SPEC_=put(1-_1mspec_,&format);
   _CSPEC_=put(_1mspec_,&format);
   if _falpos_+_pos_=0 then __FPOS_=0;
      else __FPOS_=_falpos_/(_falpos_+_pos_);
   _FPOS_=put(__FPOS_,&format);
   if _falneg_+_neg_=0 then __FNEG_=0;
      else __FNEG_=_falneg_/(_falneg_+_neg_);
   _FNEG_=put(__FNEG_,&format);
   _PPRED_=put(1-__FPOS_,&format);
   _NPRED_=put(1-__FNEG_,&format);
   _CUTPT_=put(_prob_,&format);
   __CORRECT_=(_POS_+_NEG_)/(_POS_+_NEG_+_FALPOS_+_FALNEG_);
   _CORRECT_=put(__CORRECT_,&format);
   __MISCLASS_=1-__CORRECT_;
   _MISCLASS_=put(__MISCLASS_,&format);
   /* Create single label variable */
   _id=
        %let i=1;
        %do %while (%scan(&id,&i) ne %str() );
          %if &i ne 1 %then ||"&split"||;
          %if %scan(&idnc,&i)=C %then cats(put(%scan(&id,&i),$&charlen..));
          %else cats(put(%scan(&id,&i),&format));
          %let i=%eval(&i+1);
        %end;
   ;
   drop __FNEG_ __FPOS_ __CORRECT_ __MISCLASS_;
   run;

/* -------------------- Point Labeling --------------------- */

/* Thin labels vertically (sens) and horizontally (1-spec) */
data &outrocdata;
   retain _prevsens 2.1;
   set &outrocdata end=eof;
   by _sensit_ notsorted;
   _labelgrp=0;
   drop _prevsens _labcnt;
   /* vertical thin: label points only if sensitivities differ enough */
   if _prevsens - _sensit_ > &thinsens then do;
      /* label only leftmost point at each sensitivity value */
      if (last._sensit_=1 and first._sensit_=0)
      then do;
        _thinid=_id; _labcnt+1;
        _prevsens=_sensit_;
        output;
        _thinid=""; _labelgrp=1;
      end;
   end;
   output;
   if eof then put "&sysmacroname: " _labcnt "points labeled by THINSENS=&thinsens..";
   run;

/* Add (0.0) data point */
data _add00;
   _prob_=1; _sensit_=0; _1mspec_=0; _labelgrp=0;
   run;
%if &thinvar= %then options notes;;
data &outrocdata;
   set &outrocdata _add00;
   run;
%if &version ne debug %then %str(options nonotes;);

/* Label additional points MINDIST or more apart on THINVAR variable */
%if &thinvar ne %then %do;
   proc sort data=&outrocdata;
      by &thinvar;
      run;
   options notes;
   data &outrocdata;
      set &outrocdata end=eof;
      retain _prev;
      drop _prev _labcnt;
      if _n_=2 then _prev=&thinvar;
      if _n_>1 then do;
         if abs(_prev - &thinvar) >= &mindist then do;
            if _thinid="" then do;
               _prev=&thinvar;
               if _labelgrp=0 then do;
                  _thinid=_id; _labcnt+1;
                  output;
                  _thinid=""; _labelgrp=1;
               end;
            end;
         end;
      end;
      output;
      if eof then put "&sysmacroname: " _labcnt "points labeled by THINVAR=&thinvar, MINDIST=&mindist..";
      run;
   %if &version ne debug %then %str(options nonotes;);
   proc sort data=&outrocdata;
      by _prob_;
      run; 
%end;

/* ----------------- Produce the ROC plot ----------------- */

%if %upcase(%substr(&plottype,1,1))=L %then %do;
   /* Plot once without labels so ROC curve is visible */
   proc plot data=&outrocdata;
      where _labelgrp=0;
      plot _sensit_*_1mspec_ /
           haxis=0 to 1 by .1 vaxis=0 to 1 by .1;
    %if %upcase(%substr(&altaxislabel,1,1))=Y %then
      label _1mspec_="False Positive Rate" _sensit_="True Positive Rate";;
      run; quit;

   /* Plot ROC curve again with labeled points */
   footnote "Points labeled by: &id";
   proc plot data=&outrocdata;
      where _labelgrp=0;
      plot _sensit_*_1mspec_ $ _thinid /
           haxis=0 to 1 by .1 vaxis=0 to 1 by .1;
    %if %upcase(%substr(&altaxislabel,1,1))=Y %then
      label _1mspec_="False Positive Rate" _sensit_="True Positive Rate";;
      run; quit;
%end;

%if %upcase(%substr(&plottype,1,1))=H %then %do;
   data _mrkrchars;
     length markersymbol $20;
     id="mrkr"; 
     value=0; markersymbol="n"; linethickness=&linethickness; output;
     value=1; markersymbol="&markersymbol"; linethickness=0; output;
     run;

   %if %sysevalf(&sysver < 9.4) %then %do;
      ods graphics / height=480px width=480px; 
   %end;
   
   proc sgplot data=&outrocdata noautolegend 
     %if %sysevalf(&sysver >= 9.4) %then aspect=1;
     %if %upcase(%substr(&markers,1,1))=Y and 
         %sysevalf(&sysver >= 9.4) and
         %substr(&sysvlong,1,9) ne %str(9.04.01M0) %then %do;
      dattrmap=_mrkrchars %str(;)
      symbolchar name=n char='200B'x;
     %end;;
    xaxis values=(0 to 1 by 0.25) 
      %if %upcase(%substr(&grid,1,1))=Y %then grid;
      offsetmin=&offsetmin offsetmax=&offsetmax; 
    yaxis values=(0 to 1 by 0.25) 
      %if %upcase(%substr(&grid,1,1))=Y %then grid;
      offsetmin=.05 offsetmax=.05;
    lineparm x=0 y=0 slope=1 / transparency=.7;
    series x=_1mspec_ y=_sensit_ / datalabel=_thinid
      %if %upcase(%substr(&markers,1,1))=Y and 
          %sysevalf(&sysver >= 9.4) and
          %substr(&sysvlong,1,9) ne %str(9.04.01M0)%then 
         markers group=_labelgrp attrid=mrkr;
      %if &labelstyle ne %then datalabelattrs=(&labelstyle);
      %if &linecolor ne %then lineattrs=(color=&linecolor);
      %if &linepattern ne %then lineattrs=(pattern=&linepattern);
      ;
    %if %upcase(%substr(&altaxislabel,1,1))=Y %then
      label _1mspec_="False Positive Rate" _sensit_="True Positive Rate";;
    footnote "Points labeled by: &id";
    run;
%end;

footnote;
%exit:
options &opts;
%mend;

