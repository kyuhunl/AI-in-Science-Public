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
	keep if `filter`filter''
	capture{
		csdid count, ivar(id_numeric) time(publication_month_int) gvar(treatment_month_int)
		estimates save csdid_`filter'
	}
	capture{
		jwdid count, ivar(id_numeric) time(publication_month_int) gvar(treatment_month_int)
		estimates save jwdid_`filter'
	}
	

}
