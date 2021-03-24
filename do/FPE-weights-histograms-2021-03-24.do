
// PRELIMINARIES

clear all
set more off
set scheme s1mono
set seed 123456

// LOAD DATA

cd "C:\Users\pj\Dropbox\TWFE"
use "data\WDI-FPE-data.dta"



// GENERATE WEIGHTS

** primary

reg primary i.year i.id
predict yres_primary, resid
replace yres_primary = . if primary==.

reg treatment i.year i.id if primary!=.
predict tres_primary, resid
replace tres_primary = . if primary==.

gen tresp2 = tres_primary*tres_primary if primary!=.
egen tvariance = sum(tresp2)
gen weight_primary = tres_primary/tvariance 
replace weight_primary = . if primary==.

gen yxtres_primary = primary*tres_primary if primary!=.
egen numer = sum(yxtres_primary)
gen betahat = numer/tvariance

drop tresp2 tvariance numer betahat

** secondary

reg secondary i.year i.id
predict yres_secondary, resid
replace yres_secondary = . if secondary==.

reg treatment i.year i.id if secondary!=.
predict tres_secondary, resid
replace tres_secondary = . if secondary==.

gen tresp2 = tres_secondary*tres_secondary if secondary!=.
egen tvariance = sum(tresp2)
gen weight_secondary = tres_secondary/tvariance 
replace weight_secondary = . if secondary==.

gen yxtres_secondary = secondary*tres_secondary if secondary!=.
egen numer = sum(yxtres_secondary)
gen betahat = numer/tvariance

drop tresp2 tvariance numer betahat



// HISTOGRAMS OF WEIGHTS
tw ///
	(histogram weight_primary if treatment==0, frac bcolor(vermillion%40)) ///
	(histogram weight_primary if treatment==1, frac bcolor(sea%60)), ///
	xtitle(" " "Residualized Treatment") xlabel(-0.03(0.01)0.03) ///
	legend(order(2 1) label(1 "Comparison group") label(2 "Treatment group") col(1) ring(0) pos(11) size(small)) ///
	plotregion(margin(small))
graph export fig/weights-pri.pdf, replace

tw ///
	(histogram weight_secondary if treatment==0, frac bcolor(vermillion%40)) ///
	(histogram weight_secondary if treatment==1, frac bcolor(sea%60)), ///
	xtitle(" " "Residualized Treatment") xlabel(-0.04(0.01)0.04) ///
	ylabel(0(0.05)0.25) ///
	legend(order(2 1) label(1 "Comparison group") label(2 "Treatment group") col(1) ring(0) pos(11) size(small)) ///
	plotregion(margin(small))
graph export fig/weights-sec.pdf, replace


