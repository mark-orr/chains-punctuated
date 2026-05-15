//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals

// outcome variable to examine
local outcome "effortrate"
local controls "lnamtmemm i.nrterms i.schddateyear i.seasondummy"


//
// preparation

// number of cycles survived
egen total_cycles = max(loancycle), by(groupid)

// indicator of at last cycle
generate at_last_cycle = loancycle==total_cycles

// indicator of last round within cycle
egen total_rounds_in_cycle = max(schdnr), by(groupid loancycle)
generate at_last_round_in_cycle = schdnr==total_rounds_in_cycle

// indicator of round immediately before restart
generate about_to_restart = 0
replace about_to_restart = 1 if at_last_cycle==0 & at_last_round_in_cycle

// indicator of restart round
generate at_restart = 0
replace at_restart = 1 if schdnr==1 & loancycle>1

// indicator of transition number
generate transition_number = .
forvalues i=1/4 {
	replace transition_number=`i' if (loancycle==`i' & schdnr!=1 & total_cycles>`i') | (loancycle==`i'+1 & schdnr==1)
}

// round index that does not restart with every new cycle
forvalues i=1/5 {
	generate nrterms_cycle`i' = nrterms if loancycle==`i'
	bysort groupid (nrterms_cycle`i'): replace nrterms_cycle`i'=nrterms_cycle`i'[_n-1] if missing(nrterms_cycle`i') & _n>1
}
generate round_continuous = schdnr
replace round_continuous = round_continuous+nrterms_cycle1 if loancycle==2
replace round_continuous = round_continuous+nrterms_cycle1+nrterms_cycle2 if loancycle==3
replace round_continuous = round_continuous+nrterms_cycle1+nrterms_cycle2+nrterms_cycle3 if loancycle==4
replace round_continuous = round_continuous+nrterms_cycle1+nrterms_cycle2+nrterms_cycle3+nrterms_cycle4 if loancycle==5

// round-to-round change in outcome
bysort groupid (round_continuous): generate change_`outcome' = `outcome'[_n] - `outcome'[_n-1]

// set panel and generate variables
xtset groupid round_continuous



//
// analysis

// restart 1, groups that survive a given number of cycles or more
local j=1
local coefficients`j' "1 2 3"
xtreg change_`outcome' i.at_restart `controls' if total_cycles>=`j'+1 & transition_number==`j', fe vce(cluster groupid)
margins, dydx(at_restart)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
local p`j'_3 = m`j'[4,2]  // p-value of difference
margins at_restart
matrix l`j' = r(table)
local p`j'_1 = l`j'[4,1]  // p-value level 0
local p`j'_2 = l`j'[4,2]  // p-value level 1

// restart 2, groups that survive a given number of cycles or more
local j=2
local coefficients`j' "1 2 3"
xtreg change_`outcome' i.at_restart `controls' if total_cycles>=`j'+1 & transition_number==`j', fe vce(cluster groupid)
margins, dydx(at_restart)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
local p`j'_3 = m`j'[4,2]  // p-value of difference
margins at_restart
matrix l`j' = r(table)
local p`j'_1 = l`j'[4,1]  // p-value level 0
local p`j'_2 = l`j'[4,2]  // p-value level 1

// restart 3, groups that survive a given number of cycles or more
local j=3
local coefficients`j' "1 2 3"
xtreg change_`outcome' i.at_restart `controls' if total_cycles>=`j'+1 & transition_number==`j', fe vce(cluster groupid)
margins, dydx(at_restart)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
local p`j'_3 = m`j'[4,2]  // p-value of difference
margins at_restart
matrix l`j' = r(table)
local p`j'_1 = l`j'[4,1]  // p-value level 0
local p`j'_2 = l`j'[4,2]  // p-value level 1

// restart 4, groups that survive a given number of cycles or more
local j=4
local coefficients`j' "1 2 3"
xtreg change_`outcome' i.at_restart `controls' if total_cycles>=`j'+1 & transition_number==`j', fe vce(cluster groupid)
margins, dydx(at_restart)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
local p`j'_3 = m`j'[4,2]  // p-value of difference
margins at_restart
matrix l`j' = r(table)
local p`j'_1 = l`j'[4,1]  // p-value level 0
local p`j'_2 = l`j'[4,2]  // p-value level 1

// all restarts, all groups
local j=5
local coefficients`j' "1 2 3"
xtreg change_`outcome' i.at_restart i.transition_number `controls' if total_cycles>1 & transition_number!=., fe vce(cluster groupid)
margins, dydx(at_restart)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
local p`j'_3 = m`j'[4,2]  // p-value of difference
margins at_restart
matrix l`j' = r(table)
local p`j'_1 = l`j'[4,1]  // p-value level 0
local p`j'_2 = l`j'[4,2]  // p-value level 1




//
// create scalar p-values for print
forvalues j=1/5 {
	foreach k of numlist `coefficients`j'' {
		if `p`j'_`k''>=0.0001 {
			local pv`j'_`k' : display %6.4f `p`j'_`k''
			scalar pv`j'_`k'= "p=`pv`j'_`k''"  
		}
		else {
			scalar pv`j'_`k'="p<0.0001"
		}
	}
}	




