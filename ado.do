*****************************************************************************
* PURPOSE:
* Use of .ado files
*
* AUTHOR: 
* Patrick Gauding
*
* DATE MODIFIED:
* 20180127
*
* Notes:
* CRMDA Summer Workshop 2017 Week 2 Day 3
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

* Find and install
findit foo
net install foo
ssc hot // fresh ado packages

* Set .ado storage directory
sysdir set PLUS "" // if using, must be run at beginning of each do
sysdir set PLUS "D:/Dropbox/ado/plus" // can be run out of Dropbox

ssc install estout 

// If you create a do-file called profile.do and place it in the same directory
// where the Stata executable file lives, any code contained in that file will 
// be executed automatically each time you open Stata.

// I use this file:
//			Tell Stata to look in my Dropbox folder for user-written ado-packages.
//			Automatically create and open a log file named with the current system
//			date and time that is stored in a central location.

* Returned Results

* Example
quietly sum BYTXMSTD
return list

/*
r(sum) = 805885.83
r(max) = 86.68000000000001
r(min) = 19.38
r(sd) = 9.912397548797786
r(Var) = 98.25562516541237
r(mean) = 50.71015794110244
r(sum_w) = 15892
r(N) = 15892
*/

di r(mean)
// 50.71015794110244

ereturn // E-class returns; estimations
return // R-class returns; essentially everything else

qui reg F3ERN2011 i.BYRACE if BYSEX==2
ereturn list

gen sample_dum = e(sample) // Mark the observations used in the regression
display e(rss)/(e(N)-1) // Calculate the error variance.

qui reg F3ERN2011 i.BYRACE i.BYSEX
local b_cons _b[_cons] // save the coefficient of the constant term in a macro
di _b[2.BYSEX]/_se[2.BYSEX] // manually calculate a t-statistic for BYSEX
di _b[_cons] + _b[3.BYRACE]*1 + _b[2.BYSEX]*1 // calculate a fitted value for the 
. 18754.215																		// earnings of a black woman

** Stata Programming
// 1. You should never* manually copy/paste results from the output window to
// somewhere else or fingerpaint output tables.
// 2. You should never* write duplicate lines of code to perform the same procedure
// to multiple variables, multiple datasets, etc.

** Local and Global Macros
// Cox, Nicholas J. 2002. "Speaking Stata: How to face lists with fortitude." The
// Stata Journal 2(2): 202-222.

* Macros: akin to R objects. Can be local or global. Use local only.

local fam_ed_ctrls "i.BYMOTHED i.BYFATHED i.BYGPARED"
reg F3ERN2011 i.BYSEX i.BYRACE `controls' // macros use single quotes (` ')

* Numeric macro - doesn't require quotes
local z 4
display (`z' + 7)/2
replace BYSES1 = `z' in 6
local z = `z' + 5 // change macro; note '=' in second example

* Caveats
* 1. Case sensitive
* 2. Mistyping
* 3. Reference after ceasing to exist (after running do-file or closing interactive session)
* NOTE: local = within do-file; global = within interactive session

* Loops
foreach
forvalues

* Look like this:
define the loop structure {
list the commands
list the commands
}

foreach k of numlist 2/4 {
    gen y_`k' = y^`k'
	}

* Legal numlist syntax
2 3 4
2/4 // same as typing 2 3 4
4/2 // same as typing 4 3 2
2(2)8 // same as 2 4 6 8
2 3 5/7 10(5)20 // same as 2 3 5 6 7 10 15 20

foreach j of varlist BYTXCSTD BYTXMSTD BYTXRSTD {
    egen z_`j' = std(`j')
	  lab var z_`j' "Z-scored `j"
	}

* Legal varlist syntax
BYSEX BYRACE
F3D* // same as typing F3D34 F3D35
BYSEX-BYGPARED // same as BYSEX BYRACE BYMOTHED BYFATHED BYGPARED
BY*ED // same BYMOTHED BYFATHED BYGPARED

levelsof // displays (and optionally saves as a macro) a sorted list of the distinct values
				 // taken by a variable, which you can then use to construct loops

levelsof BYRACE, local(race)
. 1 2 3 4 5 6 7
di "`race'"
. 1 2 3 4 5 6 7

