
// Regressions and figures for:
// Simple Diagnostics for Two-Way Fixed Effects
// by Pamela Jakiela
// March 24, 2021


clear all

// Figure 1:  histograms of TWFE regression weights (residualized treatment)
do FPE-weights-histograms-2021-03-24.do

// Figure 2:  TWFE regression weights by country and year
do FPE-heatmap-2021-03-24.do

// Figure 3:  residual scatter plots
do FPE-resid-plots-2021-03-24.do

// Figure 4:  dropping later years as a robustness check
do FPE-later-years-2021-03-24.do

// Online Appendix Table A2:  TWFE estimates of treatment effects
do FPE-TWFE-regressions-2021-03-24.do

// Online Appendix Table A3:  relationship between residuals
do FPE-resid-regs-2021-03-24.do

// Online Appendix Figure A1:  dropping post-treatment years as a robustness check
do FPE-relative-time-2021-03-24.do

// Online Appendix Figure A2: dropping countries as a robustness check
do FPE-jackknife-2021-03-24.do


