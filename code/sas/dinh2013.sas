/*
 * Import Excel data into SAS
 */
proc import out=hons.trauma
		datafile='Z:\Dropbox\uni\hons\data\working-trauma-los.xlsx'
		dbms=excelcs replace;
	range="'Irena to use - no deaths48hrs$'";
	scantext=yes;
	usedate=yes;
	scantime=yes;
run;

/*
 * Remove the records for patients who died
 */
data hons.trauma;
	set hons.trauma;
	if (outcome = 'Died') then delete;
run;

/*
 * Split the trauma dataset into half for derivation and validation
 */
proc surveyselect data=hons.trauma
	method=srs n=1256 out=hons.split outall;
run;

data hons.derivation hons.validation;
	set hons.split;
	if (selected = 1) then output hons.derivation;
	else output hons.validation;
run;

/*
 * Create a multivariable logistic regression model from the derivation
 * dataset with stepwise selection
 */
title 'Stepwise Selection on Trauma Patient LOS data';
proc logistic data=hons.derivation descending outest=hons.betas outmodel=hons.outmodel;
	class ssa sex normalvitals gcs1 iss8 age65 transfer penetrating mechcode
			bodyregions
			headany faceany neckany chestany abdoany spineany upperlimbany lowerlimbany
			head3 face3 neck3 chest3 abdo3 spine3 upper3 lower3
			operation laparotomy thoracotomy neurosurgery
			married english mentalhealth
			comorbidity;
	model ssa=sex normalvitals gcs1 iss8 age65 transfer penetrating mechcode
			bodyregions
			headany faceany neckany chestany abdoany spineany upperlimbany lowerlimbany
			head3 face3 neck3 chest3 abdo3 spine3 upper3 lower3
			operation laparotomy thoracotomy neurosurgery
			married english mentalhealth
			comorbidity
		/ selection=stepwise
		  slentry=0.05
		  slstay=0.05
		  details
		  lackfit
		  outroc=hons.roc
		  clodds=pl;
	output out=hons.predicted p=phat lower=lcl upper=ucl
		predprob=(individual crossvalidate);
run;

/*
 * Score the validation set with the model fitted in the above procedure
 */
proc logistic inmodel=hons.outmodel;
	score data=hons.validation
		out=hons.validation_out
		outroc=hons.validation_roc;
run;

/*
 * Plot the ROC curves for both derivation and validation data sets
 */
title1 'Receiver Operating Characteristic (ROC) Curves';
symbol interpol=join;
proc gplot data=hons.roc;
	plot _sensit_*_1mspec_;
run;
proc gplot data=hons.validation_roc;
	plot _sensit_*_1mspec_;
run;
