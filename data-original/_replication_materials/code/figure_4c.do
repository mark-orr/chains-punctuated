//
// Project: Punctuated decline of human cooperation




//
// Cooperative motivations in the interview sample

use ${interview_motivations}, clear

// preparation


// analysis

// own share
foreach var of varlist economic duty reputation solidarity {
	tabulate `var' if own_share==1
}

// other's share
foreach var of varlist economic duty reputation solidarity {
	tabulate `var' if own_share==0
}
