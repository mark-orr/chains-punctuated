//
// Project: Punctuated decline of human cooperation

clear all
version 15.1  


//
// set globals

// project directory
*global project // ** TYPE PROJECT DIRECTORY HERE **

// data directory
global data "${project}/data"

// analysis code directory
global code "${project}/code"

// results directory
global output "${project}/results"

// temporary data directory
global temporary "${data}/temporary"

// figures source data directory
global figures_source_data "${data}/figures_source_data"

// quantitative dataset file
global quant_dataset "${data}/input/cooperation_quant.dta"

// interview dataset file, group characteristics
global interview_group_dataset "${data}/input/interview_group_characteristics.dta"

// interview dataset file, individual characteristics
global interview_individual_dataset "${data}/input/interview_individual_characteristics.dta"

// interview dataset file, cooperative motivations
global interview_motivations "${data}/input/interview_cooperative_motivations.dta"




//
// analysis code

// main text

// figure 1: cooperation rates over time
do "${code}/figure_1.do"

// figure 2: cooperation rates over time, no attrition
do "${code}/figure_2.do"

// figure 3: restart effect, no controls
do "${code}/figure_3a.do"
do "${code}/figure_3b.do"

// figure 4: interview data results
do "${code}/figure_4b.do"
do "${code}/figure_4c.do"

// table 1: cycle and round effect on contribution and effort rates
do "${code}/table_1.do"
markstat using "${output}/print_table_1.stmd", docx

// table 2: decay rate
do "${code}/table_2.do"
markstat using "${output}/print_table_2.stmd", docx


// extended data 

// figure ed1: distribution of groups by contribution level
do "${code}/figure_ed1.do"

// figure ed2: distribution of groups by effort level
do "${code}/figure_ed2.do"

// figure ed3: restart effect, controls
do "${code}/figure_ed3a.do"
do "${code}/figure_ed3b.do"

// table ed1: descriptieve statistics
do "${code}/table_ed1.do"
markstat using "${output}/print_table_ed1.stmd", docx

// table ed2: sequential restart effect, no controls
do "${code}/table_ed2a.do"
markstat using "${output}/print_table_ed2a.stmd", docx
do "${code}/table_ed2b.do"
markstat using "${output}/print_table_ed2b.stmd", docx

// table ed3: interview individual characteristics
* see input data file "interview_individual_characteristics.dta"

// table ed4: cooperative motivations in interviews
* see input data file "interview_cooperative_motivations.dta"

// table ed5: free-riding in interviews
* see input data file "interview_free_riding.dta"

// table ed6: cooperative patterns in interviews
* see input data file "interview_cooperative_patterns.dta"

// table ed7: group size transition matrices only for groups that survive
do "${code}/table_ed7.do"
markstat using "${output}/print_table_ed7.stmd", docx


// supplementary information 

// table s1: continuation status and sources of attrition
do "${code}/table_s1.do"
markstat using "${output}/print_table_s1.stmd", docx

// table s2: sequential restart effect, controls included
do "${code}/table_s2a.do"
markstat using "${output}/print_table_s2a.stmd", docx
do "${code}/table_s2b.do"
markstat using "${output}/print_table_s2b.stmd", docx

// table s3: comparison of restart effects, no controls 
do "${code}/table_s3a.do"
markstat using "${output}/print_table_s3a.stmd", docx
do "${code}/table_s3b.do"
markstat using "${output}/print_table_s3b.stmd", docx

// table s4: comparison of restart effects, controls included
do "${code}/table_s4a.do"
markstat using "${output}/print_table_s4a.stmd", docx
do "${code}/table_s4b.do"
markstat using "${output}/print_table_s4b.stmd", docx

// table s5: cycle effect on contribution and effort rates
do "${code}/table_s5.do"
markstat using "${output}/print_table_s5.stmd", docx

// table s6: interview group characteristics
* see input data file "interview_group_characteristics.dta"

// table s7: interview staff characteristics
* see input data file "interview_staff_characteristics.dta"

// table s8: last round effect
do "${code}/table_s8.do"
markstat using "${output}/print_table_s8.stmd", docx

// table s9: explaining contribution and effort rate
do "${code}/table_s9.do"
markstat using "${output}/print_table_s9.stmd", docx

// table s10: group size transition matrices
do "${code}/table_s10.do"
markstat using "${output}/print_table_s10.stmd", docx









