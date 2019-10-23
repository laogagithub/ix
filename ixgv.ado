
*graph for interactionv
*2019-06-29,version 1.0
program ixgv
syntax 
version 15.0
 
 import excel "exp_bc_v.xlsx",sheet("Sheet1") firstrow	   
       graph twoway scatter RERI $giv_2              || ///
	                scatter lower_bound $giv_2       || ///
					scatter upper_bound $giv_2       || ///
					line RERI $giv_2                 || ///
	                line lower_bound $giv_2          || ///
					line upper_bound $giv_2   , ///
                    title("Interaction between $giv_2 and $giv_3 on $giv_1") ///
					ytitle("RERI(95% CI)")  ///
					xtitle("Dichotomy value of $giv_2")  yline(0)  	   
	   
       

end

