data=read.table("D:/자료/업무/표준진열/DEA_사용변수.csv",header=TRUE,sep=",")
install.packages("Benchmarking")
library(Benchmarking)
set.seed(1234)
install.packages("dplyr")
library(dplyr)



#DEA분석
data['wic_damt']=data['wic_amt']/data['days']
data['osc_damt']=data['osc_amt']/data['days']
data['gg_damt']=data['gg_amt']/data['days']
data['rif_damt']=data['rif_amt']/data['days']


x<- as.matrix(data[,c('m3','oper_m')])
y<- as.matrix(data[,c('wic_damt','osc_damt','gg_damt','rif_damt')])
def_res= dea(x,y,RTS='vrs')  #vsr: BCC , crs :CCR 모형 그외 옵션있음
def_res$eff
data.frame(origin_bizpl_cd=data[,c('origin_bizpl_cd')],type=data[,c('type')],eff=def_res$eff)




data2=data[data[['origin_bizpl_cd']] %in%  c('V6V49','V7C44',  'V6N68',  'V6K96', 'V7W44',  'V7Y42', 'V7W68', 
                                             'V7Q63',  'V6U42',  'V6Z88','V6N97',   'V8G67',   'V8M38',  'V8K38', 
                                             'V8K45', 'V8F92',  'V8F67',  'V8Q68',  'V8M82', 'V8H35','V8A29', 'V8K67'),]


x2<- as.matrix(data2[,c('rif_goodsn','days')])
y2<- as.matrix(data2[,c('rif_amt')])
def_res= dea(x2,y2,RTS = 'vrs')
data.frame(origin_bizpl_cd=data2[,c('origin_bizpl_cd')],type=data2[,c('type')],eff=def_res$eff)
dea.plot(x,y)


x=as.table(summary(data[data[['type']]==2021,]))
x
