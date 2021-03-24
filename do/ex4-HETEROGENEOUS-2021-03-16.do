// PRELIMINARIES

clear all
set more off
set scheme s1mono
set seed 1234

cd "C:\Users\pj\Dropbox\TWFE"

// generate data 

local units = 30
local periods = 40

set obs `units'
gen id = _n
gen x = rnormal() // individual characteristic

gen start = ceil(`periods'*runiform())
*replace start = `periods' + 1 if id>`units'*(3/4)
*replace start = `periods' + 1 if start<=15

expand `periods'
sort id
bys id:  gen time = _n

gen tempshock = rnormal() if id==1 // period-specific shock
bys time:  egen shock = max(tempshock)
drop tempshock

gen treatment = time>=start

** treatment effects
gen delta=3 // homogeneous
gen relativetime = time - start
replace delta = 6 if relativetime>=25
*gen delta = 3+ceil(5*runiform())

gen y = x + shock + delta*treatment + 5*rnormal()

reg y i.id i.time treatment, cluster(id)

reg treatment i.id i.time 
predict tresid, resid

reg y i.time i.id
predict yresid, resid

tw ///
	(scatter yresid tresid if treatment==0, msymbol(o) color(vermillion%20)) ///
	(scatter yresid tresid if treatment==1, msymbol(o) color(sea%20)) ///	
	(lpoly yresid tresid if treatment==0, lcolor(vermillion) lpattern(longdash) deg(1)) ///
	(lfit yresid tresid if treatment==0, lcolor(vermillion) lpattern(solid)) ///	
	(lpoly yresid tresid if treatment==1, lcolor(sea) lpattern(longdash) deg(1)) ///
	(lfit yresid tresid if treatment==1, lcolor(sea) lpattern(solid)), ///	
	legend(off)
graph export fig/example4-scatter-resid.pdf, replace

exit

gen beta = .
gen lower = .
gen upper = .
gen negative = .
gen gid = 24+_n in 1/16

forvalues i = 25/40 {
	quietly reg y treatment i.time i.id if time<=`i', cluster(id)
	mat V = r(table)
	local j = `i' - 24
	replace beta = V[1,1] in `j'
	replace lower = V[5,1] in `j'
	replace upper = V[6,1] in `j'
	quietly reg treatment i.time i.id if time<=`i'
	predict tempresid if time<=`i', resid
	gen temptest = (tempresid<0) if treatment==1 & time<=`i'
	sum temptest  if treatment==1 & time<=`i'
	replace negative = r(mean) in `j'
	drop tempresid temptest
}

*replace negative = 10*negative - 20
twoway ///	
	(rspike upper lower gid, lcolor(reddish%80) lwidth(thick)) ///
	(bar negative gid, bcolor(gs12) yaxis(2)) ///
	(rspike upper lower gid, lcolor(reddish%80) lwidth(thick)) ///
	(scatter beta gid, mcolor(sea*1.2) msymbol(s) msize(large)), ///
	legend(off) xlabel(25(5)40, noticks) yline(0, lcolor(gs10) lwidth(thin)) ///
	ylabel(2(0.5)4, noticks) xtitle(" " "Year") ytitle("Estimated Treatment Effect" " ") ///
	ylabel(0 "0" 1 "1" 5 " ", noticks axis(2)) ///
	ytitle(" " "Negative Weights in Treatment Group", axis(2))

	exit
	
tw ///
	(histogram tresid if treatment==0, frac width(0.05) bcolor(vermillion%40)) ///
	(histogram tresid if treatment==1, frac width(0.05) bcolor(sea%60)), ///
	xtitle(" " "Residualized Treatment") xlabel(-0.75(0.25)0.75) ///
	legend(order(2 1) label(1 "Comparison group") label(2 "Treatment group") ///
		col(1) ring(0) pos(11) size(small)) ///
	plotregion(margin(small))
graph export fig/example4-hist.pdf, replace

tw ///
	(scatter yresid tresid if treatment==0, msymbol(o) color(vermillion%20)) ///
	(scatter yresid tresid if treatment==1, msymbol(o) color(sea%20)) ///	
	(lpoly yresid tresid if treatment==0, lcolor(vermillion) lpattern(longdash) deg(1)) ///
	(lfit yresid tresid if treatment==0, lcolor(vermillion) lpattern(solid)) ///	
	(lpoly yresid tresid if treatment==1, lcolor(sea) lpattern(longdash) deg(1)) ///
	(lfit yresid tresid if treatment==1, lcolor(sea) lpattern(solid)), ///	
	legend(off)
graph export fig/example4-scatter-resid.pdf, replace	
