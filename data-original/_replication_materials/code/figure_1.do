//
// Project: Punctuated decline of human cooperation



use ${quant_dataset}, clear



//
// set locals

// outcome variable to examine
local outcome1 "contrate"
local outcome2 "effortrate"
local groups "895 3 6 449 17 18 835 879"


//
// preparation



//
// analysis

// means
forvalues v=1/2 {
	tempname memhold
	postfile `memhold' cycle round mean using `"${figures_source_data}/figure_1_source_data_mean_`outcome`v''.dta"', replace
	forvalues k=1/5 {
		forvalues i=1/6 {
			sum `outcome`v'' if repayq6==`i' & loancycle==`k'
			local mean = r(mean)
			post `memhold' (`k') (`i') (`mean')
		}
	}
	postclose `memhold'
}

// individual groups
use ${quant_dataset}, clear
forvalues v=1/2 {
	tempname memhold
	postfile `memhold' groupid grouplabel cycle round outcome using `"${figures_source_data}/figure_1_source_data_individual_`outcome`v''.dta"', replace
	local grouplabel = 1
	foreach g in `groups' {
		forvalues k=1/5 {	
			forvalues i=1/6 {
				sum `outcome`v'' if repayq6==`i' & loancycle==`k' & groupid==`g'
				local mean = r(mean)
				post `memhold' (`g') (`grouplabel') (`k') (`i') (`mean')
			}
		}
		local grouplabel = `grouplabel' + 1
	}
	postclose `memhold'
}



