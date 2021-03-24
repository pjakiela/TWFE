
// PRELIMINARIES

clear all
set more off
set scheme s1mono
set seed 123456

// LOAD DATA

cd "C:\Users\pj\Dropbox\TWFE"
use "data\WDI-FPE-data.dta"


// TWFE ESTIMATE OF TREATMENT EFFECTS

reg primary treatment i.year i.id, cluster(country)
mat V = r(table)
local _tempbeta1 = string(V[1,1],"%04.2f")
local _tempse1 = string(V[2,1],"%04.2f")
local _temppval1 = string(V[4,1],"%04.2f")

reg secondary treatment i.year i.id, cluster(country)
mat V = r(table)
local _tempbeta2 = string(V[1,1],"%04.2f")
local _tempse2 = string(V[2,1],"%04.2f")
local _temppval2 = string(V[4,1],"%04.2f")

cap file close fh
file open fh using tab/twfereg.tex, write replace
file write fh "Free primary education & `_tempbeta1' & `_tempbeta2' \\ " _newline
file write fh "  & (`_tempse1 ') & (`_tempse2 ')  \\  " _newline
file write fh "  & [`_temppval1'] & [`_temppval2']\\ " _newline

file close fh


