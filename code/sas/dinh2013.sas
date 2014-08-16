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
proc logistic data=hons.derivation descending outest=hons.betas;
	class ssa sex normalvitals gcs1 iss8 age65 transfer penetrating mechcode fall
			headany faceany neckany chestany abdoany spineany upperlimbany lowerlimbany
			head3 face3 neck3 chest3 abdo3 spine3 upper3 lower3
			operation laparotomy thoracotomy neurosurgery
			married english mentalhealth
			comorbidity;
	model ssa=sex normalvitals gcs1 iss8 age65 transfer penetrating mechcode fall
			headany faceany neckany chestany abdoany spineany upperlimbany lowerlimbany
			head3 face3 neck3 chest3 abdo3 spine3 upper3 lower3
			operation laparotomy thoracotomy neurosurgery
			married english mentalhealth
			comorbidity
		/ selection=stepwise
		  slentry=0.05
		  slstay=0.05
		  details
		  lackfit;
	output out=hons.predicted p=phat lower=lcl upper=ucl
		predprob=(individual crossvalidate);
run;

proc print data=hons.betas;
	title2 'Parameter Estimates and Covariance Matrix';
run;

proc print data=hons.predicted;
	title2 'Predicted Probabilities and 95% Confidence Limits';
run;
