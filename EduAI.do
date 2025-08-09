

*********Format of the equation
****ln(Earnings)_ict = β0 + β1*YearsSchoolinĝ_ict + b2* experience + controls + ε_ict

****world bank data
*earnings will be GDP: NY.GDP.MKTP.KD

*years of schooling will be percent of people who finished primary, secondary and tertiary school 
*tertiary: SE.TER.ENRR
*secondary: SE.SEC.ENRR
*primary: SE.PRM.ENRR

**good proxy for work experience at macro level is mean years of schooling because it can rerpesent how long you were in the workplace
import delimited "https://ourworldindata.org/grapher/mean-years-of-schooling-long-run.csv?v=1&csvType=full&useColumnShortNames=true", encoding("utf-8") clear
drop if code == ""
ren mf_youth_and_adults__15_64_years yrschool
tempfile mincer 
save mincer, replace
*the country code variable is code

**now AI data
import delimited "https://ourworldindata.org/grapher/annual-scholarly-publications-on-artificial-intelligence.csv?v=1&csvType=full&useColumnShortNames=true", encoding("utf-8") clear
drop if code == ""
tempfile mincerAI 
save mincerAI, replace


******************************************************* Import the Code 
**altogether now
wbopendata, indicator(NY.GDP.MKTP.KD; SE.TER.ENRR; SE.SEC.ENRR; SE.PRM.ENRR) clear long
gen  code = countrycode
merge m:m code using "C:\Users\USER\Documents\stata code\ai job\mincer.dta"
keep if _merge ==3
drop _merge
merge m:m code using "C:\Users\USER\Documents\stata code\ai job\mincerAI.dta"
keep if _merge ==3
drop _merge



**Rename and relabel the variables 
ren ny_gdp_mktp_kd GDP
ren se_ter_enrr tertiary
ren se_sec_enrr secondary
ren se_prm_enrr primary
ren num_articles__field_all AIarts
gen lnGDP = ln(GDP)
gen lnAIarts = ln(AIarts)
gen yrschoolSQ = yrschool ^ 2
label var GDP "real GDP"
label var tertiary "tertiary education"
label var secondary "secondary education"
label var primary "primary education"
label var yrschool "average years of education"
label var AIarts "AI articles published"
label var lnGDP "natural log real GDP"
label var lnAIarts "natural log AI articles"
label var yrschoolSQ "average years education squared"


***Create the environment for a panel regression 
egen counts = group(countrycode)
drop if missing(lnGDP, tertiary, primary, yrschool, lnAIarts, yrschoolSQ)
tsset year counts




*limited multicollinearity and large sample size  

reg lnGDP tertiary secondary primary yrschool yrschoolSQ lnAIarts i.year if incomelevel == "LIC", robust
vif

**this one is an actual mincer equation but the multicollinearity is pretty large
reg lnGDP tertiary primary yrschool yrschoolSQ lnAIarts i.year if incomelevel == "LIC", robust


/*Either way there is a linear relationship between the presence of artificial intelligence and 
education in lics, although, the value is economically insignificant. I cannot identify
the direction of causality, though */
/*
reg lnGDP tertiary secondary primary yrschool lnAIarts i.year if incomelevel == "LIC", robust
esttab using mercerLIC.rtf, ///
se star(* 0.1 ** 0.05 *** 0.01) ///
label ///
r2 ar2 ///
title("Regression Results: Returns to Education LIC") replace
*/
****************************************************************************************************************************************
