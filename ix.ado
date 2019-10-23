*Evaluating interaction
*2019-06-29,version 1.0
program ix, rclass
syntax varlist(min=3) [in] [if] /// 
       ,vt(string asis) [ct(string asis)  N(integer 5) REPeat(integer 500)  ///
       valuey(numlist)  ///
	   saving(string asis)  ///
	   value(numlist)  ///	   
	   teamc(string asis)  ///
	   teamb(string asis)  ///
	   teamr(string )  ///
	   valuex(numlist) ///
	  	   ]
	   
       
	   
*vt option: bb cb cc rb
*ct option: bs b2 v d g r
   *bs bootstrap method
    if "`ct'"=="bs" { 
	   interaction9 `varlist',type(`vt') repeat(`repeat') saving(`saving')
	   di "RERI AP S saved in bs.dta,check with command sysuse bs for Normality."
	   }
	   else{
		   *for 2 binary variables.
			if "`vt'"=="bb" {   
			   b2_i `varlist',saving(`saving')	   
			}
			
			*for one binary and one c.
			if "`vt'" == "cb"{
			   *dichotomize
			   if "`ct'" == "v"{
			   interactionv `varlist',value(`value') saving(`saving')
			   local ct 9
			   }
			   
			   *grouping with autocode() function
			   if "`ct'" == "d"{
			   icb_v `varlist',n(`n') saving(`saving')
			   local ct 9
			   }
			   
			   *group with group() function
			   if "`ct'" == "g"{
			   imcb `varlist',teamc(`teamc') n(`n') teamb(`teamb') saving(`saving')
			   local ct 9
			   }
			   *WARNING!
			   if `ct'!=9 {
			   di "{red:error:vt() unmatched ct().}"
			   }
			 }
			
			
			*for 2 c.
			if "`vt'"=="cc" & "`ct'" == "v"{	   
			   interactioncc `varlist',valuex(`valuex') valuey(`valuey') saving(`saving')	  
			}
			else{
				if "`vt'"=="cc" & "`ct'" != "v" {
			    di "{red:error:vt() unmatched ct().}"
			    }
			}
			
			*for rank varialbe and c.
			if "`vt'"=="rb" & "`ct'" == "r"{	   
			   imrb `varlist',teamr(`teamr') n(`n') teamb(`teamb') saving(`saving')   
			  }
			   else{
			   if "`vt'"=="rb" & "`ct'" != "r" || "`vt'"!="rb" & "`ct'" == "r"{	   
			   di "{red:error:vt() unmatched ct().}"	  
			   }
			}
  }

end

