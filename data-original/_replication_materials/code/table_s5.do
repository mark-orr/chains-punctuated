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
// analysis

// contrate
local q=1 // outcome

// // all groups, round cycle main effects
local i=1
areg `outcome`q'' c.loancycle i.officerid lnamtmemm i.nrterms i.schddateyear i.seasondummy if schdnr==1, absorb(groupid) vce(cluster groupid)
local coefficients`i' "1"
matrix m`i' = r(table)
scalar n`i' = e(N)
scalar ng`i' = e(k_absorb)  // number of groups
scalar rsq`i' = e(r2)
* p-vales
foreach k of numlist `coefficients`i'' {
	local p`i'_`k' = m`i'[4,`k']
}

// // groups 5+, round cycle main effects
local i=2
areg `outcome`q'' c.loancycle i.officerid lnamtmemm i.nrterms i.schddateyear i.seasondummy if schdnr==1 & total_cycles==5, absorb(groupid) vce(cluster groupid)
local coefficients`i' "1"
matrix m`i' = r(table)
scalar n`i' = e(N)
scalar ng`i' = e(k_absorb)  // number of groups
scalar rsq`i' = e(r2)
* p-vales
foreach k of numlist `coefficients`i'' {
	local p`i'_`k' = m`i'[4,`k']
}



// effortrate
local q=2 // outcome

// // all groups, round cycle main effects
local i=3
areg `outcome`q'' c.loancycle i.officerid lnamtmemm i.nrterms i.schddateyear i.seasondummy if schdnr==1, absorb(groupid) vce(cluster groupid)
local coefficients`i' "1"
matrix m`i' = r(table)
scalar n`i' = e(N)
scalar ng`i' = e(k_absorb)  // number of groups
scalar rsq`i' = e(r2)
* p-vales
foreach k of numlist `coefficients`i'' {
	local p`i'_`k' = m`i'[4,`k']
}

// // groups 5+, round cycle main effects
local i=4
areg `outcome`q'' c.loancycle i.officerid lnamtmemm i.nrterms i.schddateyear i.seasondummy if schdnr==1 & total_cycles==5, absorb(groupid) vce(cluster groupid)
local coefficients`i' "1"
matrix m`i' = r(table)
scalar n`i' = e(N)
scalar ng`i' = e(k_absorb)  // number of groups
scalar rsq`i' = e(r2)
* p-vales
foreach k of numlist `coefficients`i'' {
	local p`i'_`k' = m`i'[4,`k']
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


