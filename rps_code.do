/* Connor Martins - EC 329 Term Project Do-File */

/* ------------- Load Data from OneDrive ------------ */
use "C:\Users\CMARTINS\OneDrive - Bentley University\Senior First\EC 329\Term Project\rps_data.dta", clear

* Tell stata that this is panel data:
xtset state year

* Drop all observations outside of PA, WV, MI, and MD:
keep if state_nm=="PA" | state_nm=="WV" | state_nm=="MI" | state_nm=="MD"

/* ----------- Check Graphically for Parallel Trends ---------- */

* Plot all outcomes for PA vs WV:
twoway (line ren_nrg year if state_nm == "PA", sort lcolor(edkblue)) (line ren_nrg year if state_nm == "WV", sort lcolor(red)), xline(2004)

twoway (line co2_em year if state_nm == "PA", sort lcolor(edkblue)) (line co2_em year if state_nm == "WV", sort lcolor(red)), xline(2004)

twoway (line price year if state_nm == "PA", sort lcolor(edkblue)) (line price year if state_nm == "WV", sort lcolor(red)), xline(2004)

* Plot all outcomes for MI vs MD:
twoway (line ren_nrg year if state_nm == "MI", sort lcolor(edkblue)) (line ren_nrg year if state_nm == "MD", sort lcolor(red)), xline(2008)

twoway (line co2_em year if state_nm == "MI", sort lcolor(edkblue)) (line co2_em year if state_nm == "MD", sort lcolor(red)), xline(2008)

twoway (line price year if state_nm == "MI", sort lcolor(edkblue)) (line price year if state_nm == "MD", sort lcolor(emerald)), xline(2008)

/* ----------- Prepare for DiD Estimation ---------- */

* Generate relevant treatment and post variables for DiD:
gen pa_treat = (state_nm=="PA")
gen mi_treat = (state_nm=="MI")

gen pa_post = (year>=2004)
gen mi_post = (year>=2008)

* Generate interaction terms:
gen pa_interaction = pa_treat*pa_post
gen mi_interaction = mi_treat*mi_post

/* ------------- Initial DiD OLS Models ------------ */

* PA vs. WV:
reg ren_nrg pa_treat pa_post pa_interaction population state_gdp hdd cdd
outreg2 using pa_init_ols_results.doc, replace

reg co2_em pa_treat pa_post pa_interaction population state_gdp hdd cdd
outreg2 using pa_init_ols_results.doc, append

reg price pa_treat pa_post pa_interaction population state_gdp hdd cdd
outreg2 using pa_init_ols_results.doc, append

* MI vs. MD:
reg ren_nrg mi_treat mi_post mi_interaction population state_gdp hdd cdd
outreg2 using mi_init_ols_results.doc, replace

reg co2_em mi_treat mi_post mi_interaction population state_gdp hdd cdd
outreg2 using mi_init_ols_results.doc, append

reg price mi_treat mi_post mi_interaction population state_gdp hdd cdd
outreg2 using mi_init_ols_results.doc, append

/* ------------- DiD OLS Models with Log Outcomes------------ */

* Take the LN of the outcome variables for coeff interpretations:
gen ln_ren_nrg = log(ren_nrg)
gen ln_co2_em = log(co2_em)
gen ln_price = log(price)

* PA vs. WV:
reg ln_ren_nrg pa_treat pa_post pa_interaction population state_gdp hdd cdd
outreg2 using pa_ln_ols_results.doc, replace

reg ln_co2_em pa_treat pa_post pa_interaction population state_gdp hdd cdd
outreg2 using pa_ln_ols_results.doc, append

reg ln_price pa_treat pa_post pa_interaction population state_gdp hdd cdd
outreg2 using pa_ln_ols_results.doc, append

* MI vs. MD:
reg ln_ren_nrg mi_treat mi_post mi_interaction population state_gdp hdd cdd
outreg2 using mi_ln_ols_results.doc, replace

reg ln_co2_em mi_treat mi_post mi_interaction population state_gdp hdd cdd
outreg2 using mi_ln_ols_results.doc, append

reg ln_price mi_treat mi_post mi_interaction population state_gdp hdd cdd
outreg2 using mi_ln_ols_results.doc, append

/* -------- DiD models with Fixed Effects-------- */

* PA vs. WV
reghdfe ln_ren_nrg i.pa_treat##i.pa_post population state_gdp hdd cdd, absorb (state_nm year)
outreg2 using pa_ln_fe_results.doc, replace

reghdfe ln_co2_em i.pa_treat##i.pa_post population state_gdp hdd cdd, absorb (state_nm year)
outreg2 using pa_ln_fe_results.doc, append

reghdfe ln_price i.pa_treat##i.pa_post population state_gdp hdd cdd, absorb (state_nm year)
outreg2 using pa_ln_fe_results.doc, append


* MI vs. MD
reghdfe ln_ren_nrg i.mi_treat##i.mi_post population state_gdp hdd cdd, absorb (state_nm year)
outreg2 using mi_ln_fe_results.doc, replace

reghdfe ln_co2_em i.mi_treat##i.mi_post population state_gdp hdd cdd, absorb (state_nm year)
outreg2 using mi_ln_fe_results.doc, append

reghdfe ln_price i.mi_treat##i.mi_post population state_gdp hdd cdd, absorb (state_nm year)
outreg2 using mi_ln_fe_results.doc, append

/* -------- Parallel Trends Check on Population Variable -------- */
twoway (line population year if state_nm == "PA", sort lcolor(edkblue)) (line population year if state_nm == "WV", sort lcolor(red)), xline(2004)

twoway (line population year if state_nm == "MI", sort lcolor(edkblue)) (line population year if state_nm == "MD", sort lcolor(red)), xline(2008)
