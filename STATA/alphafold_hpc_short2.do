use "/scratch/kl4898/aiscience/STATA/alphafold.dta", clear

* id_numeric to numeric
destring id_numeric, replace

* setting xtset
xtset id_numeric publication_month

* dummy for post treatment
gen post = (publication_month >= treatment_month)

* create dummy variables for -24 to 24 months from treatment_month
forvalues t = 0/48 {
    gen time_`t' = (months_from_treatment == `t'-24)
}

* create variables
// egen pmonth = group(publication_month)
// egen tmonth = group(treatment_month)
encode domain_max, gen(domain)
encode field_max, gen(field)
bysort id (publication_month) : gen cum_count = sum(count)
bysort id (publication_month) : gen cum_afcount = sum(af_count)
bysort id (publication_month) : gen topic_hhi_diff = topic_hhi_total - topic_hhi_total[_n-1]
bysort id (publication_month) : gen subfield_hhi_diff = subfield_hhi_total - subfield_hhi_total[_n-1]
bysort id (publication_month) : gen field_hhi_diff = field_hhi_total - field_hhi_total[_n-1]
bysort id (publication_month) : gen domain_hhi_diff = domain_hhi_total - domain_hhi_total[_n-1]


generate early = (treatment_month <= tc(1jul2022 00:00:00))

gen pdate = dofc(publication_month)
format pdate %td
gen publication_month_str = string(year(pdate)) + "-" + string(month(pdate), "%02.0f")
egen pmonth = group(publication_month_str)

gen tdate = dofc(treatment_month)
format tdate %td
gen treatment_month_str = string(year(tdate)) + "-" + string(month(tdate), "%02.0f")
egen tmonth = group(treatment_month_str)


* event study regression (timeframe -24 to 24)
mark basic_filter if fuzzy_matched_name_count<=2 & tenure<=50 & max_monthly_pubs<=20 & months_from_treatment!=0
mark balanced_12 if pre_obs<=-12 & post_obs >=12
mark balanced_24 if pre_obs<=-24 & post_obs >=24
mark obs_12 if abs(months_from_treatment)<=12
mark obs_24 if abs(months_from_treatment)<=24


* Define lists of dependent and independent variables
local dep_vars "count _2023_JIF_sum topic_hhi_total subfield_hhi_total field_hhi_total domain_hhi_total topics_hhi_diff subfields_hhi_diff fields_hhi_diff domains_hhi_diff"
local indep_vars1 "post"
local indep_vars2 "post#i.tmonth"
local indep_vars3 "post#i.domain"
local indep_vars4 "post#i.field"

local control_vars "months_from_start cum_count"
local time_fe "i.pmonth"
local time_vars "time_*"

local filter1 "1"
local filter2 "balanced_12"
local filter3 "balanced_24"
local filter4 "obs_12"
local filter5 "obs_24"
local filter6 "is_ls"
local filter7 "balanced_12 & is_ls"
local filter8 "balanced_24 & is_ls"
local filter9 "obs_12 & is_ls"
local filter10 "obs_24 & is_ls"
local filter11 "is_ls_first"
local filter12 "balanced_12 & is_ls_first"
local filter13 "balanced_24 & is_ls_first"
local filter14 "obs_12 & is_ls_first"
local filter15 "obs_24 & is_ls_first"
local filter16 "is_ls_last"
local filter17 "balanced_12 & is_ls_last"
local filter18 "balanced_24 & is_ls_last"
local filter19 "obs_12 & is_ls_last"
local filter20 "obs_24 & is_ls_last"
/*
I'm going to use filters 6,8,10, 11,13,15, 16,18,20
specifications 1
dv count, _2023_JIF_sum, hhi total
*/
/*
What should I do?
- Creat dummy variable for early and late adopters
- Run loops for different DV, IVs, and filters
- IVs
	- post(DID)
	- post # time of adoption (doesn't work for event study, but maybe I can still do early vs late adopters)
- Controls
	- post # field or domain
	- cum_count, cum_afcount
- Filters
*/

keep if basic_filter
* Start a loop over dependent variables
forvalues filter = 6/15{
	preserve
	keep if `filter`filter''
	foreach y of local dep_vars {
		forvalues spec = 1/4 {
			capture xtreg `y' `indep_vars`spec'' `time_fe' , fe vce(cluster id_numeric)
			if _rc == 0 {
				estimates save did_`y'_`filter'_`spec', append
				outreg2 using results_`y'_`filter'_`spec'.doc, append ctitle(No Controls) keep(`indep_vars`spec'')
			}
			capture xtreg `y' `indep_vars`spec'' `control_vars' `time_fe' , fe vce(cluster id_numeric)
			if _rc == 0 {
				estimates save did_`y'_`filter'_`spec', append
			* Output results
				outreg2 using results_`y'_`filter'_`spec'.doc, append ctitle(With Controls) keep(`indep_vars`spec'')
		}
	}
		capture xtreg `y' `time_vars' `time_fe' , fe vce(cluster id)
		if _rc == 0 {
			estimates save es_`y'_`filter', append
			outreg2 using results_event_`y'_`filter'.doc, append ctitle(No Controls) keep(`time_vars')
			coefplot, keep(time_*) drop(_cons) xline(0) xtitle(Months from Treatment) ytitle(Effect) title("`y' - Event Study (No Control)")
			graph export "`y'_event_study_plot_`filter'.png", replace
			}
		capture xtreg `y' `time_vars' `control_vars' `time_fe' , fe vce(cluster id)
		if _rc == 0 {
			estimates save es_`y'_`filter', append
			outreg2 using results_event_`y'_`filter'.doc, append ctitle(With Controls) keep(`time_vars' `controls_vars')
			coefplot, keep(time_*) drop(_cons) xline(0) xtitle(Months from Treatment) ytitle(Effect) title("`y' - Event Study (With Control)")
			graph export "`y'_event_study_plot_`filter'_c.png", replace
			}
}
	restore
}
