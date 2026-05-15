//
// Project: Punctuated decline of human cooperation




//
// Group characteristics of the interview sample

use ${interview_group_dataset}, clear

// preparation
generate loan_amount_coarse = .
replace loan_amount_coarse = 1 if loan_amount<=0.5
replace loan_amount_coarse = 2 if loan_amount>0.5 & loan_amount<1
replace loan_amount_coarse = 3 if loan_amount>=1

// analysis
tabulate group_size, m
tabulate loan_cycle, m
tabulate loan_amount_coarse, m




//
// Indvidual characteristics of the interview sample

use ${interview_individual_dataset}, clear

// preparation
generate children_coarse = children
replace children_coarse = 5 if children>5
generate monthly_sales_coarse = .
replace monthly_sales_coarse = 1 if monthly_sales<0.5
replace monthly_sales_coarse = 2 if monthly_sales>=0.5 & monthly_sales<1
replace monthly_sales_coarse = 3 if monthly_sales>=1 & monthly_sales<1.5
replace monthly_sales_coarse = 4 if monthly_sales>=1.5
generate ethnic_group_coarse = ethnic_group
replace ethnic_group_coarse = "other" if ethnic_group=="Mandingo" | ethnic_group=="Sherbro" | ethnic_group=="Yalunka" 

// analysis
tabulate gender, m
tabulate children_coarse, m
tabulate business_type, m
tabulate monthly_sales_coarse, m
tabulate ethnic_group_coarse, m
