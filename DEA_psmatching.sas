data data21_x ;
set data21 ;  /*데이터 불러오기. 21년 신규점포 24시간 운영여부, 평수, 오픈후 일매출 등*/
year1='2021';
if oper_time =24 then oper_hour =1 ;else oper_hour =0;
run;

data data_before ;
set data21_x data22 ;
run;


PROC MEANS data=data_before  MIN q1 MEDIAN  mean  q3 MAX std  n;
/*class year1 ;*/
by year1 ;
var oper_hour smoke damt ;
RUN ;

proc freq data= data_before ;
tables year1*store_sz ;
quit; 

data data21 ;
set data21 ;
year1='2021';
if store_sz ='' then delete ;
if oper_time =. then delete ;
if damt =. then delete ;
/*if 평수 ='10~15평   ' then 평수1 =1 ; else 평수1=0 ;*/
/*if 평수 ='10평미만  ' then 평수2=1 ; else 평수2=0 ;*/
/*if 평수 ='15~20평   ' then 평수3 =1 ; else 평수3=0 ;*/
/*if 평수 ='20~25평   ' then 평수4 =1 ; else 평수4=0 ;*/
/*if 평수 ='30평초과  ' then 평수5 =1 ; else 평수5=0 ;*/
if oper_time =24 then oper_hour =1 ;else oper_hour =0;
if smoke =0  then delete ;
if store_sz = '25~30평' or store_sz ='20~25평' or store_sz ='30평초과';
run;



data data22 ;
set data22 ;
year1='2022';
/*if 평수 ='10~15평   ' then 평수1 =1 ; else 평수1=0 ;*/
/*if 평수 ='10평미만  ' then 평수2=1 ; else 평수2=0 ;*/
/*if 평수 ='15~20평   ' then 평수3 =1 ; else 평수3=0 ;*/
/*if 평수 ='20~25평   ' then 평수4 =1 ; else 평수4=0 ;*/
/*if 평수 ='30평초과  ' then 평수5 =1 ; else 평수5=0 ;*/
if oper_time =24 then oper_hour =1 ;else oper_hour =0;
run;

data data ;
set data21 data22 ;
/*keep year1 store_sz  damt oper_hour origin_bizpl_cd  ;*/
run;

proc logistic data=data_before;
class store_sz year1 oper_hour ;
model year1= store_sz  oper_hour damt ;
output out= logi pred=pb;
quit; 
data logi ;
set logi ;
pb2=1-pb ;
run;
proc psmatch data=data ;
class store_sz year1 oper_hour ;
psmodel year1(treated='2022')= store_sz  oper_hour damt ;
/*match method=greeky(k=10) caliper=0.01;*/
match method=greedy(k=10)  caliper=0.01;
/*assess /varinfo plots=(all);*/
output out (obs=match)=out_os matchid=_matchid ;
run;


PROC MEANS data=out_os  MIN q1 MEDIAN  mean  q3 MAXstd  n;
/*class year1 ;*/
by year1 ;
var oper_hour smoke damt ;
RUN ;

proc freq data= out_os ;
tables year1*store_sz ;
quit; 


proc sql noprint ;
select mean(pb2) into: mean_before from logi ;
select std(pb2) into : std_before from logi ;
quit; 

proc sql noprint ;
select mean(_PS_) into: mean_after from out_os ;
select std(_PS_) into : std_after from out_os ;
quit; 


/*PS 그리기*/

PROC UNIVARIATE DATA=logi NOPRINT;
    CLASS year1;
    HISTOGRAM pb2;
    INSET N='N' (6.0) MEAN='MEAN' (6.4) STD='STD' (6.4) / FONT='ARIAL' POS=NE HEIGHT=3;
RUN;

PROC UNIVARIATE DATA=out_os NOPRINT;
    CLASS year1;
    HISTOGRAM _ps_ ;
    INSET N='N' (6.0) MEAN='MEAN' (6.4) STD='STD' (6.4) / FONT='ARIAL' POS=NE HEIGHT=3;
RUN;


proc psmatch data=data ;
class '평수'N year1 oper_hour ;
psmodel year1(treated='2022')= 평수 oper_hour 일객수 일매출액 월평균판매상품수 ;
/*match method=greeky(k=5) caliper=0.1;*/
match method=greedy(k=1)  caliper=0.01;
/*assess /varinfo plots=(all);*/
output out (obs=match)=out_os2 matchid=_matchid ;
run;


/*겹쳐그리기*/
PROC sgplot	 DATA=out_os ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram damt /group=year1 transparency=0.8;
density damt /type=kernel group=year1;
run;

/*겹쳐그리기*/
PROC sgplot	 DATA=out_os ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram _ps_ /group=year1 transparency=0.8;
density _ps_ /type=kernel group=year1;
INSET N='N' (6.0) MEAN='MEAN' (4.2) STD='STD' (6.4) / POS=NE HEIGHT=3;
run;

PROC UNIVARIATE DATA=out_os ;
 by year1;
HISTOGRAM _ps_/ endpoints = 0 to 1 by 0.05;
INSET N='N' (6.0) MEAN='MEAN' (4.2) STD='STD' (6.4) / POS=NE HEIGHT=3;
run;



PROC sgplot	 DATA=out_os ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram '일매출액'N  /group=year1 transparency=0.8;
density  '일매출액'N  /type=kernel group=year1;
run;

PROC sgplot	 DATA=out_os ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram 월평균판매상품수  /group=year1 transparency=0.8;
density 월평균판매상품수 /type=kernel group=year1;
run;





/*겹쳐그리기*/
PROC sgplot	 DATA=out_os2 ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram 일객수  /group=year1 transparency=0.8;
density '일객수'N  /type=kernel group=year1;
run;

PROC sgplot	 DATA=out_os2 ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram '일매출액'N  /group=year1 transparency=0.8;
density  '일매출액'N  /type=kernel group=year1;
run;

PROC sgplot	 DATA=out_os2 ;
/*var 'ratio2019추석'n 'ratio2020추석'n;*/
histogram 월평균판매상품수  /group=year1 transparency=0.8;
density 월평균판매상품수 /type=kernel group=year1;
run;





PROC MEANS data=out_os MIN q1 MEDIAN q3 MAX  mean std ;
var damt days _ps_ ;
class year1 ;
RUN ;



PROC MEANS data=data22(keep='일객수'N 일매출액 월평균판매상품수 oper_hour ) MIN q1 MEDIAN q3 MAX  mean std ;
/*class year1 ;*/
RUN ;



PROC MEANS data=data21(keep='일객수'N 일매출액 월평균판매상품수 oper_hour ) MIN q1 MEDIAN q3 MAX  mean std ;
/*class year1 ;*/
RUN ;


proc sql; 
create table total22 as
select origin_bizpl_cd, sum(amt) as amt,sum(cnt_key) as cnt_key,sum(goods_cnt) as goods_cnt
		, sum(days) as days,count(distinct yyyymm) as yn
		,calculated cnt_key /calculated days as 일객수
		,calculated amt /calculated days as 일매출액
		,calculated goods_cnt /calculated yn as 월평균판매상품수 
from  data22_total
group by 1;
quit; 


PROC MEANS data=total22(keep='일객수'N 일매출액 월평균판매상품수  ) n  MIN q1 MEDIAN q3 MAX  mean std ;
/*class year1 ;*/
RUN ;

proc freq data=out_os ;
tables year1*평수 /nocol norow nopercent;quit; 
