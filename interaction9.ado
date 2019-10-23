*Estimation of RERI,AP and S with bootstrap method.

program interaction9, rclass
	syntax varlist(min=3),repeat(integer) type(string) [saving(string asis)] [if][in] 

	quietly bootstrap RERI=r(reri) AP=r(ap) S=r(s),saving(bs,`saving') reps(`repeat'):interactionc `varlist',type("`type'")

	estat bootstrap,all
end

