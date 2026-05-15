//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals

// outcome variable to examine
local outcome "contrate"
local controls ""


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

// groups that go through at least 2 restarts
local j=2
local coefficients`j' "3 4"
xtreg change_`outcome' i.at_restart##i.transition_number `controls' if total_cycles>=`j'+1 & transition_number<=`j', fe vce(cluster groupid)
margins, dydx(at_restart) over(transition_number)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
* p-vales
foreach k of numlist `coefficients`j'' {
	local p`j'_`k' = m`j'[4,`k']
}
contrast {at_restart -1 1}#{transition_number -1 1}, pveffects  // difference in restart effects 1-2
matrix d`j'_1 = r(table)
scalar pd`j'_1 = d`j'_1[4,1]

// groups that go through at least 3 restarts
local j=3
local coefficients`j' "4 5 6"
xtreg change_`outcome' i.at_restart##i.transition_number `controls' if total_cycles>=`j'+1 & transition_number<=`j', fe vce(cluster groupid)
margins, dydx(at_restart) over(transition_number)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
* p-vales
foreach k of numlist `coefficients`j'' {
	local p`j'_`k' = m`j'[4,`k']
}
contrast {at_restart -1 1}#{transition_number -1 1 0}, pveffects  // difference in restart effects 1-2
matrix d`j'_1 = r(table)
scalar pd`j'_1 = d`j'_1[4,1]
contrast {at_restart -1 1}#{transition_number 0 -1 1}, pveffects  // difference in restart effects 2-3
matrix d`j'_2 = r(table)
scalar pd`j'_2 = d`j'_2[4,1]

// groups that go through at least 4 restarts
local j=4
local coefficients`j' "5 6 7 8"
xtreg change_`outcome' i.at_restart##i.transition_number `controls' if total_cycles>=`j'+1 & transition_number<=`j', fe vce(cluster groupid)
margins, dydx(at_restart) over(transition_number)
matrix m`j' = r(table)
scalar n`j' = e(N)
scalar ng`j' = e(N_g)  // number of groups
scalar rsq`j' = e(r2)  // R-squared
* p-vales
foreach k of numlist `coefficients`j'' {
	local p`j'_`k' = m`j'[4,`k']
}
contrast {at_restart -1 1}#{transition_number -1 1 0 0}, pveffects  // difference in restart effects 1-2
matrix d`j'_1 = r(table)
scalar pd`j'_1 = d`j'_1[4,1]
contrast {at_restart -1 1}#{transition_number 0 -1 1 0}, pveffects  // difference in restart effects 2-3
matrix d`j'_2 = r(table)
scalar pd`j'_2 = d`j'_2[4,1]
contrast {at_restart -1 1}#{transition_number 0 0 -1 1}, pveffects  // difference in restart effects 3-4
matrix d`j'_3 = r(table)
scalar pd`j'_3 = d`j'_3[4,1]



//
// create scalar p-values for print
forvalues j=2/4 {
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



