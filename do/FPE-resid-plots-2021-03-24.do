
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


// TESTING LINEAR RELATIONSHIP PRIMARY

tw ///
	(scatter yres_primary tres_primary if treatment==0, msymbol(o) color(vermillion%20)) ///
	(scatter yres_primary tres_primary if treatment==1, msymbol(o) color(sea%20)) ///	
	(lpoly yres_primary tres_primary if treatment==0, lcolor(vermillion) lpattern(longdash) deg(1) bw(0.1)) ///
	(lfit yres_primary tres_primary if treatment==0, lcolor(vermillion) lpattern(solid)) ///	
	(lpoly yres_primary tres_primary if treatment==1, lcolor(sea) lpattern(longdash) deg(1) bw(0.1)) ///
	(lfit yres_primary tres_primary if treatment==1, lcolor(sea) lpattern(solid)), ///	
	legend(order(2 1) cols(1) label(2 "Treatment observations") label(1 "Comparison observations") ///
	ring(0) pos(11)) ///
	xtitle(" " "Residualized Treatment") ytitle("Residualized Outcome" " ")
graph export fig/resid-scatter-pri.pdf, replace


// TESTING LINEAR RELATIONSHIP SECONDARY

tw ///
	(scatter yres_secondary tres_secondary if treatment==0, msymbol(o) color(vermillion%20)) ///
	(scatter yres_secondary tres_secondary if treatment==1, msymbol(o) color(sea%20)) ///	
	(lpoly yres_secondary tres_secondary if treatment==0, lcolor(vermillion) lpattern(longdash) deg(1) bw(0.1)) ///
	(lfit yres_secondary tres_secondary if treatment==0, lcolor(vermillion) lpattern(solid)) ///	
	(lpoly yres_secondary tres_secondary if treatment==1, lcolor(sea) lpattern(longdash) deg(1) bw(0.1)) ///
	(lfit yres_secondary tres_secondary if treatment==1, lcolor(sea) lpattern(solid)), ///	
	legend(order(2 1) cols(1) label(2 "Treatment observations") label(1 "Comparison observations") ///
	ring(0) pos(11))  ///
	xtitle(" " "Residualized Treatment") ytitle("Residualized Outcome" " ")
graph export fig/resid-scatter-sec.pdf, replace