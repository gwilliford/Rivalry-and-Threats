***Set up
cd "C:\Users\gwill\Dropbox\Research\Published Research\MCT and Rivalry\MCT Data"
use "MCTRivalsData.dta", clear

***Primary Analysis
global kgd caprat nukposs1 nukposs2 demdy ally mp1 distance ww1 ww2 cw civdy indepdy cummidmax lastfatmax py c.py#c.py c.py#c.py#c.py
eststo kgd1: logit mctiss lpercap $kgd if krival==1 & mctyear==1, vce(cluster dirdy)
eststo kgd2: logit mctiss laglead1 laglead2 $kgd if krival==1 & mctyear==1, vce(cluster dirdy)
eststo kgd3: logit mctiss riv3cta riv3ctb $kgd if krival==1 & mctyear==1, vce(cluster dirdy)
eststo kgdfull: logit mctiss lpercap laglead1 laglead2 riv3cta riv3ctb $kgd if krival==1 & mctyear==1, vce(cluster dirdy)

*Marginal effects capability change
su lpercap if krival==1 & mctyear==1, detail
di r(mean)+2*r(sd)
di r(mean)-2*r(sd)
margins, at(lpercap=(-27 29))
di (.0177198-.0115486)/.0115486
		
*Marginal effects leadership change
margins, at(laglead1=(0 1))
di (.0206542-.012829)/.012829
		
*Marginal effects external rivalry
su riv3ctb if krival == 1 & mctyear == 1
di r(mean) + 2*r(sd)
di r(mean) - 2*r(sd)
margins, at(riv3ctb=(0 11))
di (.0198211 - .0129672) / .0129672

su riv3cta if krival == 1 & mctyear == 1
di r(mean) + 2*r(sd)
di r(mean) - 2*r(sd)
margins, at(riv3cta = (0 11))
di (0.0104144 - 0.0166127) / 0.0166127 

*Table 1
esttab kgd1 kgd2 kgd3 kgdfull using kgdtab.rtf, replace rtf label se nonotes varwidth(35) nobaselevels ///
starlevels(* 0.05 ** 0.01) noomit cells(b(star fmt(3)) se(par fmt(3))) ///
collabels(,none) mlabels(,nodep notitles none) eqlabels(,none) ///
wrap varlabels(_cons "Constant") stats(N ll, labels("Observations" "Log-likelihood") fmt(%9.0g)) ///
order(lpercap laglead1 laglead2 riv3cta riv3ctb caprat nukposs1 nukposs2 riv3cta demdy ally mp1 distance cummidmax lastfatmax ww1 ww2 cw civdy indepdy py) ///
refcat(lpercap "Primary Independent Variables" caprat "Dyadic Controls" ww1 "Shock Variables" py "Peace Years", nolabel) ///
addnotes("Entries are binomial logit coefficients. Standard errors clustered by directed dyad in parentheses, * p<0.05 ** p<0.01 in a two-tailed test.") 

***********APPENDIX***********
***KGD Descriptive statistics
estpost su mctiss lpercap laglead1 laglead2 riv3cta riv3ctb caprat nukposs1 nukposs2 demdy ally mp1 cummidmax lastfatmax distance ww1 ww2 cw civdy indepdy if krival==1 & mctyear==1
eststo summstats
esttab summstats using descstats.rtf, cell("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") replace label mlabel(,none) nonumber

	
