***File to Create MCTRivals.dta
*Packagesrequired : tsspell

***Working Directory
cd "C:\Users\gwill_000\Dropbox\Research\MCT and Rivalry\MCT Data"
use ./DirectedDyadEugeneMaster2017_01_23.dta, clear
tsfill
destring dyad ccode1 ccode2, replace

***Merge KGD Rivals to Dyad Year Data
merge m:m dirdy year using KGDdirdy.dta
drop _merge
replace krival=0 if krival==.

***Merge Thompson Rivals to Dyad Year Data
merge m:1 dirdy year using "ThompsonDirectedDyadYear.dta"
drop if _merge==2
drop _merge
replace positional = 0 if positional ==.
replace spatial = 0 if spatial == .
replace ideol = 0 if ideol==.
replace interv = 0 if interv==.
save temp2.dta, replace

*** Format MCT Data
import delimited "./mct_dataset_v09.csv", clear

* Create directed dyad indicator from dirdy data
rename (ccode_a ccode_b) (ccode1 ccode2)
tostring ccode1 ccode2, format("%03.0f") replace
gen dirdy = ccode1+ccode2
destring ccode1 ccode2 dirdy, replace

* Save as is to create peace years variables later
save tempmct.dta,replace

* Condense to one obs per year
gen mctiss = 1
collapse (mean) mctiss (max) territory leadership policy reparations other demonstration force target_fatalities compliance, by(dirdy year)
save tempmctdirdy.dta, replace
	
***Merge Major Power Status
import excel ".\Major Power System Membership.xlsx", sheet("majors2011.csv") firstrow clear
expand 2, gen(mark)
gen year = styear if mark==0
replace year = endyear if mark==1
xtset ccode year
tsfill
gen mp = 1
replace mp=0 if ccode==220 & year>=1941 & year<=1944
replace mp=0 if ccode==255 & year>=1919 & year<=1924
replace mp=0 if ccode==255 & year>=1945 & year<=1990
replace mp=0 if ccode==365 & year>=1918 & year<=1921
replace mp=0 if ccode==740 & year>=1946 & year<=1990
keep ccode year mp
rename ccode ccode1
rename mp mp1
save tempmp1.dta, replace
rename ccode1 ccode2
rename mp1 mp2
save tempmp2.dta, replace
use temp3.dta, clear
merge m:m ccode1 year using tempmp1.dta
drop if _merge==2
drop _merge
merge m:m ccode2 year using tempmp2.dta
drop if _merge==2
drop _merge
replace mp1 = 0 if mp1==.
gen mpdy = 1 if mp1==1 | mp2==1
replace mpdy = 0 if mpdy==.
save temp4.dta, replace

***Merge Archigos Data
import delimited ".\1March_Archigos_4.1.txt", clear 
gen year = substr(startdate, 1,4)
destring year, replace
gen leadch = 1
collapse (mean) leadch, by(ccode year)
rename ccode ccode1
rename leadch leadch1
save archdum1, replace
rename ccode1 ccode2
rename leadch1 leadch2
save archdum2, replace

use temp4.dta
merge m:m ccode1 year using archdum1
drop if _merge==2
drop _merge
merge m:m ccode2 year using archdum2
drop if _merge==2
drop _merge

replace leadch1 = 0 if leadch1==.
replace leadch2 = 0 if leadch2==.
sort dirdy year
gen laglead1 = l.leadch1
gen laglead2 = l.leadch2
save temp5.dta, replace

***Generate Capability Measure
use temp5.dta, clear
xtset dirdy year
gen caprat = cap_1/(cap_1+cap_2)
gen dcaprat = d.caprat
gen lcaprat = l.caprat
gen percap = dcaprat/lcaprat*100
gen lpercap	= l.percap
la var lpercap "Lagged Percent Change in Ratio of Cap1 to Whole Dyad"

***Create alliance dummy
gen ally = 1 if alliance <4
replace ally =0 if ally==.
gen lally = l.ally
save temp5_1.dta, replace

