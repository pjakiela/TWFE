
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

gen txtres_pri = treatment*tres_pri

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

gen txtres_sec = treatment*tres_sec


// REGRESSIONS

reg yres_pri tres_pri treatment txtres_pri
mat V = r(table)
local _tempbeta1a = string(V[1,1],"%04.2f")
local _tempse1a = string(V[2,1],"%04.2f")
local _temppval1a = string(V[4,1],"%04.2f")
local _tempbeta1b = string(V[1,2],"%04.2f")
local _tempse1b = string(V[2,2],"%04.2f")
local _temppval1b = string(V[4,2],"%04.2f")
local _tempbeta1c = string(V[1,3],"%04.2f")
local _tempse1c = string(V[2,3],"%04.2f")
local _temppval1c = string(V[4,3],"%04.2f")

reg yres_sec tres_sec treatment txtres_sec
mat V = r(table)
local _tempbeta2a = string(V[1,1],"%04.2f")
local _tempse2a = string(V[2,1],"%04.2f")
local _temppval2a = string(V[4,1],"%04.2f")
local _tempbeta2b = string(V[1,2],"%04.2f")
local _tempse2b = string(V[2,2],"%04.2f")
local _temppval2b = string(V[4,2],"%04.2f")
local _tempbeta2c = string(V[1,3],"%04.2f")
local _tempse2c = string(V[2,3],"%04.2f")
local _temppval2c = string(V[4,3],"%04.2f")

cap file close fh
file open fh using tab/residreg.tex, write replace
file write fh "Residualized treatment & `_tempbeta1a' & `_tempbeta2a' \\ " _newline
file write fh "  & (`_tempse1a ') & (`_tempse2a ')  \\  " _newline
file write fh "  & [`_temppval1a'] & [`_temppval2a']\\ " _newline

file write fh "Treatment group & `_tempbeta1b' & `_tempbeta2b' \\ " _newline
file write fh "  & (`_tempse1b ') & (`_tempse2b ')  \\  " _newline
file write fh "  & [`_temppval1b'] & [`_temppval2b']\\ " _newline

file write fh "Treatment group $\times$ residualized treatment & `_tempbeta1c' & `_tempbeta2c' \\ " _newline
file write fh "  & (`_tempse1c ') & (`_tempse2c ')  \\  " _newline
file write fh "  & [`_temppval1c'] & [`_temppval2c']\\ " _newline

file close fh


