*Exploring RERI between two continous varialbes by converting them into binary variables.

program interactioncc, rclass 
version 15.0
syntax varlist(min = 3) [if][in],valuex(numlist ascending) valuey(numlist ascending) [saving(string)]

preserve     

tokenize `varlist'

local k "`1'"
local ax "`1'"
local y "`2'"
local x "`3'"


local var = subinstr("`varlist'","`y'","",.)
local var = subinstr("`var'","`x'","",.)
local vara = subinstr("`var'","`1'","",.)

local var_m = "`1'"+" `y'1"+"##"+"`x'1 "+"`vara'"
local var = "`1'" +" `y'1"+"#"+"`x'1 "+"`vara'"
quietly gen `y'1 =.
quietly gen `x'1 =.

local cx: word count `valuex'
local cy: word count `valuey'
local v = `cx'*`cy'
local col_name = ""
local row_name = ""

		      matrix x = J(`v',4,.z)
			  matrix x2 = J(`cy',`cx',.z)
			 
			  local ix 0
			  local iy 0
			  *recycle x
		      foreach nx of local valuex {
			   local ix `ix'+1
               quietly replace `x'1 = 0 
			   quietly replace `x'1 = 1 if `x' > `nx'
			
					   local ia 0
				foreach ny of local valuey {
				      local ia `ia'+1
				
				   *calculating
					  local i =(`ix'-1)* `cy' + `ia'
					  quietly replace `y'1 = 0 
					  quietly replace `y'1 = 1 if `y' > `ny'
		   
					quietly logistic `var'   
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

				

					local rse=sqrt(`c1'*(`rh1')^2+`c2'*(`rh2')^2+`c3'*(`rh3')^2+2*`rh1'*`rh2'*`c12'+2*`rh1'*`rh3'*`c13'+2*`rh2'*`rh3'*`c23')
					local r = round(exp(`b3') - exp(`b1') - exp(`b2')+1, 0.0001)
					
					local rl = round(`r'-1.96*`rse',0.0001)
					local ru = round(`r'+1.96*`rse',0.0001)
				
															
					
					// mulplicative
					quietly logistic `var_m'
					matrix r =r(table)
					local p_m=r[4,8]
					local or_m=r[1,8]
					local low_m=r[5,8]
					local up_m=r[6,8]
					
					matri x[`i',1]=`nx'
					matri x[`i',2]=`ny'
									
					if `rl'*`ru'>0{						
						matri x[`i',3]=`r'
						matri x2[`ia',`ix']=`r'	
					}
					else{
					    matri x[`i',3]=0
						
					}
					if `p_m'< 0.05 {
						matri x[`i',4]=`or_m'				
						}
						else{
					    matri x[`i',4]=0
						
					}
						

					dis "calculating `x' :`nx'        `y': `ny' " 
					
				}
				    
					local nx = string(`nx')
				
				local row_name = "`row_name'" + "`nx' "
			}
			foreach ny of local valuey {
			     local ny = string(`ny')
			 	 local col_name = "`col_name'" + "`ny' " 
					}
			 dis _newline
			 dis "{title:RERI for different dichotomy value of `x' and `y'}"
			 dis "   `y'        `x'"
		     matrix rownames x2 = `col_name'
			 matrix colnames x2 = `row_name'
			 matlist x2, nodotz
			 
			 dis "saved as {hi:exp_cc_b.xlsx} already."
  restore
			
	*putexcel
	   local cell=char(66)+string(2)
	   putexcel set "exp_cc_b.xlsx",`saving'
	   quietly putexcel `cell' = matrix(x)
	   quietly putexcel B1 = "`x'"
	   quietly putexcel C1 = "`y'" 
	   quietly putexcel D1 = "RERI" 
	   quietly putexcel E1 = "P_Multi" 
	   
	   global gicc_2 `2'
	   global gicc_3 `3'
	   global gicc_1 `1'
	   
	
end

