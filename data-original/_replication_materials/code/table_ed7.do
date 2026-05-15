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

collapse (mean) groupsize contrate, by(groupid loancycle)
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



//
// analysis

// compute transition probabilities by cycle
forvalues i=1/4 {
	display "transition from cycle " `i' " to cycle " `i'+1 ":"
	tab groupsize posterior_groupsize if loancycle==`i' & groupsize>0 & F.groupsize>0, row matcell(x`i')
}

// values for table
* transitions 1, 2, 3
forvalues i=1/3 {
	forvalues j=1/5 {
		scalar xt`i'_`j' = x`i'[`j',1] + x`i'[`j',2] + x`i'[`j',3] + x`i'[`j',4] + x`i'[`j',5]
	}
}
* transition 4
forvalues i=4/4 {
	forvalues j=1/5 {
		scalar xt`i'_`j' = x`i'[`j',1] + x`i'[`j',2] + x`i'[`j',3] + x`i'[`j',4]
	}
}



