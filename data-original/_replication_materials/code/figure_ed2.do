//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals

// outcome variable to examine
local outcome "effortrate"



//
// preparation

// number of cycles survived
egen total_cycles = max(loancycle), by(groupid)

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
// set panel and generate variables
duplicates drop groupid round_continuous, force
xtset groupid round_continuous



//
// analysis

// number of (unique) groups participating in total and in each cycle 
by groupid, sort: gen nvals = _n==1
count if nvals
drop nvals
by groupid loancycle, sort: gen nvals = _n==1
forvalues k=1/5 {
	count if nvals & loancycle==`k'
}

tempname memhold
postfile `memhold' total_cycles cycle round prop100 prop75 prop50 prop25 prop1 prop0 using `"${figures_source_data}/figure_ed2_source_data_distribution_`outcome'.dta"', replace

// all groups
forvalues i=1/6 {
	forvalues k=1/5 {
		sum `outcome' if repayq6==`i' & loancycle==`k'
		local Nt = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & `outcome'==100
		local N100 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & `outcome'<100 & `outcome'>=75
		local N75 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & `outcome'<75 & `outcome'>=50
		local N50 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & `outcome'<50 & `outcome'>=25
		local N25 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & `outcome'<25 & `outcome'>0
		local N1 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & `outcome'==0
		local N0 = r(N)
		foreach n of numlist 100 75 50 25 1 0 {
			local p`n' = `N`n''/`Nt'
		}
		post `memhold' (0) (`k') (`i') (`p100') (`p75') (`p50') (`p25') (`p1') (`p0')
	}
}

// groups that survive exactly z number of cycles
forvalues z=1/5 {  // max loan cycle
	forvalues i=1/6 {  // rescaled round
		forvalues k=1/`z' {  // loan cycle
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z'
		local Nt = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z' & `outcome'==100
		local N100 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z' & `outcome'<100 & `outcome'>=75
		local N75 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z' & `outcome'<75 & `outcome'>=50
		local N50 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z' & `outcome'<50 & `outcome'>=25
		local N25 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z' & `outcome'<25 & `outcome'>0
		local N1 = r(N)
		sum `outcome' if repayq6==`i' & loancycle==`k' & total_cycles>=`z' & `outcome'==0
		local N0 = r(N)
		foreach n of numlist 100 75 50 25 1 0 {
			local p`n' = `N`n''/`Nt'
		}
		post `memhold' (`z') (`k') (`i') (`p100') (`p75') (`p50') (`p25') (`p1') (`p0')
		}
	}
}

postclose `memhold'

// sort
use `"${figures_source_data}/figure_ed2_source_data_distribution_`outcome'.dta"', clear
sort total_cycles cycle round
save `"${figures_source_data}/figure_ed2_source_data_distribution_`outcome'.dta"', replace



