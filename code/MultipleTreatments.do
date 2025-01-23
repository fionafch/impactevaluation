/*******************************************************************************
* Multiple Treatments simulation
*******************************************************************************/

*===============================================================================
**# General Settings 
*===============================================================================



/* Notation

Y = Outcome
D = Treatment Indicator
b = Treatment effect 
N = Number of observations

_a = Treatment A
_b = Treatment B

sigma = standard deviation of error term

*/

global probability_of_treatment_a 0.15
global probability_of_treatment_b 0.30

*===============================================================================
**# Case 1:  Mutually exclusive treatments with homogeneous effects
*===============================================================================
qui{
clear all 

* Setup 
set obs 1000
gen id = _n

* Treatment 

** Status
gen D_a = (runiform()<=$probability_of_treatment_a)
gen D_b = (runiform()<=$probability_of_treatment_b)
replace D_b = 0 if (D_a==1 & D_b==1)
noisily tab D_a D_b 

** Effect size 
scalar a = 1 
scalar b_a = 0.2
scalar b_b = 0.2

* Outcome model
scalar sigma = 0.05 
gen Y1 = 1 + b_a*D_a + b_b*D_b + rnormal(0,sigma)

* Estimate true specification (one treatment variable per treatment type)
regress Y1 D_a 
est store case1_true_a

regress Y1 D_b 
est store case1_true_b

* Assume we only see treatment status regardless of type
gen D = (D_a==1 | D_b==1)

* Estimate observable equation
reg Y1 D 
est store case1_D
 
* Estimate multiple regression with two treatments
** This works by virtue of no slope effects
reg Y1 D_a D_b
est store case1_mlr
}
esttab case1*, se title("Case 1: Mutually exclusive treatments with homogeneous effects")


*===============================================================================
**# Case 2:  Mutually exclusive treatments with heterogeneous effects
*===============================================================================
qui{
clear all 

* Setup 
set obs 1000
gen id = _n

* Treatment 

** Status
gen D_a = (runiform()<=$probability_of_treatment_a)
gen D_b = (runiform()<=$probability_of_treatment_b)
replace D_b = 0 if (D_a==1 & D_b==1)
noisily tab D_a D_b 

** Effect size 
scalar a = 1 
scalar b_a = 0.1
scalar b_b = 0.3

* Outcome model
scalar sigma = 0.05 
gen Y1 = 1 + b_a*D_a + b_b*D_b + rnormal(0,sigma)

* Estimate true specification (one treatment variable per treatment type)
regress Y1 D_a 
est store case2_true_a

regress Y1 D_b 
est store case2_true_b

* Assume we only see treatment status regardless of type
gen D = (D_a==1 | D_b==1)

* Estimate observable equation
reg Y1 D 
est store case2_D
 
* Estimate multiple regression with two treatments
** This works by virtue of no slope effects
reg Y1 D_a D_b
est store case2_mlr
}
esttab case2*, se title("Case 1: Mutually exclusive treatments with heterogeneous effects")


*===============================================================================
**# Case 3:  Non mutually exclusive treatments with homogeneous effects
*===============================================================================
qui{
clear all 

* Setup 
set obs 1000
gen id = _n

* Treatment 

** Status
gen D_a = (runiform()<=$probability_of_treatment_a)
gen D_b = (runiform()<=$probability_of_treatment_b)
noisily tab D_a D_b 

** Effect size 
scalar a = 1 
scalar b_a = 0.2
scalar b_b = 0.2

* Outcome model
scalar sigma = 0.05 
gen Y1 = 1 + b_a*D_a + b_b*D_b + rnormal(0,sigma)

* Estimate true specification (one treatment variable per treatment type)
regress Y1 D_a 
est store case3_true_a

regress Y1 D_b 
est store case3_true_b

* Assume we only see treatment status regardless of type
gen D = (D_a==1 | D_b==1)
gen T = D_a + D_b 
noisily tab D T 

* Estimate observable equation
reg Y1 D 
est store case3_D
 
* Estimate multiple regression with two treatments
** This works by virtue of no slope effects
reg Y1 D_a D_b
est store case3_mlr
}

* Estimate multiple regression with two treatments and interaction 
** This works by virtue of no slope effects
reg Y1 ib0.T
est store case3_levels

esttab case3*, se title("Case 3: Non mutually exclusive treatments with homogeneous effects")


*===============================================================================
**# Case 4:  Mutually exclusive treatments with heterogeneous effects
*===============================================================================
qui{
clear all 

* Setup 
set obs 10000
gen id = _n

* Treatment 

** Status
gen D_a = (runiform()<=$probability_of_treatment_a)
gen D_b = (runiform()<=$probability_of_treatment_b)
noisily tab D_a D_b 

** Effect size 
scalar a = 1 
scalar b_a = 0.2
scalar b_b = 0.7

* Outcome model
scalar sigma = 0.05 
gen Y1 = 1 + b_a*D_a + b_b*D_b + rnormal(0,sigma)

* Estimate true specification (one treatment variable per treatment type)
regress Y1 D_a 
est store case4_true_a

regress Y1 D_b 
est store case4_true_b

* Assume we only see treatment status regardless of type
gen D = (D_a==1 | D_b==1)
gen T = D_a + D_b 
noisily tab D T 

* Estimate observable equation
reg Y1 D 
est store case4_D
 
* Estimate multiple regression with two treatments
** This works by virtue of no slope effects
reg Y1 D_a D_b
est store case4_mlr

* Estimate multiple regression with two treatments and interaction 
** This works by virtue of no slope effects
reg Y1 ib0.T
est store case4_levels

* Estimate multiple regression with treated and same control group 
reg Y1 D_a if (D_a==1 | T==0)
est store case4_groups_a
* Estimate multiple regression with treated and same control group 
reg Y1 D_b if (D_b==1 | T==0)
est store case4_groups_b

}
esttab case4*, se title("Case 1: Non mutually exclusive treatments with heterogeneous effects")

di $probability_of_treatment_a * b_a + $probability_of_treatment_b * b_b
