//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals



//
// preparation

// number of cycles survived
egen total_cycles = max(loancycle), by(groupid)

// indicator of at last cycle
generate at_last_cycle = loancycle==total_cycles

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



//
// collpse to one observation per group-cycle and expand sample to fully balanced panel to keep track of groups that dropped
// denote as group size 0 groups not observed that repaid 100% in all rounds of the last observed cycle
// denote as group size -1 groups not observed that are not 0
sort groupid loancycle scheduled_running_month
collapse (mean) groupsize contrate effortrate (last) scheduled_running_month, by(groupid loancycle)
xtset groupid loancycle
xtdescribe
xtpatternvar, generate(panel_pattern)
drop if strpos(panel_pattern, ".111.") | strpos(panel_pattern, "1.1..") | strpos(panel_pattern, "1.111") 

// expand sample to 5 timepoints for all units
bysort groupid (loancycle): generate toexpand = _n==_N & _N<5
bysort groupid (loancycle): generate times_toexpand = 5 - _N
generate expanded=0
forvalues i=1/4 {
	expand `i'+1 if toexpand==1 & times_toexpand==`i', generate(expanded_`i'times)
	replace expanded=1 if expanded_`i'times==1
	replace groupsize=0 if expanded==1 & contrate==100
	replace groupsize=-1 if expanded==1 & contrate<100
	drop expanded_`i'times
}
drop toexpand
rename times_toexpand times_expanded
bysort groupid (loancycle expanded): replace loancycle = _n if expanded==1

// posterior group size
sort groupid loancycle
generate posterior_groupsize = F.groupsize

// truncated due to end of data collection period
generate truncated = scheduled_running_month>=67

// continue to next cycle
generate continued = groupsize>0 & posterior_groupsize>0
generate continued_partial = continued==1 & contrate<100

// late according to our own consideration
generate late = effortrate<75

// transition cases
generate transition = .
replace transition = 1 if continued  // continue to next cycle
replace transition = 2 if continued==0 & contrate==100 & late==0 & truncated==0  // do not continue but paid in full on time
replace transition = 3 if continued==0 & contrate==100 & late==1 & truncated==0  // do not continue but paid in full late
replace transition = 4 if continued==0 & contrate<100 & truncated==0
replace transition = 5 if continued==0 & truncated==1

drop if groupsize<=0



//
// analysis

forvalues i=1/4 {
	tab transition if loancycle==`i' , matcell(x`i')
	local N = r(N)
	scalar N`i' = `N'
	forvalues j=1/5 {
		scalar xt`i'_`j' = (x`i'[`j',1]/`N')*100
	}
}

