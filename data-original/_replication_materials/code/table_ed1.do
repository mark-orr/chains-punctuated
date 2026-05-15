//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals

// group and loan characteristics
local group_loan_vars "lnamtmemm nrterms groupsize propfemalei propmarriedi avgchildi avgmthsalesmi avgbusequitymi propbtpettyi propbtclothi propbtfoodi propbtitemi propbtservicei"



//
// preparation




//
// generate variables for analysis

// city indicators
tab city_main, generate(city_main)



//
// analysis

// group and loan characteristics
local j=1  // counter of variables
foreach var of varlist `group_loan_vars' {
	// all cycles
	forvalues i=0/0 {
		sum `var' if schdnr==1
		scalar mean`j'_`i' = r(mean)
		scalar sd`j'_`i' = r(sd)
	}
	// by cycle
	forvalues i=1/5 {
		sum `var' if schdnr==1 & loancycle==`i'
		scalar mean`j'_`i' = r(mean)
		scalar sd`j'_`i' = r(sd)
	}
	local j=`j'+1
}

// rainy season
* all cycles
forvalues i=0/0 {
	sum seasondummy
	scalar mean`j'_`i' = r(mean)
	scalar sd`j'_`i' = r(sd)
}
* by cycle
forvalues i=1/5 {
	sum seasondummy if loancycle==`i'
	scalar mean`j'_`i' = r(mean)
	scalar sd`j'_`i' = r(sd)
}
local j=`j'+1

// city
forvalues k=1/4 {  // city counter
	* all cycles
	forvalues i=0/0 {
		sum city_main`k' if schdnr==1
		scalar mean`j'_`i' = r(mean)
	}
	* by cycle
	forvalues i=1/5 {
		sum city_main`k' if schdnr==1 & loancycle==`i'
		scalar mean`j'_`i' = r(mean)
	}
	local j=`j'+1
}

// number of loans disbursed
* by cycle
forvalues i=1/5 {
	sum contrate if schdnr==1 & loancycle==`i'
	scalar n`j'_`i' = r(N)
}
* all cycles
forvalues i=0/0 {
	scalar n`j'_`i' = n`j'_1 + n`j'_2 + n`j'_3 + n`j'_4 + n`j'_5
}
local j=`j'+1

// number of transactions
* all cycles
forvalues i=0/0 {
	sum contrate
	scalar n`j'_`i' = r(N)
}
* by cycle
forvalues i=1/5 {
	sum contrate if loancycle==`i'
	scalar n`j'_`i' = r(N)
}
local j=`j'+1


