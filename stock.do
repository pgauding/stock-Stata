*****************************************************************************
* PURPOSE:
* Stock set up and useful functions in Stata
*
* AUTHOR: 
* Patrick Gauding
*
* DATE MODIFIED:
* 20180127
*
* Notes:
* CRMDA Summer Workshop 2017 Week 2 Day 2
*****************************************************************************

*** INITIAL SETUP ***
clear all // clears memory
capture log close // closes open logs
set linesize 80 // output fits paper
set more off // disables auto-pauses
set rmsg on // logs execution time
version 15.1 // version control

* Set Working Directory
cd ""
save "" // save data in data subdir

* Start log
log using "log/foo.txt", replace text // save log in log subdir

* Save out analysis datasets
datasignature set
datasignature
datasignature confirm // if checksums don't match

** Example commands
copy "http://www.somewhere.com/sheet1.xls" "c:/project1/datasets/sheet1.xls", replace
copy "https://en.wikipedia.org/wiki/Beyonce" "c:/singers/bey.htm"

unzipfile "d:/archive.zip", replace

** Import commands
use // website or local .dta
import delimited // .csv
import delimited "foo", delimiter("char") // for other delims
export delimited // saves out as .csv or other

append // stack datasets; lengthen sheet of paper
merge // combine on common unique idetifies; 1:1, M:1, M:M merges (don't do M:M);
			// widening a sheet of paper

describe (d)
codebook

summarize (sum)
summarize, detail (sum, d)

tab
tab foo, nolab

histogram
histogram foo, normal

scatter
lfit
graph twoway (scatter foo1 foo2) (lfit foo1 foo2)

rename
rename BYSEX gender

label
label gender "Gender of respondent"

* Labeling variable values
label define gender_labels 1 "male" 2 "female"
label values gender gender_labels

* Logical Operators
& // and
| // or
!= // not equal
>= // greater than or equal to
<= // less than or equal to
== // equals

* Logical examples
tab BYFATHED if BYSEX==1
tab BYFATHED if BYSEX!=2
count if BYSES1==.

sum F3ERN2011
sum F3ERN2011 if BYMOTHED>=6

* Creating and transforming data
preserve // must be used together; only one preserve held
restore
restore, not // cancels previous preserve w/o actually restoring

drop
keep

destring
destring foo, replace ignore(",") // replace the string variable, 
																	// ignoring commas in otherwise numeric variables
destring foo, replace force // code any cell containing non-numeric
														// characters as missing
destring foo, gen(newvar) // create a new numeric variable using the old string variable
tostring

encode // creates a numeric variable from a string variable, and automatically
			 // creates variable labels based on the string	
decode // creates a string variable from a numeric variable, using the value labels
			 // as the variable values

generate
sum F3ERN2011, detail
gen log_earn = ln(F3ERN2011)
gen earn_sq = F3ERN2011*F3ERN2011
gen blank_string = ""
gen blank_num = .
gen z_earn = (F3ERN2011-26009)/23993
summarize z_earn

generate newvar = date(varname, "date format") // convert a string variable
// into Stata's standardized format for date (0= Jan 1, 1960)
// "date format" reflects the formatting of the string ("DMY", "MDY")
format newvar = %td // make the actual date display in the editor window
// rather than the number representing the day

replace
replace F3ERN2011 =.
replace F3ERN2011 =. if F3ERN2011 >= 200000
replace F3ERN2011 = . in 20

* Dummies using if
tab BYRACE
gen hispanic_dum = .
replace hispanic_dum=0 if BYRACE ==1 | BYRACE==2 | BYRACE==3 | BYRACE==6 | BYRACE==7
replace hispanic_dum=1 if BYRACE==4 | BYRACE==5
label var hispanic_dum "Respondent is Hispanic"
tab hispanic_dum BYRACE

* Dummies using cond
sum F3ERN2011, detail
gen rich_dum = cond(F3ERN2011 >= 52500,1,0)
tab rich_dum if F3ERN2011==. // What about these missings?
gen rich_dum = (cond(F3ERN2011>=52500,1,0)) if F3ERN2011 < . // Do this instead.

** egen: extensions to generate (pre-canned generate functions for common data transformation)

* Standaridize wages
egen z_earn2 = std(F3ERn2011)
summarize z_earn2

* Generate group-level means using egen:
by BYSEX BYRACE, sort: egen mean_earn = mean(F3ERN2011)
summarize F3ERN2011 if BYSEX==1 & BYRACE==7

ssc install egenmore
rowmedian
noccur
xtile