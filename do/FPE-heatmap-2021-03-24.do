
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



// HEATMAP

gen graphid = 1 if country=="Namibia"
replace graphid = 2 if country=="Burkina Faso"
replace graphid = 3 if country=="Lesotho"
replace graphid = 4 if country=="Benin"
replace graphid = 5 if country=="Burundi"
replace graphid = 6 if country=="Mozambique"
replace graphid = 7 if country=="Rwanda"
replace graphid = 8 if country=="Kenya"
replace graphid = 9 if country=="Zambia"
replace graphid = 10 if country=="Tanzania"
replace graphid = 11 if country=="Cameroon"
replace graphid = 12 if country=="Uganda"
replace graphid = 13 if country=="Ghana"
replace graphid = 14 if country=="Ethiopia"
replace graphid = 15 if country=="Malawi"

preserve
drop if primary==.
tw ///
	(scatter graphid year if year<fpe_year, msymbol(s) mlcolor(gs10) mfcolor(gs14) msize(vlarge)) ///
	(scatter graphid year if year>=fpe_year & tres_primary>0, msymbol(s) mcolor(vermillion*0.54) msize(vlarge)) ///
	(scatter graphid year if year>=fpe_year & tres_primary<0, msymbol(s) mcolor(cranberry) msize(vlarge)), ///
	aspect(0.4) plotregion(style(none)) ///
	ylabel(1 "Namibia" 2 "Burkina Faso" 3 "Lesotho" 4 "Benin" 5 "Burundi" ///
		6 "Mozambique" 7 "Rwanda" 8 "Kenya" 9 "Zambia" 10 "Tanzania" ///
		11 "Cameroon" 12 "Uganda" 13 "Ghana" 14 "Ethiopia" 15 "Malawi", ///
		angle(0) noticks labsize(small)) ytitle(" " ) yscale(lstyle(none)) ///
		legend(order(3 2 1) label(3 "Treatment observations - negative weight") ///
		label(2 "Treatment observations - positive weight") ///
		label(1 "Comparison observations") col(1)) xtitle(" ") xlabel(1980(5)2016)
graph export fig/heat-pri.pdf, replace
restore

preserve
drop if secondary==.
tw ///
	(scatter graphid year if year<fpe_year, msymbol(s) mlcolor(gs10) mfcolor(gs14) msize(vlarge)) ///
	(scatter graphid year if year>=fpe_year & tres_secondary>0, msymbol(s) mcolor(vermillion*0.54) msize(vlarge)) ///
	(scatter graphid year if year>=fpe_year & tres_secondary<0, msymbol(s) mcolor(cranberry) msize(vlarge)), ///
	aspect(0.4) plotregion(style(none)) ///
	ylabel(1 "Namibia" 2 "Burkina Faso" 3 "Lesotho" 4 "Benin" 5 "Burundi" ///
		6 "Mozambique" 7 "Rwanda" 8 "Kenya" 9 "Zambia" 10 "Tanzania" ///
		11 "Cameroon" 12 "Uganda" 13 "Ghana" 14 "Ethiopia" 15 "Malawi", ///
		angle(0) noticks labsize(small)) ytitle(" " ) yscale(lstyle(none)) ///
		legend(order(3 2 1) label(3 "Treatment observations - negative weight") ///
		label(2 "Treatment observations - positive weight") ///
		label(1 "Comparison observations") col(1)) xtitle(" ") xlabel(1980(5)2016)
graph export fig/heat-sec.pdf, replace
restore



