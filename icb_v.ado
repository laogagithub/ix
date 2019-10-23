*FOR ONE BINARY AND ONE CONTINUOUS.
*Converting a continuous variable into rank variable with function autocode().


program icb_v, rclass 
version 15.0
syntax varlist(min = 3) [in] [if], n(integer) saving(string)
preserve
matrix drop _all

tokenize `varlist'
local x = "`3'"
local y = "`2'"
local varx = subinstr("`varlist'","`y'","",.)
local var = subinstr("`varx'","`x'","",.)
local vara = subinstr("`var'","`1'","",.)
local var = "`1'" + " `x'`y' "+"`vara'"
local var_01 = "`1'"+" `x' "+"`vara'"
local adj:word count `varlist'
tempname output r r010 

	sort `2'	
	local yn=`y'[_N]	
	local y1=`y'[1]	
	cap gen `y'_t = autocode(`y',`n',`y1',`yn')
	tabulate `y'_t,gen(`y')
	
	*Creating varialbe 
        cap  gen t_`y' = 1 if `y'1 ==1			
		forvalue i=2(1)`n' {		  
		   replace t_`y' = `i' if `y'`i' == 1		 
		}		
		quietly  gen `x'`y' = 0 if  t_`y' == 1 & `x'== 0	
        quietly cap gen `x'1 =0 if t_`y' == 1 & `x'== 1
local var1 = "`1'"+" `x'1 "+"`vara'"
matrix r010 = J(`n',4,.)  
  local team = `n'*2
  local rowname = ""

  forvalue ty = 1(1)`n'{
        
  
		quietly count if  `x' == 0 & t_`y' == `ty' & `1' == 1
		local ca10 = r(N)
		quietly count if  `x' == 0 & t_`y' == `ty' & `1' == 0
		local co10 = r(N)
		quietly count if  `x' == 1 & t_`y' == `ty' & `1' == 1
		local ca11 = r(N)
		quietly count if  `x' == 1 & t_`y' == `ty' & `1' == 0
		local co11 = r(N)
		
		 * OR10 VS OR00 
		 if `ty' >1 {
		
		  quietly replace `x'`y' = 1 if  `x' == 0 & t_`y' == `ty'
          quietly logistic `var'	      
          matrix r1000 = r(table)
 		  quietly replace `x'`y' = . if  `x' == 0 & t_`y' == `ty'
          matrix r010[`ty',1]=r1000[1,1]
		  matrix r010[`ty',2]=r1000[5,1]
		  matrix r010[`ty',3]=r1000[6,1]
		  matrix r010[`ty',4]=r1000[4,1]
          }
		 
  
       * OR01 VS OR00
        quietly replace `x'`y' = 1 if  `x' == 1 & t_`y' == `ty'
        quietly logistic `var'
	    matrix r1100 = r(table)
		quietly replace `x'`y' = . if  `x' == 1 & t_`y' == `ty'
		
      
        * OR01 VS OR10
		quietly logistic `varx' if t_`y' ==`ty'
		matri r0110 = r(table)
		
		
		
		local rowname = "`rowname'"+ "`y'=`ty' . "
	  *new matrix
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
		                                 .z,.z,r1000[4,1],.z,.z ,r0110[4,1] ,.z ,.z ) 	
		}
       
	  
	   }
	   *Calculating OR for continous variable within strata of dichotomy value
	  
	   forvalue ty = 2(1)`n' {
	 
	    * OR10 VS OR01
	      quietly replace `x'1 = 1 if  t_`y' == `ty' & `x'==1
		 quietly logistic `var1'	      
          matrix r1101 = r(table)
 		 quietly replace `x'1 = . if  `x'1 == 1 & t_`y' == `ty'
	
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
	  
	  display _newline "Interaction between `y' and `x' on `1' BASED ON range of `y'/`n'" 
	  dis "{hline 134}"
	  
	  dis "{center 80:`x'=0}"   "{center 15:`x'=1}"  "{center 55:within strata of `y'}"
	  dis "                      " "{hline 85}"
	  local sign = "& -"+(4*`n'-3)*"&"+"-"
      matlist new,nodotz cspec(& %20s & %6.0f & %6.0f & %7.4f & %7.4f & %7.4f & %6.0f & %6.0f & %7.4f & %7.4f & %7.4f & %7.3f & %7.4f & %7.4f & ) ///
                            rspec(`sign')
	 
			*calculate and display RERI
		
			quietly cap gen `y'`x' = 0 if  t_`y' == 1
			local var = "`1'"+" `x'"+"#"+"`y'`x' "+"`vara'" 
			local var_m = "`1'"+" `x'"+"##"+"`y'`x' "+"`vara'"
			local mv = `n'-1
			
			matrix mv = J(`mv',4,.)
			
			forvalue ty = 2(1)`n'{
				   
		    quietly replace `y'`x' = 1 if  t_`y' == `ty'
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
			
			*Calculating multiplicative
		    quietly logistic `var_m',
            matrix vm =r(table)
			
			matrix mv[`ty'-1,1] = vm[1,8]
			matrix mv[`ty'-1,2] = vm[5,8]
			matrix mv[`ty'-1,3] = vm[6,8]
			matrix mv[`ty'-1,4] = vm[4,8]
		 		
		    *Display RERI
	
	    if `ty'==2 {
		  	  di "Measure of intraction on additive scale: RERI(95% CI)=" "`r'(`rl',`ru'),P=`pr'" 
		  }
		  else{
		     dis "                                                         `r'(`rl',`ru'),P=`pr'"
		  }
		  
		
         quietly replace `y'`x' = . if  t_`y' == `ty'

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
     dis"*:comparing with `x'=0 and `y'=1;"
	 dis"#:relative risk of `x' within strata of `y';"
	 dis"**:relative risk for different group of `y' comparing with `y'=1 within strata of `x'."
	 dis"P value are below the ORs."
 	 dis "{hline 134}"	 
     local cell=char(66)+string(2)
     putexcel   set "exp_icb_v.xlsx",`saving'
     putexcel `cell' = matrix(new)
restore
end

