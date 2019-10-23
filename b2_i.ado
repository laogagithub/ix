	*2019-05-29, version 1.0 ,presenting interaction between two binary varialbes.

program b2_i, 
version 15.0
syntax varlist(min=3) [if][in] [,saving(string)]
preserve

		tokenize `varlist'
		local a "`1'"
		local ax "`1'"
		local y "`2'"
		local x "`3'"
		local adj: word count `varlist'


		local var = subinstr("`varlist'","`y'","",.)
		local var = subinstr("`var'","`x'","",.)
		local vara = subinstr("`var'","`a'","",.)

		local var_m = "`a'"+" `y'"+"##"+"`x' "+"`vara'"
		local var = "`a'"+" `y'"+"#"+"`x' "+"`vara'"

			quietly logistic `var',coef   

			matrix a=e(b)
			local b1=a[1,3] 
			local b2=a[1,2]
			local b3=a[1,4]

			matrix c=e(V)
			local c1 = c[3,3]
			local c2 = c[2,2]
			local c3 = c[4,4]
			local c12 = c[2,3]
			local c13 = c[3,4]
			local c23 = c[2,4]

			local rh1 =  -exp(`b1')
			local rh2 = - exp(`b2')
			local rh3 = exp(`b3')

			local ah1 = - exp(`b1'-`b3')
			local ah2 = - exp(`b2'-`b3')
			local ah3 = (exp(`b1')+exp(`b2')-1)/exp(`b3')

			local sh1 = -exp(`b1')/(exp(`b1')+exp(`b2')-2)
			local sh2 = -exp(`b2')/(exp(`b1')+exp(`b2')-2)
			local sh3 = exp(`b3')/(exp(`b3') -1)

			local rse2 =`c1'*(`rh1')^2+`c2'*(`rh2')^2+`c3'*(`rh3')^2+2*`rh1'*`rh2'*`c12'+2*`rh1'*`rh3'*`c13'+2*`rh2'*`rh3'*`c23'
			local ase2 =`c1'*(`ah1')^2+`c2'*(`ah2')^2+`c3'*(`ah3')^2+2*`ah1'*`ah2'*`c12'+2*`ah1'*`ah3'*`c13'+2*`ah2'*`ah3'*`c23'
			local sse2 =`c1'*(`sh1')^2+`c2'*(`sh2')^2+`c3'*(`sh3')^2+2*`sh1'*`sh2'*`c12'+2*`sh1'*`sh3'*`c13'+2*`sh2'*`sh3'*`c23'

			local rse=sqrt(`c1'*(`rh1')^2+`c2'*(`rh2')^2+`c3'*(`rh3')^2+2*`rh1'*`rh2'*`c12'+2*`rh1'*`rh3'*`c13'+2*`rh2'*`rh3'*`c23')
			local ase=sqrt(`c1'*(`ah1')^2+`c2'*(`ah2')^2+`c3'*(`ah3')^2+2*`ah1'*`ah2'*`c12'+2*`ah1'*`ah3'*`c13'+2*`ah2'*`ah3'*`c23')
			local sse=sqrt(`c1'*(`sh1')^2+`c2'*(`sh2')^2+`c3'*(`sh3')^2+2*`sh1'*`sh2'*`c12'+2*`sh1'*`sh3'*`c13'+2*`sh2'*`sh3'*`c23')

			local r = round(exp(`b3') - exp(`b1') - exp(`b2')+1, 0.0001)
			local a = round(exp(-`b3') - exp(`b1'-`b3') - exp(`b2'-`b3') + 1, 0.0001)
			local s = round((exp(`b3')-1)/(exp(`b1')+exp(`b2')-2),0.0001)

			local rl = round(`r'-1.96*`rse',0.0001)
			local ru = round(`r'+1.96*`rse',0.0001)
			local al = round(`a'-1.96*`ase',0.0001)
			local au = round(`a'+1.96*`ase',0.0001)
			local sl = round(exp(ln(`s')-1.96*`sse'),0.0001)
			local su = round(exp(ln(`s')+1.96*`sse'),0.0001)

			//P value
			local pr = round((1-normal(abs(`r'/`rse')))*2,0.001)
			local pa = round((1-normal(abs(`a'/`ase')))*2,0.001)
			local ps = round((1-normal(abs(ln(`s')/`sse')))*2,0.001)



			// mulplicative
			quietly logistic `var_m'
			matrix r =r(table)
			matrix a=e(b)
			local b1=a[1,3] 
			local b2=a[1,2]
			local b3=a[1,4]

			//OR for x1y0 v.s. x0y0
			quietly   gen `x'1 = 0 if `y'==0 & `x'==0
			quietly replace `x'1 = 1 if `y'==0 & `x'==1
			local varx = "`ax' "+"`x'1 "+" `vara'"
			quietly logistic `varx'
			matrix x1y0 = r(table)
			local x1y011 = x1y0[1,1]
			local x1y041 = x1y0[4,1]
			local x1y051 = x1y0[5,1]
			local x1y061 = x1y0[6,1]
			drop `x'1

			//OR for x0y1 v.s. x0y0
			quietly   gen `x'1 = 0 if `y'==0 & `x'==0
			quietly replace `x'1 = 1 if `y'==1 & `x'==0
			local varx = "`ax' "+"`x'1 "+" `vara'"
			quietly logistic `varx'
			matrix x0y1 = r(table)
			local x0y111 = x0y1[1,1]
			local x0y141 = x0y1[4,1]
			local x0y151 = x0y1[5,1]
			local x0y161 = x0y1[6,1]
			drop `x'1


			//OR for x1y1 v.s. x1y1
			quietly   gen `x'1 = 0 if `y'==0 & `x'==0
			quietly replace `x'1 = 1 if `y'==1 & `x'==1
			local varx = "`ax' "+"`x'1 "+" `vara'"
			quietly logistic `varx'
			matrix x1y1 = r(table)
			local x1y111 = x1y1[1,1]
			local x1y141 = x1y1[4,1]
			local x1y151 = x1y1[5,1]
			local x1y161 = x1y1[6,1]
			drop `x'1


			//OR for x1y1 v.s. x0y1


			quietly   gen `x'1 = 0 if `y'==1 & `x'==0
			quietly replace `x'1 = 1 if `y'==1 & `x'==1
			local varx = "`ax' "+"`x'1 "+" `vara'"
			quietly logistic `varx'
			matrix x = r(table)

			local x11 = x[1,1]
			local x41 = x[4,1]
			local x51 = x[5,1]
			local x61 = x[6,1]
			drop `x'1
			
			//OR for x1y1 v.s. x1y0	
			
			quietly   gen `y'1 = 0 if `x'==1 & `y'==0
			quietly replace `y'1 = 1 if `x'==1 & `y'==1
			local vary = "`ax' " +"`y'1 " + "`vara'"
			quietly logistic `vary'
			matrix y = r(table)
			local y11 = y[1,1]
			local y41 = y[4,1]
			local y51 = y[5,1]
			local y61 = y[6,1]
			drop `y'1
			
				//calculation of cases and controls in each subgroup.

				quietly count if `x'==0 & `y'==0 & `ax'==1
				local ca00= r(N)

				quietly count if `x'==0 & `y'==0 & `ax'==0
				local co00 = r(N)

				quietly count if `x'==0 & `y'==1 & `ax'==1
				local ca01 = r(N)
				quietly count if `x'==0 & `y'==1 & `ax'==0
				local co01 = r(N)

				quietly count if `x'==1 & `y'==0 & `ax'==1
				local ca10 = r(N)
				quietly count if `x'==1 & `y'==0 & `ax'==0
				local co10 = r(N)

				quietly count if `x'==1 & `y'==1 & `ax'==1
				local ca11 = r(N)

				quietly count if `x'==1 & `y'==1 & `ax'==0
				local co11 = r(N)
				matrix output = (`ca00',`co00',1        ,.z       ,.z       ,`ca01',`co01',x0y1[1,1],x0y1[5,1],x0y1[6,1],x0y1[1,1],x0y1[5,1],x0y1[6,1]\ ///
								 .z    ,.z    ,.z       ,.z       ,.z       ,.z    ,.z    ,x0y1[4,1],.z       ,.z       ,x0y1[4,1],.z       ,   .z    \ ///
								 `ca10',`co10',x1y0[1,1],x1y0[5,1],x1y0[6,1],`ca11',`co11',x1y1[1,1],x1y1[5,1],x1y1[6,1],y[1,1]   ,y[5,1]   ,y[6,1]   \ ///
								 .z    ,.z    ,x1y0[4,1],.z       ,.z       ,.z    ,.z    ,x1y1[4,1],.z       ,.z       ,y[4,1]   ,.z       ,.z    \ ///
								 .z    ,.z    ,x1y0[1,1],x1y0[5,1],x1y0[6,1],.z    ,.z    ,x[1,1]   ,x[5,1]   ,   x[6,1],.z       ,.z       ,.z    \ ///
								 .z    ,.z    ,x1y0[4,1],.z       ,.z       ,.z    ,.z    ,x[4,1]   ,.z       ,.z       ,.z       ,.z       ,.z     )
						 

					matrix colnames output =  ca co OR* [95% CI] ca co OR* [95% CI] # # #  
					matrix rownames output = "0" "." "1" "---" "OR!" "."  
					matrix btable=(`r',`rl',`ru',`pr'\ `a',`al',`au',`pa'\ `s',`sl',`su',`ps'\ round(r[1,8],0.0001), round(r[5,8],0.0001), round(r[6,8],0.0001),round(r[4,8],0.001))
						
						//printout results.
						display _newline
						dis as txt "Interaction between `y' and `x' on `1'"
						di _newline
						di "{hline 115}"
						display as txt _column(20)"`y' = 0" _column(60) "`y' = 1" 
						di "`x'     {hline 78}   OR#     [95%     CI]"
						matlist output, nodotz cspec(& %8s & %6.0f & %6.0f & %5.3f & %7.3f & %6.3f & %6.0f & %6.0f & %5.3f & %7.3f & %7.3f & %7.3f & %7.3f & %7.3f & ) ///
									   rspec(&   -&&&&&-) 
						display "Measure of interaction on additive scale: RERI(95% CI) = "`r' "(" `rl' " "`ru' "); P = "`pr' "."                            
						display "Measure of interaction on multiplicative scale: ratio of ORs(95% CI) = " round(r[1,8],0.0001) "(" round(r[5,8],0.0001) "  " round(r[6,8],0.0001) ");P = " round(r[4,8],0.001) "."

						if `adj'>3 {						 
						   local exp "ORs are adjusted for`vara'."
						   }
						di "`exp'"
						di "{it:OR*: comparing with `x'=0 and `y'=0.}"
						di "{it:OR#: comparing with `y'=0 in strata of `x'.}"
						di "{it:OR!:comparing with `x'=0 in strata of `y'.}"
						di "{it:P value are below the ORs.ca:case;co:control.}"
		* put into .docx
		putdocx begin
		putdocx paragraph
		putdocx text ("Interaction between `y' and `x' on `1'.")
		putdocx table tablename = matrix(output),border(all, nil) ///
			  border(bottom) border(top) ///
			  title("                                         `y'=0                       `y'=1                within `x' strata") ///
			  halign(center) nformat(%7.4f) rownames colnames

		putdocx table tablename(3 5,2 3 7 8),nformat(%5.0f)
		putdocx table tablename(3,4 9/14),nformat(%5.2f)
		putdocx table tablename(5 7,4/6 9/14),nformat(%5.2f)

		putdocx table tablename(4 6 8,5/14),nformat(%5.3f)

		putdocx table tablename(1,1),border(top)
		putdocx table tablename(2,2/14),border(top)
		putdocx table tablename(2,1/14),border(bottom)

		putdocx paragraph
		putdocx text ("Measure of intraction on additive scale: RERI(95% CI) =" +string(`r')+"("+string(`rl')+"  "+string(`ru')+") P = "+string(`pr')),linebreak
		putdocx text ("                                                                AP(95% CI) =" +string(`a')+" ("+string(`al')+"  "+ string(`au')+") P = "+string(`pa')),linebreak  
		putdocx text ("                                                                     S(95% CI)="  +string(`s')+" ("+string(`sl')+"  "+string(`su')+") P = "+string(`ps')),linebreak 
		putdocx text ("Measure of intraction on mulplicative scale: ratio of ORs(95% CI) =" +string( round(r[1,8],0.0001))+" ("+string(round(r[5,8],0.0001)) +" " +string(round(r[6,8],0.0001))+ ") P = " +string(round(r[4,8],0.001))),linebreak
		if `adj'>=3 {
		putdocx text ("ORs are adjusted for`vara'."),linebreak
		}
		putdocx text ("OR*: comparing with `x'=0 and `y'=0."),linebreak	
		putdocx text ("OR#: comparing with `y'=0 in strata of `x'."),linebreak
		putdocx text ("OR!:comparing with `x'=0 in strata of `y'."),linebreak
		putdocx text ("P value are below the ORs.ca:case;co:control."),linebreak
		
		
		putdocx save "b2_i.docx",`saving'
		
 restore
 matrix drop _all
end