***Peace years
use tempmct.dta, clear
gen mctdyad = 1
collapse (mean) mctdyad, by(dyad year)
save tempmct2.dta, replace
use temp5_1.dta, clear
merge m:1 dyad year using tempmct2.dta
drop if _merge==2
drop _merge
save temp5_2.dta,replace

***shocks: civil war, independence/creation of new states, world wars, systemic changes in distribution of power among states, end of the Cold War
gen ww1 = 1 if year>=1914 & year<=1928
replace ww1 = 0 if ww1==.
gen ww2 = 1 if year>=1939 & year<=1955
replace ww2 = 0 if ww2==.
gen cw = 1 if year>=1989 & year<=1999
replace cw = 0 if cw==.
gen syst = 1 if year>=1859 & year<=1877
replace syst=0 if syst==.
save temp6.dta, replace

***Merge intrastate war data
import delimited "Intra-StateWarData_v4.1.csv", clear
keep if wartype==4|wartype==5
replace ccodea = ccodeb if ccodea==-8
gen obs=_n
reshape long startmonth startday startyear endmonth endday endyear, i(obs) j(episode)
replace endyear = 2007 if endyear==-7
drop if startyear==-8
gen tot = endyear-startyear+1
expand tot
bys obs: gen year = startyear+[_n-1]
gen civw = 1
collapse (max) civw, by(ccodea year)
rename ccodea ccode1
rename civw civw1
save tempciv1.dta, replace
rename ccode1 ccode2
rename civw1 civw2
save tempciv2.dta, replace

use temp6.dta, clear
merge m:1 ccode1 year using tempciv1.dta
drop if _merge==2
drop _merge
merge m:1 ccode2 year using tempciv2.dta
drop if _merge==2
drop _merge
gen civdy = 1 if civw1 == 1 | civw2 == 1
sort dirdy year
replace civdy = 1 if l.civdy==1|l2.civdy==1|l3.civdy==1|l4.civdy==1|l5.civdy==1|l6.civdy==1|l7.civdy==1|l8.civdy==1|l9.civdy==1|l10.civdy==1
replace civdy=0 if civdy==.
gen lcivdy = l.civdy
replace lcivdy=0 if lcivdy==.
save temp7.dta, replace

***Merge state independence data
import delimited "tc2014.csv", clear
rename gainer ccode1
keep ccode1 year indep
collapse (max) indep, by(ccode1 year)
rename indep indep1
save tempterr1.dta, replace
rename ccode1 ccode2
rename indep1 indep2
save tempterr2.dta, replace
use temp7.dta, clear
merge m:1 ccode1 year using tempterr1.dta
drop if _merge==2
drop _merge
merge m:1 ccode2 year using tempterr2.dta
drop if _merge==2
drop _merge
gen indepdy = 1 if indep1==1 | indep2==1
sort dirdy year
replace indepdy=1 if l.indepdy==1|l2.indepdy==1|l3.indepdy==1|l4.indepdy==1|l5.indepdy==1|l6.indepdy==1|l7.indepdy==1|l8.indepdy==1|l9.indepdy==1|l10.indepdy==1
replace indepdy=0 if indepdy==.
gen lindepdy=l.indepdy
replace lindepdy=0 if lindepdy==.
save temp8.dta, replace

