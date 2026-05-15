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

// last cycle
egen total_cycles = max(loancycle), by(groupid)
generate at_last_cycle = loancycle==total_cycles

// indicator of last round within cycle
egen total_rounds_in_cycle = max(schdnr), by(groupid loancycle)
generate at_last_round_in_cycle = schdnr==total_rounds_in_cycle

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

// average outcome within group and cycle
forvalues i=1/2 {
	egen avg_`outcome`i'' = mean(`outcome`i''), by(groupid loancycle)
}

// proportion of rounds within cycle in rainy season
egen avg_rainy = mean(seasondummy), by(groupid loancycle)

// atomize loan size
generate lnamtmemm_bin = .
replace lnamtmemm_bin = 1 if lnamtmemm<=0.31
replace lnamtmemm_bin = 2 if lnamtmemm>0.31 & lnamtmemm<=0.41
replace lnamtmemm_bin = 3 if lnamtmemm>0.41 & lnamtmemm<=0.51
replace lnamtmemm_bin = 4 if lnamtmemm>0.51 & lnamtmemm<=0.7
replace lnamtmemm_bin = 5 if lnamtmemm>0.71 & lnamtmemm<=0.81
replace lnamtmemm_bin = 6 if lnamtmemm>0.81 & lnamtmemm!=.

// indicator of some presence in service business type
generate positive_service = propbtservicei>0

// indicator of first round
generate first_round = schdnr==1

// indicator majority of loan transactions in rainy season
generate majority_rainy = avg_rainy>0.5

// indicator not first cycle
generate not_first_cycle = loancycle>1

// set panel and generate variables
xtset groupid round_continuous



//
// analysis

// average of first cycle
local j=1
forvalues i=1/2 {
	local coefficients`j' "1 2 3 4 5 6 7 8 9 10 11 13 14 16"
	areg avg_`outcome`i'' nrterms groupsize propfemalei propmarriedi avgchildi avgmthsalesmi sdmthsalesmi avgbusequitymi sdbusequitymi btdiversityzi propbtpettyi i.positive_service lnamtmemm_bin i.majority_rainy i.branchid i.time_span_division i.schddateyear if loancycle==1 & at_last_round_in_cycle==1, absorb(officerid) vce(cluster groupid)
	matrix m`j' = r(table)
	scalar n`j' = e(N)
	scalar rsq`j' = e(r2)
	* p-vales
	foreach k of numlist `coefficients`j'' {
		local p`j'_`k' = m`j'[4,`k']
	}
	local j=`j'+2
}

// random effects all rounds and cycles
local j=2
forvalues i=1/2 {
	local coefficients`j' "1 2 3 4 5 6 7 8 9 10 11 13 14 16 18 22"
	xtreg `outcome`i'' nrterms groupsize propfemalei propmarriedi avgchildi avgmthsalesmi sdmthsalesmi avgbusequitymi sdbusequitymi btdiversityzi propbtpettyi i.positive_service lnamtmemm_bin i.seasondummy##i.not_first_cycle i.loancycle##c.schdnr i.time_span_division i.branchid i.officerid i.schddateyear, re vce(cluster groupid)
	matrix m`j' = r(table)
	scalar n`j' = e(N)
	scalar ng`j' = e(N_g)  // number of groups
	scalar rsq`j' = e(r2_o)  // overall R-squared
	* p-vales
	foreach k of numlist `coefficients`j'' {
		local p`j'_`k' = m`j'[4,`k']
	}
	local j=`j'+2
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




