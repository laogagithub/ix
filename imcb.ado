*FOR ONE BINARY AND ONE CONTINUOUS.
*Converting a continuous variable into rank variable with function group().

program imcb, rclass
syntax varlist(min=3) [if][in] ,teamc(string) n(integer) teamb(string)  [saving(string)]

preserve                              
matrix drop _all
	tokenize `varlist'

	local varx = subinstr("`varlist'","`teamc'","",.)
	local var = subinstr("`varx'","`teamb'","",.)
	local vara = subinstr("`var'","`1'","",.)
	local var = "`1'" + " `teamb'`teamc'"+" "+"`vara'"

	tempname output r r01 reri

	quietly cap  gen `teamc'0 = group(`n')
	quietly cap gen `teamb'`teamc' = 0 if  `teamc'0 == 1 & `teamb'== 0
	quietly cap gen `teamb'1 =0 if `teamc'0 == 1 & `teamb'== 1
	
	local var1 = "`1'"+" `teamb'1 "+"`vara'"

	matrix r010 = J(`n',4,.)	  
	  local team = `n'*2
	  local rowname = ""
	  
	  forvalue ty = 1(1)`n'{		
			  
					quietly count if  `teamb' == 0 & `teamc'0 == `ty' & `1' == 1
					local ca10 = r(N)
					quietly count if  `teamb' == 0 & `teamc'0 == `ty' & `1' == 0
					local co10 = r(N)
					quietly count if  `teamb' == 1 & `teamc'0 == `ty' & `1' == 1
					local ca11 = r(N)
					quietly count if  `teamb' == 1 & `teamc'0 == `ty' & `1' == 0
					local co11 = r(N)
					
					 * OR10 VS OR00 
						 if `ty' >1 {
						
							  quietly replace `teamb'`teamc' = 1 if  `teamb' == 0 & `teamc'0 == `ty'
							  quietly logistic `var'	      
							  matrix r1000 = r(table)
							  quietly replace `teamb'`teamc' = . if  `teamb' == 0 & `teamc'0 == `ty'
							  matrix r010[`ty',1]=r1000[1,1]
							  matrix r010[`ty',2]=r1000[5,1]
							  matrix r010[`ty',3]=r1000[6,1]
							  matrix r010[`ty',4]=r1000[4,1]
							  }
						 
				  
					  * OR01 VS OR00
							quietly replace `teamb'`teamc' = 1 if  `teamb' == 1 & `teamc'0 == `ty'
							quietly logistic `var'
							matrix r1100 = r(table)
							quietly replace `teamb'`teamc' = . if  `teamb' == 1 & `teamc'0 == `ty'
							
						  
					  * OR01 VS OR10
							quietly logistic `varx' if `teamc'0 ==`ty'
							matri r0110 = r(table)
							
							
							
							local rowname = "`rowname'"+ "`teamc'=`ty' . "
						
				  *DEFINE new matrix
				   if `ty'==1 {
					   *OR
						matrix new = nullmat(new)\(`ca10',`co10',1   ,.z    ,.z  , ///
												   `ca11',`co11',r1100[1,1] ,r1100[5,1],r1100[6,1],r0110[1,1] ,r0110[5,1] ,r0110[6,1])
						matrix new = nullmat(new)\(.z,.z,.z  ,.z,.z, ///
												   .z,.z,r1100[4,1],.z,.z ,r0110[4,1] ,.z ,.z )
				   }
				   else{
					   *OR
						matrix new = nullmat(new)\(`ca10',`co10',r1000[1,1] ,r1000[5,1],r1000[6,1], ///
													`ca11',`co11',r1100[1,1] ,r1000[5,1],r1100[6,1],r0110[1,1]  ,r0110[5,1] ,r0110[6,1])
						* p value								  
						matrix new = nullmat(new)\(.z,.z,r1000[4,1]  ,.z,.z, ///
														 .z,.z,r1100[4,1],.z,.z ,r0110[4,1] ,.z ,.z ) 	
						}
				   
				  
		 }
				 
				 
      *Calculating OR for continous variable within strata of dichotomy value
				  
      forvalue ty = 2(1)`n' {
				 
					* OR10 VS OR01
					  quietly replace `teamb'1 = 1 if  `teamc'0 == `ty' & `teamb'==1
					  quietly logistic `var1'	      
					  matrix r1101 = r(table)
					  quietly replace `teamb'1 = . if  `teamb'1 == 1 & `teamc'0 == `ty'
				
					  matrix new = nullmat(new)\(.z,.z,r010[`ty',1] ,r010[`ty',2],r010[`ty',3]  , ///
											   .z,.z,r1101[1,1] ,r1101[5,1],r1101[6,1],.z  ,.z ,.z)
				   	* p value								  
				      matrix new = nullmat(new)\(.z,.z,r010[`ty',4],.z,.z, ///
											     .z,.z,r1101[4,1],.z,.z ,.z ,.z ,.z )								   
		 
		}
		   
	  *Display new
		  local rowname = "`rowname'"+ " OR**"+ (`n'-2)*2*" . "
		  matrix colnames new = case control OR* [95% CI] case control OR* [95% CI] OR# [95% CI]
		  matrix rownames new = `rowname'
		  
		  display _newline "Interaction between `teamc' and `teamb' on `1'" 
		  dis "{hline 134}"
		  
		  dis "{center 80:`teamb'=0}"   "{center 15:`teamb'=1}"  "{center 55:within strata of `teamc'}"
		  dis "                      " "{hline 85}"
		  local sign = "& -"+(4*`n'-3)*"&"+"-"
		  matlist new,nodotz cspec(& %20s & %6.0f & %6.0f & %7.4f & %7.4f & %7.4f & %6.0f & %6.0f & %7.4f & %7.4f & %7.4f & %7.3f & %7.4f & %7.4f & ) ///
								rspec(`sign')
		 
	  *Calculating and Displaying RERI
			
				quietly cap gen `teamc'`teamb' = 0 if  `teamc'0 == 1
				local var = "`1'"+" `teamb'"+"#"+"`teamc'`teamb' "+"`vara'" 
				local var_m = "`1'"+" `teamb'"+"##"+"`teamc'`teamb' "+"`vara'"
				local mv = `n'-1
				
				matrix mv = J(`mv',4,.)	
			
		forvalue ty = 2(1)`n'{					   
				quietly replace `teamc'`teamb' = 1 if  `teamc'0 == `ty'
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

				local rse=sqrt(`c1'*(`rh1')^2+`c2'*(`rh2')^2+`c3'*(`rh3')^2+2*`rh1'*`rh2'*`c12'+2*`rh1'*`rh3'*`c13'+2*`rh2'*`rh3'*`c23')

				local r = round(exp(`b3') - exp(`b1') - exp(`b2')+1, 0.0001)

				local rl = round(`r'-1.96*`rse',0.0001)
				local ru = round(`r'+1.96*`rse',0.0001)

				//p value
				local pr = round((1-normal(abs(`r'/`rse')))*2,0.001)
				
				*calculate multiplicative
				quietly logistic `var_m',
				matrix vm =r(table)
				
				matrix mv[`ty'-1,1] = vm[1,8]
				matrix mv[`ty'-1,2] = vm[5,8]
				matrix mv[`ty'-1,3] = vm[6,8]
				matrix mv[`ty'-1,4] = vm[4,8]
					
				*display RERI
		
			if `ty'==2 {
				  di "Measure of intraction on additive scale: RERI(95% CI)=" "`r'(`rl',`ru'),P=`pr'" 
			  }
			  else{
				 dis "                                                        `r'(`rl',`ru'),P=`pr'"
			    }			
			 quietly replace `teamc'`teamb' = . if  `teamc'0 == `ty'
	    }       
		
		
		*Disaplay Multiplicative
			  forvalue ty = 2(1)`n'{
					if `ty'==2 {			
						di "Measure of intraction on multiplicative scale: Ratios of OR(95% CI)= " mv[`ty'-1,1] "(" mv[`ty'-1,2] "," mv[`ty'-1,3] ") ,P = " mv[`ty'-1,4]
							   }
							   else{
						di "                                                                     " mv[`ty'-1,1] "(" mv[`ty'-1,2] "," mv[`ty'-1,3] ") ,P = " mv[`ty'-1,4]
					   }
					}
			  local adj:word count `varlist'
			  if `adj'>3 {
					 dis "ORs are adjusted for`vara'."
			   }
			   else{
				   di "ORs are not adjusted."
				   }				   
	 dis"*:comparing with `teamb'=0 and `teamc'=1;"
	 dis"#:relative risk of `teamb' within strata of `teamc';"
	 dis"**:relative risk for different group of `teamc' comparing with `teamc'=1 within strata of `teamb'."
	 dis"P value are below the ORs."
	 dis "{hline 134}"	 
	 local cell=char(66)+string(2)
	 putexcel   set "exp_imcb.xlsx",`saving'
	 putexcel `cell' = matrix(new)
    
restore
end
