
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


// DROPPING LATER YEARS - PRIMARY

preserve
drop if primary==.
cap drop beta lower upper negative gid labvar labpos
gen beta = .
gen lower = .
gen upper = .
gen negative = .
gen gid = 1999 + _n in 1/16

forvalues i = 2000/2015 {
	quietly reg primary treatment i.year i.id if year<=`i', cluster(country)
	mat V = r(table)
	local j = `i' - 1999
	replace beta = V[1,1] in `j'
	replace lower = V[5,1] in `j'
	replace upper = V[6,1] in `j'
	quietly reg treatment i.year i.id if year<=`i'
	predict tempresid if year<=`i', resid
	gen temptest = (tempresid<0) if treatment==1 & year<=`i'
	sum temptest  if treatment==1 & year<=`i'
	replace negative = r(mean) in `j'
	drop tempresid temptest
}

gen labvar = round(100*negative)/100
replace labvar = . if labvar==0
gen labpos = negative+0.1
twoway ///	
	(rspike upper lower gid, lcolor(reddish%80) lwidth(thick)) ///
	(bar negative gid, base(0) bcolor(turquoise*0.64) barw(0.96) yaxis(2)) ///
	(scatter labpos gid if negative>0, msymbol(i) mlabcolor(turquoise) mlabel(labvar) mlabsize(vsmall) mlabpos(0) yaxis(2)) ///
	(rspike upper lower gid, lcolor(reddish%80) lwidth(thick)) ///
	(scatter beta gid, mcolor(sea*1.2) msymbol(s) msize(large)), ///
	legend(off) xlabel(2000(5)2015, noticks) yline(0, lcolor(gs10) lwidth(thin)) ///
	ylabel(-20(20)80, noticks) xtitle(" " "Year") ytitle("Estimated Treatment Effect" " ") ///
	ylabel(0 " " 5 " ", noticks labcolor(turquoise) axis(2) angle(0) labsize(small)) ///
	ytitle(" ", axis(2)) ///
	text(-8 2015.625 "Proportion of treatment observations receiving negative weight", color(turquoise) size(small) place(w))
graph export fig/effect-by-year-primary.pdf, replace

restore


// DROPPING LATER YEARS - SECONDARY

preserve
drop if secondary==.
cap drop beta lower upper negative gid labvar labpos
gen beta = .
gen lower = .
gen upper = .
gen negative = .
gen gid = 1999 + _n in 1/16

forvalues i = 2000/2015 {
	quietly reg secondary treatment i.year i.id if year<=`i', cluster(country)
	mat V = r(table)
	local j = `i' - 1999
	replace beta = V[1,1] in `j'
	replace lower = V[5,1] in `j'
	replace upper = V[6,1] in `j'
	quietly reg treatment i.year i.id if year<=`i'
	predict tempresid if year<=`i', resid
	gen temptest = (tempresid<0) if treatment==1 & year<=`i'
	sum temptest  if treatment==1 & year<=`i'
	replace negative = r(mean) in `j'
	drop tempresid temptest
}

gen labvar = round(100*negative)/100
replace labvar = . if labvar==0
gen labpos = negative+0.1
twoway ///	
	(rspike upper lower gid, lcolor(reddish%80) lwidth(thick)) ///
	(bar negative gid, base(0) bcolor(turquoise*0.64) barw(0.96) yaxis(2)) ///
	(scatter labpos gid if negative>0, msymbol(i) mlabcolor(turquoise) mlabel(labvar) mlabsize(vsmall) mlabpos(0) yaxis(2)) ///
	(rspike upper lower gid, lcolor(reddish%80) lwidth(thick)) ///
	(scatter beta gid, mcolor(sea*1.2) msymbol(s) msize(large)), ///
	legend(off) xlabel(2000(5)2015, noticks) yline(0, lcolor(gs10) lwidth(thin)) ///
	ylabel(-15(5)15, noticks) xtitle(" " "Year") ytitle("Estimated Treatment Effect" " ") ///
	ylabel(0 " " 5 " ", noticks labcolor(turquoise) axis(2) angle(0) labsize(small)) ///
	ytitle(" ", axis(2)) ///
	text(-11 2015.625 "Proportion of treatment observations receiving negative weight", color(turquoise) size(small) place(w))
graph export fig/effect-by-year-secondary.pdf, replace

restore