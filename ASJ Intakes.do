clear
use "C:\Users\Michael\Desktop\Thesis\Stata\ASJ Intakes"

//Some inmates committed crimes out of state and need to be dropped 
//These won't account for out of state inmates with multiple intakes so we might need to be a bit more careful
drop if strpos(desc, "FUGITIVE FROM JUSTICE") == 1
drop if strpos(desc, "FEDERAL DETAINER") == 1

//Recoding id + date and sorting
encode inmateid, generate(id)
gen idate = date(intakedate, "MDY")
sort id idate	

//Creating month of the year dummies
egen month = ends(intakedate) , p(/) h
destring month , replace
gen jan = 0
replace jan = 1 if month == 1
gen feb = 0 
replace feb = 1 if month == 2
gen mar = 0
replace mar = 1 if month == 3
gen apr = 0 
replace apr = 1 if month == 4
gen may = 0 
replace may = 1 if month == 5 
gen jun = 0 
replace jun = 1 if month == 6
gen aug = 0 
replace aug = 1 if month == 8 
gen sep = 0
replace sep = 1 if month == 9
gen oct = 0 
replace oct = 1 if month == 10
gen nov = 0 
replace nov = 1 if month == 11
gen dec = 0 
replace dec = 1 if month == 12
global month feb mar apr may jun jul aug sep oct nov dec
*Excluding Jan from the macro 

//Setting Jan 1, 2014 as day 0 and defining year dummies
replace idate = idate - 19724
gen year = 1
replace year = 2 if idate >= 365
replace year = 3 if idate >= 730
replace year = 4 if idate >= 1096
replace year = 5 if idate >= 1461
replace year = 6 if idate >= 1826

//Finding multiple intakes and defining the date of recidivism
//Multiple intakes will have the same recidivism date and we will censor observations after 3 years (1095 days)
gen sameday = 1 if idate == idate[_n+1] & id == id[_n+1]

gen recdate = 0 
replace recdate = idate[_n+1] if id == id[_n+1]
replace recdate = idate + 1095 if id != id[_n+1]
replace recdate = idate + 1095 if recdate > idate + 1095
forvalues a = 1(1)36{
  replace recdate = recdate[_n+1] if sameday == 1  
}
gen recdate1 = recdate
replace recdate1 = idate + 365 if recdate1 >= idate + 365
gen recdate2 = recdate
replace recdate2 = idate + 730 if recdate2 >= idate + 730



//Determining the number of intakes individuals have
gen recid = 0 
replace recid = 1 if id == id[_n+1] & sameday != 1 
forvalues a = 1(1)36{
  replace recid = recid[_n+1] if sameday == 1  
}
replace recid = 0 if recdate >= idate + 1095

gen recid1 = recid
replace recid1 = 0 if recdate1 == idate + 365
gen recid2 = recid 
replace recid2 = 0 if recdate2 == idate + 730

preserve
	drop if sameday == 1
	gen recnum = 1 
		forvalues i = 1(1)26	{
			replace recnum = `i' + 1 if id == id[_n-`i']
		}
	save "C:\Users\Michael\Desktop\Thesis\Stata\recnum" , replace
restore

merge m:1 id idate sameday using "C:\Users\Michael\Desktop\Thesis\Stata\recnum.dta"
forvalues a = 1(1)36{
  replace recnum = recnum[_n+1] if sameday == 1  
}
drop _merge

gen recfreq = recnum
replace recfreq = 10 if recfreq >= 10

gen cens = 0 
replace cens = 1 if recid == 0

//Identifying the arresting agency
gen agency = 1 
replace agency = 2 if strpos(arrestingagency , "AUB") != 0
replace agency = 3 if strpos(arrestingagency , "LEW") != 0
replace agency = 4 if strpos(arrestingagency , "LIF") != 0
replace agency = 5 if strpos(arrestingagency , "LISPD") != 0
replace agency = 6 if strpos(arrestingagency , "MDEA") != 0
replace agency = 7 if strpos(arrestingagency , "MEC") != 0
replace agency = 8 if strpos(arrestingagency , "MECPD") != 0
replace agency = 9 if strpos(arrestingagency , "MSP") != 0
replace agency = 10 if strpos(arrestingagency , "OTPD") != 0
replace agency = 11 if strpos(arrestingagency , "OXFSO") != 0
replace agency = 12 if strpos(arrestingagency , "PPO") != 0
replace agency = 13 if strpos(arrestingagency , "SAB") != 0