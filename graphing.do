*****************************************************************************
* PURPOSE:
* Graphing in Stata
*
* AUTHOR: 
* Patrick Gauding
*
* DATE MODIFIED:
* 20180127
*
* Notes:
* CRMDA Summer Workshop 2017 Week 2 Day 4
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

twoway // X-Y plots; 31 varieties

graph twoway scatter BYTXMSTD BYTXRSTD // scatter only
graph twoway (scatter BYTXMSTD BYTXRSTD) (lfitci BYTXMSTD BYTXRSTD) // add OLS + 95% CI
graph twoway (scatter BYTXMSTD BYTXRSTD) (lfitci BYTXMSTD BYTXRSTD), ///
				ytitle("Standardized Math Score") xtitle("Standardized Reading Score") ///
				legend(off) // add ylab xlab no legend

graph twoway (scatter BYTXMSTD BYTXRSTD) (lfitci BYTXMSTD BYTXRSTD), ///
				ytitle("Standardized Math Score") xtitle("Standardized Reading Score") ///
				legend(off) title("Relationship between Math and Reading Scores") // add title

graph twoway (scatter BYTXMSTD BYTXRSTD) (lfitci BYTXMSTD BYTXRSTD), ///
				ytitle("Standardized Math Score") xtitle("Standardized Reading Score") ///
				legend(off) title("Relationship between Math and Reading Scores")

// There's a finger-painter. It's frustrating
graph play foo

* Create two graphs, smash them together
graph twoway (lfitci BYTXMSTD BYTXRSTD if BYSEX==2 in 1/100),  ///
				ytitle("Standardized Math Score") xtitle("Standardized Reading Score")  ///
				legend(off) title("Women")
graph save "output/plot_women", replace

graph twoway (lfitci BYTXMSTD BYTXRSTD if BYSEX==1 in 1/100),  ///
				ytitle("Standardized Math Score") xtitle("Standardized Reading Score")  ///
				legend(off) title("Men")
graph save "output/plot_men", replace

graph combine "output/plot_men.gph" "output/plot_women.gph", xcommon ycommon  ///
				title("Relationship between math and reading scores by gender")
graph export "output/combined_plot.png", replace

* Use margins to calculate adjusted means (fitted or predicted values)
margins

// With no options, Stata calculates the predicted value of the dependent variable for 
// each observation, and gives us the mean of those predictions.

// If margins is called with a categorical variable, Stata calculates what the mean ///
// predicted value of the dependent variable would be if all observations had a particular ///
// value of the categorical value, all else constant:
margins(BYRACE)

// This answer the hypothetical question: "What would the mean test score be if all the
// individuals in the sample were black/white/etc.?"

// For continous variables, you need to specify the values that you want to examine using at:
margins, at(BYTXMSTD= (42 51 60))

// This tells us the mean predicted earnigns with standardized math score set at 42, 51, and 60 
// (roughly -1 SD, mean, +1 SD) holding all other variables constant at their means.

// You can also use at to calculate fitted values for specific combinations:
margins, at(BYRACE=51 BYRACE==7 & BYSEX==1)

// This provides a fitted value for white males with average math test scores.

margins, at BYTXMSTD=(20(10)90) // margins with 95% CI at points 20-90 every 10
marginsplot
margins BYSEX, at(BYTXMSTD=(20(10)90)) // same deal by gender
marginsplot
margins r.BYSEX, at(BYTXMSTD=(20(10)90)) // contrasts of predictive margins of BYSEX with 95% CIs
marginsplot, yline(0)

* More complicated models

regress F3ERN2011 i.BYSEX##c.BYTXMSTD##i.BYRACE // impact of math achievement to vary by gender and race
regress F3ERN2011 i.BYSEX c.BYTXMSTD##c.BYTXMSTD // nonlinear impact of math achievement
regress F3ERN2011 i.BYSEX##c.BYTXMSTD##c.BYTXMSTD // nonlinear impact of math achievement vary by gender

margins BYSEX, at(BYTXMSTD=(20(10)90))
marginsplot

margins BYSEX, at(BYTXMSTD=(20(10)90))
marginsplot

margins BYSEX, at(BYTXMSTD=(20(10)90))
marginsplot

* Margins and nonlinear models

// Margins is even more useful in nonlinear estimation such as binary outcome models.
// We can run a model predicting who is wealthy:

logit highest_income i.BYSEX##c.BYTXMSTD i.BYRACE, or // or is odds ratio

// The coefficient on i.BYSEX is marginally statistically significant. The odds ratio tells us
// that the odds of being wealthy if you are a female are 0.57 times the odds of being wealthy
// if you are a male.

// You can ask the margins comand to examine the interaction between gender and standardized math score.
// You need to specify some "representative" values of math score:

margins i.BYSEX, at (c.BYTXMSTD = (33.72 50.83 66.49)), post

// This gives us predicted probablities of being wealthy for men and women at differnt levels of 
// mathematical aptitude. The post allows us to do tests of statistical significance of the differences:
test 1._at#1.BYSEX = 1._at#2.BYSEX
test 2._at#1.BYSEX = 2._at#2.BYSEX
test 3._at#1.BYSEX = 3._at#3.BYSEX
marginsplot


