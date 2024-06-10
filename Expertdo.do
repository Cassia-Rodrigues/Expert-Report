
**EXPERT REPORT**

clear
set more off
capture log close

import excel "/Users/User/Desktop/Applied Economics/ECON 674/pset1/data1.xlsx", firstrow case(lower) clear

br

sort installation_date
log using Problem2-1.log, replace


drop if installation_price < 0

count
sort door_id

duplicates tag door_id, gen (doorduplicates)
tab doorduplicates


duplicates report installation_costs
duplicates drop if installation_costs
count

drop doorduplicates
duplicates tag door_id, gen (doorduplicates)
tab doorduplicates

drop doorduplicates


***************************************************************************
sort installation_date


codebook installation_price
codebook installation_cost
*hist installation_price,freq title(Installation Prices)
*hist installation_cost,freq title(Installation Cost)


gen profit= installation_price-installation_costs
gen pcmargin= profit/installation_price

*Creating variables for month and year
gen installation_year= year(installation_date)

gen installation_month= month(installation_date)

sort installation_year
*collapse (mean) installation_price installation_cost profit pcmargin, by(installation_year installation_month door_type)


/* Using 3 periods 
tab door_type, gen(door_type_dummy)


gen treatment = (installation_year >= 1983 & installation_year <= 1995)
gen post_1= (installation_year >= 1983 & installation_year <= 1995)
gen post_2= (installation_year >= 1995 & installation_year <= 2015)
gen post_3= (installation_year >= 1980 & installation_year <= 1983)
gen treat_post1= treatment*post_1
gen treat_post2= treatment*post_2
gen treat_post3= treatment*post_3

reg installation_price treatment post_1 post_2 post_3 treat_post1 treat_post2 treat_post3 installation_costs door_type_dummy*

*/

reg installation_price treatment treat installation_cost
reg installation_price treatment treat installation_cost door_type_dummy1
reg installation_price treatment treat installation_cost door_type_dummy2
reg installation_price treatment treat installation_cost door_type_dummy3
reg installation_price treatment treat installation_cost door_type_dummy4
reg installation_price treatment treat installation_cost door_type_dummy5
di "The Estimate of the Damages are: " 232.2941*9014

reg logprice treatment treat logcost

table installation_price installation_costs profit pcmargin if installation_year >= 1983 & installation_year <= 1995

bysort installation_year: egen price=mean(installation_price)

table installation_price installation_costs profit pcmargin if treatment==1

**Creating dummy variables

gen logprice= ln(installation_price)
gen logcost= ln(installation_costs)
gen logpcmargin= ln(pcmargin)
gen logprofit=ln(profit)



hist logcost



gen treatment =(installation_year >= 1983 & installation_year <= 1995)

*replace treatment= 0 if installation_year==1983 & installation_month<11
*replace treatment= 0 if installation_year==1995 & installation_month >4

gen treatment_time=installation_year> 1983
*replace treatment_time=0 if installation_year==1983 & installation_month<11
des
sum

*gen treatment= door_type==1 | door_type==2 |door_type==3 
*replace treatment= 0 if installation_year < 1983 | installation_year > 1995

gen treat=1 if inlist(door_type,1,2,3) & inrange(installation_year,(1983),(1995))
replace treat=0 if inlist(door_type,1,2,3) & inrange(installation_year,(1995), (2015))

gen treatment= treat==1
gen post= treat==0

gen treattreat= treatment*treat
tab door_type, gen(door_type_dummy)
* Regression without omitted variables
**# Bookmark #3
reg installation_price treatment treatment_time treat installation_cost 
reg logprice treatment treat logcost
predict predicted_val, xb

*Interaction term
gen did_interact= treatment*treatment_time

*Youtube vid checks
tab treatment treatment_time, sum(installation_price) nofreq nost
di (3813.3656-3567.4623 )-(2452.7699-3510.7939)

reg installation_price i.treatment##i.treatment_time
xx
diff installation_price, treated(treat) period(treatment_time)

diff installation_price, treated(treatment) period(treatment_time) cov(installation_costs)

*Parallel trend analysis
bysort installation_year: egen price=mean(installation_price)
graph tw (sc logprice installation_year)(lfit predicted_val installation_year if installation_year >= 1983 & installation_year <= 1995)(lfit logprice installation_year if installation_year>= 1983)

reg logprice treatment treatment_time treat logcost

/*Finding the monthly averages
*collapse (mean) installation_price installation_cost profit pcmargin, by(installation_year installation_month treatment treatment_time did_interact door_type_dummy*)

reg installation_price installation_costs did_interact treatment treatment_time door_type_dummy4 door_type_dummy5
predict predicted_val, xb

tabstat installation_price installation_costs profit pcmargin, by(installation_year)

collapse (mean) installation_price installation_cost profit pcmargin predicted_val, by(installation_year treatment)
*/
tw (line logpcmargin installation_year if treatment==1,msize(0) connect(1) lcolor(blue) xlabel(1980 1985 1990 1995 2000 2005 2010 2015) xtitle(Installation Year) ytitle(Installation Price))(line logpcmargin installation_year if treatment==0,msize(0) connect(1) lcolor(red) xlabel(1980 1985 1990 1995 2000 2005 2010 2015)xtitle(Installation Year) ytitle(Installation Price))

di "The Estimate of the Damages are: " 0.0345367*9014
di "The Estimate of the Damages are: " 232.59713*9014

*To find the damages difference
tw (line installation_price installation_year,msize(0) connect(1) lcolor(blue) ylabel(1000 3000 5000 7000 9000) xlabel(1980 1985 1990 1995 2000 2005 2010 2015) xtitle(Installation Year) ytitle(Installation Price))(line predicted_val installation_year,msize(0) connect(1) lcolor(red) ylabel(1000 3000 5000 7000 9000)xlabel(1980 1985 1990 1995 2000 2005 2010 2015) xtitle(Installation Year) ytitle(Installation Price) xline(1983 1995))

collapse (mean) installation_price installation_cost profit pcmargin, by(installation_year)
tab installation_price installation_cost profit pcmargin



didregress (logprice)(treatment)(treat), group(logcost) time(t)

    Verify parallel trends assumption graphically
        . estat trendplots

    Test for parallel trends
        . estat ptrends