***merge Jo and Gartzke nuclear status data
use "jo_gartzke_0207_replicate_0906.dta", clear
rename nuke_df nukposs1
label variable nukposs1 "possess nuclear weapons == 1"
keep ccode1 year nukposs
save "tempnuk1", replace
rename ccode1 ccode2
rename nukposs1 nukposs2
save "tempnuk2", replace
use temp8.dta, clear
merge m:1 ccode1 year using tempnuk1.dta
drop _merge
replace nukposs1=0 if nukposs1==.
sort dirdy year
gen lnukposs1 = l.nukposs1
gen nuknew1 = 1 if l.nukposs1==0 & nukposs1==1
rename nuknew1 n
replace n = 1 if l.n==1|l2.n==1|l3.n==1|l4.n==1|l5.n==1|l6.n==1|l7.n==1|l8.n==1|l9.n==1|l10.n==1
rename n nuknew1
replace nuknew1=0 if nuknew1==.
merge m:1 ccode2 year using tempnuk2.dta
drop _merge
replace nukposs2=0 if nukposs2==.
sort dirdy year
gen lnukposs2 = l.nukposs2
gen nuknew2 = 1 if l.nukposs2==0 & nukposs2==1
rename nuknew2 n
replace n = 1 if l.n==1|l2.n==1|l3.n==1|l4.n==1|l5.n==1|l6.n==1|l7.n==1|l8.n==1|l9.n==1|l10.n==1
rename n nuknew2
replace nuknew2=0 if nuknew2==.
save temp9.dta, replace

***Merge ATOP data
use atop3_0syEUGNNA.dta, clear
keep state number year
rename state ccode1
rename number atop1
save tempatop1, replace
use temp9.dta, clear
merge m:1 ccode1 year using tempatop1
drop _merge
sort dirdy year
gen datop1 = d.atop1
save temp10.dta, replace

use atop3_0ddyrEUGNNA.dta, clear
keep if defense==1 | offense==1
rename stateA ccode1
collapse (sum) defense offense, by(ccode1 year)
gen sum = offense+defense
merge 1:m ccode1 year using temp9.dta
drop _merge
sort dirdy year 
replace sum = 0 if sum ==.
gen allch = d.sum
save temp10.dta, replace

gen mctforce = 1 if mctiss==1 & force==1
replace mctforce = 0 if mctforce==.

gen mctterr = 1 if mctiss==1 & territory==1
replace mctterr = 0 if mctterr==.

gen mctleader = 1 if mctiss==1 & leadership==1
replace mctleader=0 if mctleader==.

gen mctpolicy = 1 if mctiss==1 & policy==1
replace mctpolicy=0 if mctpolicy==.

gen mctrep = 1 if mctiss==1 & reparations==1
replace mctrep=0 if mctrep==.

gen mctother = 1 if mctiss==1 & other==1
replace mctother=0 if mctother==.

gen logcapa = log(cap_1)
gen logcapb = log(cap_2)
sort dirdy year
gen logcaprat = logcapa/(logcapa+logcapb)
gen perlogcap = (d.logcaprat/l.logcaprat)*100
gen lperlogcap = l.perlogcap

replace civw1=0 if civw1==.
replace civw2=0 if civw2==.

replace mctdyad=0 if mctdyad==.
tsspell mctdyad, fcond(mctdyad==1 | l.mctdyad==.)
gen py = l._seq
order py, after(mctiss)
order mctdyad, after(mctiss)
order _seq, after(mctdyad)

gen midyear = year>=1816 & year<=2007
gen mctyear = year>=1918 & year<=2001
save MCTRivalsFinal.dta, replace

*** Merge MID Data
use MCTRivalsFinal.dta, clear
destring ccode*, replace
merge m:1 dirdy year using DyadicMID.dta
drop _merge

gen crisdy = 1 if crisis==1 & oneside!=1
replace crisdy = 0 if crisis!=. & crisdy==.

gen midfat = 1 if cwinit == 1 & cwfatald>0
replace midfat = 0 if midfat==.

save MCTRivalsFinal2.dta, replace

***Merge DOE Data
import delimited "results-predict-dir-dyad.tab", clear
tostring ccode_a ccode_b, format("%03.0f") replace
gen dirdy = ccode_a+ccode_b
destring dirdy ccode_a ccode_b, replace
save tempdoe.dta, replace

use MCTRivalsFinal2.dta, clear
merge m:1 dirdy year using tempdoe.dta
drop _merge

