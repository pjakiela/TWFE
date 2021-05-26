// Example of Jakiela 2021 TWFE test
// Clear dataset
clear all
set scheme s1mono
set obs 120
set seed 1
gen unit=ceil(_n/12)
gen period=mod(_n-1,12)+1
gen treatedpost=cond(unit>period,1,0)
gen intensity=(unit-period)*treatedpost // this is intensity defined as how long treatment has happened for a unit

// y1 has a constant treatment effect
gen y1=0.1*invnorm(uniform()) + 5*treatedpost
// y2 has a nonlinear treatment effect in the intensity (duration) of treatment
gen y2=0.02*invnorm(uniform()) + 0.02*intensity*intensity*intensity

// what do the TWFE regressions show?
reg y1 treatedpost i.period i.unit  //  positive treatment effect for y1 as expected, very close to DGP parameter
reg y2 treatedpost i.period i.unit  //  wrongly signed treatment effect for y2 - all effects are positive but this est is negative

// construct residuals
qui reg y1 i.period i.unit
predict y1resid, resid
qui reg y2 i.period i.unit
predict y2resid, resid
qui reg treatedpost i.period i.unit
predict xresid, resid

gen tpxresid=treatedpost*xresid

// conduct tests
reg y1resid xresid tpxresid
local tstatdiff1=" " + string(abs(_b[tpxresid]/_se[tpxresid]),"%5.4f")
reg y2resid xresid tpxresid
local tstatdiff2=" " + string(abs(_b[tpxresid]/_se[tpxresid]),"%5.4f")

reg y1resid xresid
reg y2resid xresid

gen xresid2=xresid*xresid
gen y1x=y1resid*xresid
qui sum xresid2
di r(sum)
local denom=r(sum)
qui sum y1x
di r(sum)
local numer=r(sum)
di "RATIO " `numer'/`denom'


// graph the two patterns
twoway (scatter y1resid xresid if treatedpost==1, msize(small) mcolor(blue) m(O)) ///
(scatter y1resid xresid if treatedpost==0, msize(small) mcolor(blue*0.5) m(Oh)) ///
      (scatter y2resid xresid if treatedpost==1, msize(small) mcolor(dkorange) m(O)) ///
      (scatter y2resid xresid if treatedpost==0, msize(small) mcolor(dkorange*0.5) m(Oh)), ///
	  legend(rows(1) label(1 oktreated) label(2 okUNtreated) label(3 timevaryingtreated) label(4 timevaryingUNtreated) size(small)) ///
	  note("T stat on homogeneous effect slope diff `tstatdiff1'; T stat on time varying slope diff `tstatdiff2'")



	  
