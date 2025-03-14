/* use "/Users/kl/alphafold_complete.dta", clear */
use "/Users/kl/b12.dta", clear

local filter0 "1"

local filter1 "is_ls_first"
local filter2 "is_ls_last"

local filter3 "early"
local filter4 "early==0"

local filter5 "tmonth_medsplit==0"
local filter6 "tmonth_medsplit==1"

local filter7 "tmonth_tertile==0"
local filter8 "tmonth_tertile==2"

local filter9 "pubs_before_treatment_medsplit==0"
local filter10 "pubs_before_treatment_medsplit==1"

local filter11 "pubs_before_treatment_tertile==0"
local filter12 "pubs_before_treatment_tertile==2"

local filter13 "months_before_treatment_medsplit==0"
local filter14 "months_before_treatment_medsplit==1"

local filter15 "months_before_treatment_tertile==0"
local filter16 "months_before_treatment_tertile==2"

local filter17 "productivity_before_treatment_me==0"
local filter18 "productivity_before_treatment_me==1"

local filter19 "productivity_before_treatment_te==0"
local filter20 "productivity_before_treatment_te==2"


local dvs "count _2023_JIF_sum average_2023_JIF topic_hhi_adjusted"
local interactions "tmonth_demean pubs_before_treatment_demean months_before_treatment_demean productivity_before_treatment_de is_ls_first is_ls_last early"
local ttest_vars "topics_hhi_12_adjusted subfields_hhi_12_adjusted fields_hhi_12_adjusted domains_hhi_12_adjusted"


forvalues filter = 0/20{
	use "/Users/kl/b12.dta", clear
	xtset id_numeric pmonth, monthly
	keep if `filter`filter''
	foreach y of local dvs{
		preserve
		collapse (mean) mean=`y' (sd) sd=`y' (count) n=`y', by(months_from_treatment)
		generate hi = mean + invttail(n-1,0.025)*(sd / sqrt(n))
		generate lo = mean - invttail(n-1,0.025)*(sd / sqrt(n))

		twoway (connected mean months_from_treatment, lcolor(blue) mcolor(blue) 	msymbol(circle)) (rcap hi lo months_from_treatment, lcolor(blue%50)) , title("Trend of Monthly Publications (Life Sciences)") xtitle("Months from Treatment") ytitle("Count") ylabel(, angle(horizontal)) xline(0, lcolor(red) lpattern(dash)) legend(off)
		graph save LS_TREND_`y'_`filter', replace
		restore

		xtreg `y' post i.pmonth , fe vce(cluster id_numeric)
		outreg2 using LS_12_DID_`y'_`filter'.doc, keep(post)
		if `filter' == 0 {
			foreach i of local interactions{
			xtreg `y' post 1.post#c.`i' i.pmonth, fe vce(cluster id_numeric)
			outreg2 using LS_12_DID_`y'_`filter'_`i'.doc, keep(post 1.post#c.`i')
			}
		}
		
		local time_vars time12_*
		xtreg `y' `time_vars' i.pmonth , fe vce(cluster id)
	coefplot, keep(time12_*) drop(_cons) yline(0, lpattern(solid)) xline(12.5, lcolor(red)) ytitle(Months from Treatment) xtitle(Effect) title("`y' - Event Study (No Controls)") vertical coeflabels(time12_0 = "-12" time12_1 = "-11" time12_2 = "-10" time12_3 = "-9" time12_4 = "-8" time12_5 = "-7" time12_6 = "-6" time12_7 = "-5" time12_8 = "-4" time12_9 = "-3" time12_10 = "-2" time12_11 = "-1" time12_12 = "0" time12_13 = "+1" time12_14 = "+2" time12_15 = "+3" time12_16 = "+4" time12_17 = "+5" time12_18 = "+6" time12_19 = "+7" time12_20 = "+8" time12_21 = "+9" time12_22 = "+10" time12_23 = "+11" time12_24 = "+12", notick labsize(small))
		graph save LS_ES_`y'_`filter'_12_nocontrols
		outreg2 using LS_ES_`y'_`filter'_12.doc, keep(`time_vars')

		
// 		local time_vars time24_*
// 		xtreg `y' `time_vars' i.pmonth , fe vce(cluster id)
// coefplot, keep(time24_*) drop(_cons) yline(0, lpattern(solid)) xline(23.5, lcolor(red)) ytitle(Months from Treatment) xtitle(Effect) title("`y' - Event Study (No Controls)") vertical coeflabels(time24_0 = "-24" time24_1 = "-23" time24_2 = "-22" time24_3 = "-21" time24_4 = "-20" time24_5 = "-19" time24_6 = "-18" time24_7 = "-17" time24_8 = "-16" time24_9 = "-15" time24_10 = "-14" time24_11 = "-13" time24_12 = "-12" time24_13 = "-11" time24_14 = "-10" time24_15 = "-9" time24_16 = "-8" time24_17 = "-7" time24_18 = "-6" time24_19 = "-5" time24_20 = "-4" time24_21 = "-3" time24_22 = "-2" time24_23 = "-1" time24_24 = "0" time24_25 = "+1" time24_26 = "+2" time24_27 = "+3" time24_28 = "+4" time24_29 = "+5" time24_30 = "+6" time24_31 = "+7" time24_32 = "+8" time24_33 = "+9" time24_34 = "+10" time24_35 = "+11" time24_36 = "+12" time24_37 = "+13" time24_38 = "+14" time24_39 = "+15" time24_40 = "+16" time24_41 = "+17" time24_42 = "+18" time24_43 = "+19" time24_44 = "+20" time24_45 = "+21" time24_46 = "+22" time24_47 = "+23" time24_48 = "+24", notick labsize(tiny))
// 		graph save LS_ES_`y'_`filter'_24_nocontrols
// 		outreg2 using LS_ES_`y'_`filter'_24.doc, append ctitle(No Controls) keep(`time_vars' `control_vars')
		
	}


	* T-test
		eststo clear
		estpost ttest `ttest_vars' if months_from_treatment == -1 | months_from_treatment == 12, by(months_from_treatment)
		esttab using "ttest_results_`filter'.rtf", cells("b(fmt(3)) se(fmt(3)) t(fmt(2)) p(fmt(3))")
}