sort dirdy year
gen dvict = d.victorya
gen lvict = l.victorya
gen pvict = dvict/lvict*100
gen lpvict = l.pvict
gen ldvict = l.dvict
gen ldvict100=ldvict*100

replace mp2 = 0 if mp2==.
replace indep1 = 0 if indep1==.
replace indep2 = 0 if indep2==.

gen indep1a = 1 if indep1 == 1
replace indep1a=1 if l.indep1a==1|l2.indep1a==1|l3.indep1a==1|l4.indep1a==1|l5.indep1a==1|l6.indep1a==1|l7.indep1a==1|l8.indep1a==1|l9.indep1a==1|l10.indep1a==1
replace indep1a = 0 if indep1a==.

gen indep2a = 1 if indep2 == 1
replace indep2a=1 if l.indep2a==1|l2.indep2a==1|l3.indep2a==1|l4.indep2a==1|l5.indep2a==1|l6.indep2a==1|l7.indep2a==1|l8.indep2a==1|l9.indep2a==1|l10.indep2a==1
replace indep2a=0 if indep2a==.

gen civw1a = 1 if civw1 == 1
replace civw1a=1 if l.civw1a==1|l2.civw1a==1|l3.civw1a==1|l4.civw1a==1|l5.civw1a==1|l6.civw1a==1|l7.civw1a==1|l8.civw1a==1|l9.civw1a==1|l10.civw1a==1
replace civw1a=0 if civw1a==.

gen civw2a = 1 if civw2 == 1
replace civw2a=1 if l.civw2a==1|l2.civw2a==1|l3.civw2a==1|l4.civw2a==1|l5.civw2a==1|l6.civw2a==1|l7.civw2a==1|l8.civw2a==1|l9.civw2a==1|l10.civw2a==1
replace civw2a=0 if civw2a==.

save MCTRivalsFinal2.dta, replace

*** MCT DV
merge 1:1 dirdy year using tempmctdirdy.dta
drop if _merge==2
drop _merge
replace mctiss=0 if mctiss==.

***Save final version
la var mctiss 	 "Militarized Compellant Threat Issued"
la var krival    "KGD Rival"
la var trival 	 "Strategic Rival"

la var ldvict100 "Change in Challenger's Probability of Winning a Dispute (DOE Score)"
la var lpercap   "Percent Change in Challenger's Share of Capabilities"
la var riv3cta   "Third Party Rivalry (Challenger)"
la var riv3ctb   "Third Party Rivalry (Target)"
la var triv3cta  "Third Party Rivalry (Challenger)"
la var triv3ctb  "Third Party Rivalry (Target)"

la var kgdnew10  "New Rivals"
la var tnew10 	 "New Rivals"
la var victorya  "Challenger's Probability of Winning a Dispute (DOE Score)"
la var caprat 	 "Capability Ratio"
la var nukposs1  "Challenger Nuclear Weapons"
la var nukposs2  "Target Nuclear Weapons"
la var demdy 	 "Democratic Dyad"
la var ally 	 "Alliance"
la var mpdy 	 "Major Power in Dyad"
la var mp1 	 	 "Major Power Challenger"
la var distance  "Distance"
la var ww1 		 "World War I"
la var ww2 		 "World War II"
la var cw 		 "Cold War"
la var civdy 	 "Civil War in Dyad"
la var indepdy 	 "Newly Independent State in Dyad"
la var py 		 "Peace Years"

la var laglead1 "Leader Change (Challenger)"
la var laglead2 "Leader Change (Target)"
la var cummidmax "Cumulative MIDs"
la var lastfatmax "Fatality Level of Last Dispute"

keep dyad dirdy ccode1 ccode2 mctiss krival trival caprat lpercap laglead1 laglead2 riv3cta riv3ctb mctyear nukposs1 nukposs2 demdy ally mp1 distance ww1 ww2 cw civdy indepdy cummidmax lastfatmax py 
save MCTRivalsData.dta, replace
