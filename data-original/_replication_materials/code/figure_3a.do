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

tempname memhold
postfile `memhold' restart_number restart_round mean std_error N using `"${figures_source_data}/figure_3_source_data_restart_no_controls_`outcome'.dta"', replace

forvalues i=1/4 {
	forvalues j=0/1 {
		sum change_`outcome' if at_restart==`j' & total_cycles>=`i'+1 & transition_number==`i'
		local mean = r(mean)
		local Nt = r(N)
		local std_error = r(sd)/sqrt(r(N))
		post `memhold' (`i') (`j') (`mean') (`std_error') (`Nt')
	}
}
postclose `memhold'
