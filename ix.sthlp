{smcl}
{* *! version 1.0 16 JUN 2019}{...}

{cmd:help ix}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:ix} {hline 8}}evaluate interaction between two variables with logistic model.{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:ix} [{it:yvar}] {it:var1} {it:var2} [{it:cvars}], {opt vt(#)} 
	 [ {it:options} ]


{phang}
{it:yvar} is the variable name for the binary outcome. 

{phang}
{it:var1} is the variable name for the first exposure,binary or continuous.If binary, it must be coded as 0/1.

{phang}
{it:var2} is the variable name for the second exposure,binary or continuous.If binary, it must be coded as 0/1.

{phang}
{it:cvars} are the variable names for the covariates to be included in the model for the outcome.

{phang}
{it:vt(#)} specifies the type of the two varialbes whose interaction that you are interested,bb,cb or cc.bb:two binary ones,cc:two continuous ones,cb:one binary and one continous varialbe.


{phang}
{it:Attention:} when evaluating interaction between one binary and one continous variables, var1 must be continous varialbe.

{synoptset 31 tabbed}{...}
{synopthdr :options}
{synoptline}
{p2coldent:* {opt ct(#)}}type of calculation{p_end}

{synopt :{opt teamc(string)}}name of continous varialbe{p_end}
{synopt :{opt teamb(string)}}name of binary varialbe{p_end}
{synopt :{opt teamr(string)}}name of rank varialbe{p_end}

{synopt :{opt n(integer)}}numbers of group for continous variable {p_end}
{synopt :{opt repeat(#)}}# replications for boostrap,default is 500{p_end}

{synopt :{opt valuey(numlist)}}dichotomy value for var1,must be in asending range{p_end}
{synopt :{opt valuex(numlist)}}dichotomy value for var2,must be in asending range{p_end}
{synopt :{opt value(numlist)}}dichotomy value for continuous variable,must be in asending range{p_end}

{synopt :{opt saving(string)}}modify or replace to store the results.{p_end}
{synopt :{opt ixgv}}visualize the exploring results after analysis with the combination of ct(v) and vt(cb).{p_end}
{synopt :{opt ixgcc}}visualize the exploring results after analysis with the combination of ct(v) and vt(cc).{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* is required most of the time.{p_end}


{title:Description}

{pstd}
{cmd:ix} On additive and multiplicative scale, evaluating interation with logistic model or boostrap between two varialbes ,which can be both binary, both continous or their conbination.

{pstd}
{cmd:ix} provides standard result presentation according recommendations authored by Knol Mirjam J. and VanderWeele Tyler J. published in 2012[1]. Exploring interaction between continuous variables with bootstrap,by converting continous varialbe to binary variable based on a range of numlist.



{title:Options}

{phang}
{opt ct(#)} specifies the calculation for assessing interaction.There are 4 choices:bs,v,g,d and r.{p_end}

{p 7 6 2}{opt bs}: calcute RERI,AP and S with bootstrap.{p_end}
{p 7 6 2}{opt v}: when specifing vt(#) as vt(cb),this option converts continuous variable into binary variable for each value defined by value() and calculate RERI.When specifing vt(#) as vt(cc),this option converts the two continous varialbes into binary ones based on numlist defined by valuex() and valuey() and calculate RERI,valuey for var1 and valuex() for var2.{p_end}
{p 7 6 2}{opt g}: when specifing vt(#) as vt(cb),n(integer) is required, and this option sorts continuous variable and then grouping it with function {cmd:group()}.{p_end}
{p 7 6 2}{opt d}: when specifing vt(#) as vt(cb),n(integer) is required, and this option groups continous varialbe with the function {cmd:autocode()}.{p_end}
{p 7 6 2}{opt r}: when specifing vt(#) as vt(rb),this option is for one rank varialbe and one binary variable.{p_end}


{title:Examples}


    {title:Binary outcome}

{pstd}Load data{p_end}
{phang2}{stata sysuse nlsw88}{p_end}

{pstd}Converting wage into binary variable{p_end}
{phang2}{stata gen y=0}{p_end}
{phang2}{stata replace y=1 if wage>6 }{p_end}
{pstd}Exploring with bootstrap{p_end}
{phang2}{stata ix y grade ttl_exp smsa,vt(cc) ct(bs) repeat(500) saving(nlsw88_bs)}{p_end}
{phang2}{stata ix y ttl_exp smsa grade,vt(cb) ct(bs) repeat(500) saving(nlsw88_bs)}{p_end}
{phang2}{stata ix y ttl_exp smsa grade,vt(bb) ct(bs) repeat(500) saving(nlsw88_bs)}{p_end}

{pstd}Exploring with continuous variable{p_end}
{phang2}{stata ix y  ttl_exp grade smsa,vt(cc) ct(v) valuex(9(1)15) valuey(9(1)15)}{p_end}
{phang2}{stata clear}{p_end}
{phang2}{stata ixgcc}{p_end}


{phang2}{stata ix y  ttl_exp smsa grade,vt(cb) ct(v) value(5(2)22)}{p_end}
{phang2}{stata clear}{p_end}
{phang2}{stata ixgv}{p_end}

{phang2}{stata ix y  age union ttl_exp,vt(cb) ct(g) n(3) teamc(age) teamb(union) }{p_end}
{phang2}{stata ix y  age union ttl_exp,vt(cb) ct(d) n(3) teamc(age) teamb(union) saving(modify)}{p_end}
{phang2}{stata ix y  smsa union ttl_exp grade,vt(bb)}{p_end}


{title:Reference}

{pstd}1. Knol, M.J.,T.J. VanderWeele, Recommendations for presenting analyses of effect modification and interaction. International Journal of Epidemiology, 2012. 41(2): p. 514-520.{p_end}
{pstd}2. Assmann., S.F., D.W. Hosmer., S. Lemeshow., et al., Confidence Intervals for Measures of Interaction. Epidemiology, 1996. 7(3): p. 286-290.{p_end}
{pstd}3. Knol, M.J., I. van der Tweel, D.E. Grobbee, et al., Estimating interaction on an additive scale between continuous determinants in a logistic regression model. International Journal of Epidemiology, 2007. 36(5): p. 1111-1118.{p_end}
{pstd}4. Hosmer, D.W.,S. Lemeshow, Confidence interval estimation of interaction. Epidemiology, 1992. 3(5): p. 452-6.{p_end}
{pstd}5. Andersson, T., L. Alfredsson, H. Källberg, et al., Calculating measures of biological interaction. European Journal of Epidemiology, 2005. 20(7): p. 575-579.{p_end}
