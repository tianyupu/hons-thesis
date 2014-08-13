/*
 * Split the trauma dataset into half for derivation and validation
 */
proc surveyselect data=hons.trauma
	method=srs n=1273 out=hons.split outall;
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
proc logistic data=hons.derivation covout outest=hons.betas;
	class ssa;
	model ssa=gcs1 normalvitals age65 penetrating chestany spineany lowerlimbany fall mentalhealth operation iss8 mechanism
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