foreach j of local race {
    local rlab: label BYRACE `j'
	  di "RACE = `rlab'"
	  reg F3ERN2011 i.BYSEX c.BYTXMSTD c.BYTXRSTD if BYRACE==`j'
	}

// This gets a bit fancy! It picks up the appropriate value label and displays it so you know which
// regression represents which category of race.

use "http://www.census.gov/2010census/xls/fips_codes_website.xls"
export delimited

levelsof fips, local (fips)

See fun problem on stata-3-programming.pdf slide 28

** Factor Notation and Regressions
* i.foo notation indicates to Stata to treat variable as indicator or factor
* c.foo notation indicates to State to treat variable as continuous (default)

reg F3ERN2011 BYSEX BYRACE
reg F3ERN2011 i.BYSEX i.BYRACE

// In first example, BYSEX and BYRACE are treated as continous (boo.) In second line,
// they are treated as factors.

* Clever things

// ib# allows you to set the omitted (base) category
reg F3ERN2011 BYSEX ib7.BYRACE

// ib(freq) selects the modal category as base (default is smallest category)

// i# creates a binary dummy from your categorical variable
reg F3ERN2011 BYSEX i7.BYRACE

// Thereby comparing whites to non-whites (the omitted base category)

reg F3ERN2011 i.BYSEX i.BYRACE c.BYTXRSTD##c.BYTXRSTD

// Earnings predicted by gender, race, standardized reading score, standardized reading score squared

reg F3ERN2011 i.BYSEX##c.BYTXMSTD i.BYRACE

// Earnings predicited by gender, race, standardized math score, interaction

* The old way - high scoring math white women vs. men
gen genderXmath = BYSEX*BYTXMSTD // create interaction term
reg F3ERN2011 BYSEX BYTXMSTED genderXmath i.BYRACE // include in regression
margins, at(BYSEX=2 BYTXMSTD=63.14 BYRACE=7) // fitted value of $20,341.62 for women
margins, at(BYSEX=1 BYTXMSTD=63.14 BYRACE=7) // fitted value of $37,811.81 for men
// These results say that men earn $17,470.18 more.

* The factor notation way
reg F3ERN2011 i.BYSEX##c.BYTXMSTD i.BYRACE // run regression
margins, at(BYSEX=2 BYTXMSTD=63.14 BYRACE=7) // fitted value of $30,880.54 for women
margins, at(BYSEX=1 BYTXMSTD=63.14 BYRACE=7) // fitted value of $34,498.93 for men
// These results say that men earn $3,618.39 more.

* THE DIFFERNCE - Calculus
// The partial effect of gender on earnings in our equation isn't just the coefficient on gender. It is the coefficient on gender times the product of the coefficient on the interaction term and the value we specify for math test score.
// Doing it the old way, Stata didn't know that the interaction term is the product of the two first-order terms. It just treated it like any other variable and held constant when calculating the predicted values
// Doing it the new way, Stata knew not to hold the interaction term constant, yielding the correct fitted values.

* Outputting tables using estout
qui reg F3ERN2011 i.BYSEX BYTXRSTD
estimates store model_1
qui reg F3ERN2011 i.BYSEX c.BYTXRSTD##c.BYTXRSTD
estimates store model_2

esttab model_1
esttab model_1, stat(N F r2) star(* .1 ** .05 *** .01) b(2) se(2)
esttab model_1 model_2, stat(N F r2) star(* .1 ** .05 *** .01) b(2) se(2)  ///
				label nomtitles title("Table 2: Regression Results") drop(1.BYSEX)
esttab model_1 model_2 using "output/reg_results", stat(N F r2) star(* .1 ** .05 *** .01) b(2) se(2) ///
				label nomtitles title("Table 2: Regression Results") drop (1.BYSEX) coeflabel(c.BYTXRSTD#BYTXRSTD ///
				"Reading Score, squared") rtf

qui reg F3ERN2011 i.BYSEX BYTXRSTD
estpost summarize F3ERN2011 BYSEX BYTXRSTD if e(smaple)
esttab using "output/sum_stats", cells("mean(fmt2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))")  ///
				nomtitle nonumber title("Table 1: SUmmary Statistics") rtf replace
				
* ALSO:
putexcel

// But only weak people make tables in Excel.