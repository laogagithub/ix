
*2019-06-29,version 1.0
program ixgcc
syntax 
version 15.0
 
 *Graph
	   import excel "exp_cc_b.xlsx",sheet("Sheet1") firstrow
	   sort RERI
	  local reri=RERI[1]*RERI[_N]
	  if `reri'>=0{
	   if RERI[1]>=0 {
	       local color "red"
		   local foot "increase risk"
		   }
		   else{
	       if RERI[_N]<=0{
	       local color "green"
		   local foot "decrease risk"
		   }
		   }
		  
		
	   graph twoway scatter $gicc_2 $gicc_3 [fweight = abs(RERI)] , mcolor(`color') msymbol(oh)  ||   ///
	                scatter $gicc_2 $gicc_3 if RERI==0,  msymbol(x) mcolor(black)    ///
	                title("Bigger the circle, Stronger the interaction") ///
					xtitle("Dichotomy value of $gicc_3") ///
					ytitle("Dichotomy value of $gicc_2") ///
					legend(label(1 `foot') ///
					label(2 "with no interaction"))
					
					}
					else{
					
	   graph twoway scatter $gicc_2 $gicc_3  [fweight = abs(RERI)] if RERI<0, mcolor(green) msymbol(oh)    || ///
	                scatter $gicc_2 $gicc_3 [fweight = RERI] if RERI>0, mcolor(red) msymbol(oh)   ||  ///
				    scatter $gicc_2 $gicc_3 if RERI==0,  msymbol(x) mcolor(black)    ///
	                title("Bigger the circle, Stronger the interaction") ///
					xtitle("Dichotomy value of $gicc_3") ///
					ytitle("Dichotomy value of $gicc_2") ///
					legend(label(2 "increase risk") ///
					label(1 "decrease risk") ///
					label(3 "with no interaction"))
					} 	   
	   
       

end

