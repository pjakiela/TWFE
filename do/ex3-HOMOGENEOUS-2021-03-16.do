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
*gen delta = 3+ceil(5*runiform())

gen y = x + shock + delta*treatment + 5*rnormal()

reg y i.id i.time treatment, cluster(id)

reg treatment i.id i.time 
predict tresid, resid

reg y i.time i.id
predict yresid, resid

tw ///
	(histogram tresid if treatment==0, frac width(0.05) bcolor(vermillion%40)) ///
	(histogram tresid if treatment==1, frac width(0.05) bcolor(sea%60)), ///
	xtitle(" " "Residualized Treatment") xlabel(-0.75(0.25)0.75) ///
	legend(order(2 1) label(1 "Comparison group") label(2 "Treatment group") ///
		col(1) ring(0) pos(11) size(small)) ///
	plotregion(margin(small))
graph export fig/example3-hist.pdf, replace

tw ///
	(scatter yresid tresid if treatment==0, msymbol(o) color(vermillion%20)) ///
	(scatter yresid tresid if treatment==1, msymbol(o) color(sea%20)) ///	
	(lpoly yresid tresid if treatment==0, lcolor(vermillion) lpattern(longdash) deg(1)) ///
	(lfit yresid tresid if treatment==0, lcolor(vermillion) lpattern(solid)) ///	
	(lpoly yresid tresid if treatment==1, lcolor(sea) lpattern(longdash) deg(1)) ///
	(lfit yresid tresid if treatment==1, lcolor(sea) lpattern(solid)), ///	
	legend(off)
graph export fig/example3-scatter-resid.pdf, replace	
