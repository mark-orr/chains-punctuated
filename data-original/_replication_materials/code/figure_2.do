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

// group panel for figure: survives a given number of cycles and continues to the next cycle
forvalues i=1/4 {
	generate group_panel_`i' = total_cycles>=`i'+1
}
generate group_panel_5 = total_cycles==5 & moves_to_cycle_6==1



//
// analysis

tempname memhold
postfile `memhold' outcome group_panel cycle round mean std_error N using `"${figures_source_data}/figure_2_source_data_mean_contrate_effortrate_no_attrition.dta"', replace

forvalues v=1/2 {  // outcome variable
	forvalues z=1/5 {  // group panel
		forvalues i=1/6 {  // rescaled round
			forvalues k=1/`z' {  // loan cycle
				sum `outcome`v'' if repayq6==`i' & loancycle==`k' & group_panel_`z'==1
				local mean = r(mean)
				local Nt = r(N)
				local std_error = r(sd)/sqrt(r(N))
				post `memhold' (`v') (`z') (`k') (`i') (`mean') (`std_error') (`Nt')
			}
		}
	}
}
postclose `memhold'

// sort 
use `"${figures_source_data}/figure_2_source_data_mean_contrate_effortrate_no_attrition.dta"', clear
sort group_panel outcome cycle round
save `"${figures_source_data}/figure_2_source_data_mean_contrate_effortrate_no_attrition.dta"', replace
