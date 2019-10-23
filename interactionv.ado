*For one continuous and one binary.
*Converting a continuous variable into binary and calculating RERI,AP,S for each dichotomy value.

program interactionv, rclass 
version 15.0
syntax varlist(min = 3), value(numlist ascending) [saving(string)] [if][in]

preserve 

tokenize `varlist'

local k "`1'"
local ax "`1'"
local y "`2'"
local x "`3'"

sort `y'
local yn=`y'[_N]
local y1=`y'[1]
local var = subinstr("`varlist'","`y'","",.)
local var = subinstr("`var'","`x'","",.)
local vara = subinstr("`var'","`1'","",.)

local var_m = "`1'"+" `y'1"+"##"+"`x' "+"`vara'"
local var = "`1'" +" `y'1"+"#"+"`x' "+"`vara'"
cap gen `y'1 =.

local countv: word count `value'
		
		      matrix x = J(`countv',8,.)
			  matrix d = J(`countv',8,.)
			  local i 0
		      foreach num of local value {
			  if `num'<`y1' | `num'>`yn' {
			  di"{red:dichotomy value out of range for `y'}"
			  }
			  else{
			  local i `i'+1
              quietly replace `y'1 = 0 
			  quietly replace `y'1 = 1 if `y' > `num'
		
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
					
					//p value
					local pr = (1-normal(abs(`r'/`rse')))*2
					local pa = round((1-normal(abs(`a'/`ase')))*2,0.001)
					local ps = round((1-normal(abs(ln(`s')/`sse')))*2,0.001)
					
					//OR and their 95% CI
					//logistic `var'
					//matrix o = r(table)
					
					
					// mulplicative
					quietly logistic `var_m'
					matrix r =r(table)
					local p_m=r[4,8]
					local or_m=r[1,8]
					local low_m=r[5,8]
					local up_m=r[6,8]
					
					matri d[`i',1]=`num'
					matri d[`i',2]=`r'
					matri d[`i',3]=`rl'
					matri d[`i',4]=`ru'
					matri d[`i',5]=`pr'
					matri d[`i',6]=`or_m'
					matri d[`i',7]=`low_m'
					matri d[`i',8]=`up_m'
					
					matri x[`i',1]=`num'
					if `rl'*`ru'>0{
					matri x[`i',2]=`r'
					matri x[`i',3]=`rl'
					matri x[`i',4]=`ru'
					matri x[`i',5]=`pr'
					}
					else{
					matri x[`i',2]=.z
					matri x[`i',3]=.z
					matri x[`i',4]=.z
					matri x[`i',5]=.z
					}
					if `p_m'< 0.05 {
					matri x[`i',6]=`or_m'
					matri x[`i',7]=`low_m'
					matri x[`i',8]=`up_m'
					
					}
					else{
					matri x[`i',6]=.z
					matri x[`i',7]=.z
					matri x[`i',8]=.z
					}
					dis " *dichotomy value of `y': " `num' 
					 
					}
					}
			drop `y'1
			  
			dis _newline "{hline 102}"
			display "{Interaction between `y' and `x' on `1' with each dichotomy value of `y'}" 
			dis _newline
			display "{it:Multiplicative results(95% CI) only with P< 0.05 will be printed.}" 
			display "{it:Only 95% CIs of RERI that DO NOT contain 0 will be printed.}" 
			display "{it:Adjustment:`vara'.}" 
			matrix colnames x =  "`y'" RERI [95% CI] P_value Multiplicative [95% CI]
			//matrix rownames x = ""  
			di "{hline 102}"
			matlist x, nodotz
			di "{hline 102}"
  
	restore  
	   local cell=char(66)+string(2)
	   global giv_2 `2'
	   global giv_3 `3'
	   global giv_1 `1'
	   
	   putexcel set "exp_bc_v.xlsx",`saving'
	   quietly putexcel `cell' = matrix(d)
	   quietly putexcel B1 = "`y'"
	   quietly putexcel C1 = "RERI" 
	   quietly putexcel D1 = "lower_bound" 
	   quietly putexcel E1 = "upper_bound" 
	   quietly putexcel F1 = "P_value"
	   quietly putexcel G1 = "Multiplicative" 
	   quietly putexcel H1 = "lower_bound" 
	   quietly putexcel I1 = "upper_bound"
	   			
	   dis "saved as {hi:exp_bc_v.xlsx} already."
	   
	  
end

