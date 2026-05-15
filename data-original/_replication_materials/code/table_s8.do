//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals

// outcome variable to examine
local outcome1 "contrate"
local outcome2 "effortrate"


//
// preparation

// number of cycles survived
egen total_cycles = max(loancycle), by(groupid)

// indicator of last round within cycle
egen total_rounds_in_cycle = max(schdnr), by(groupid loancycle)
generate at_last_round_in_cycle = schdnr==total_rounds_in_cycle

// indicator of second to last round within cycle
generate at_second_to_last_round = schdnr==total_rounds_in_cycle-1

// indicator of third to last round within cycle
generate at_third_to_last_round = schdnr==total_rounds_in_cycle-2

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

// drop groups with only two scheduled payments and thus no 3rd to last round in the cycle
drop if total_rounds_in_cycle==2


//
// set panel and generate variables
duplicates drop groupid round_continuous, force
xtset groupid round_continuous



//
// analysis

// last round effect
local i=1
forvalues j=1/2 {
	local coefficients`i' "2 8"
	xtreg `outcome`j'' i.at_last_round_in_cycle i.loancycle if (at_last_round_in_cycle==1 | at_second_to_last_round==1), fe vce(cluster groupid)
	matrix m`i' = r(table)
	scalar n`i' = e(N)
	scalar ng`i' = e(N_g)  // number of groups
	scalar rsq`i' = e(r2)
	* p-vales
	foreach k of numlist `coefficients`i'' {
		local p`i'_`k' = m`i'[4,`k']
	}
	local i=`i'+2
}

// second to last round effect
local i=2
forvalues j=1/2 {
	local coefficients`i' "2 8"
	xtreg `outcome`j'' i.at_second_to_last_round i.loancycle if (at_second_to_last_round==1 | at_third_to_last_round==1), fe vce(cluster groupid)
	matrix m`i' = r(table)
	scalar n`i' = e(N)
	scalar ng`i' = e(N_g)  // number of groups
	scalar rsq`i' = e(r2)
	* p-vales
	foreach k of numlist `coefficients`i'' {
		local p`i'_`k' = m`i'[4,`k']
	}
	local i=`i'+2
}



//
// create significance stars for regressions above
forvalues j=1/4 {
	foreach k of numlist `coefficients`j'' {
		if `p`j'_`k''<0.1 & `p`j'_`k''>=0.05 {
			scalar st`j'_`k'="*"
		}
		else if `p`j'_`k''<0.05 & `p`j'_`k''>=0.01 {
			scalar st`j'_`k'="**"
		}
		else if `p`j'_`k''<0.01 & `p`j'_`k''>=0.001 {
			scalar st`j'_`k'="***"
		}
		else if `p`j'_`k''<0.001 {
			scalar st`j'_`k'="****"
		}
		else {
			scalar st`j'_`k'=""
		}
	}
}


//
// create scalar p-values for print
forvalues j=1/4 {
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

