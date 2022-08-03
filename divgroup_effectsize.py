#!/usr/bin/env python
# coding: utf-8

# In[24]:


# ! pip install stats


# In[233]:


from scipy.stats import friedmanchisquare
import pandas as pd
from scipy.stats import kruskal
import numpy as np
import warnings
import matplotlib.pyplot as plt


# In[234]:


warnings.filterwarnings('ignore')


# In[252]:


group_amt=pd.read_excel('D:/자료/업무/표준진열/22년_유형_점별대분류매출.xlsx')
group_amt.head(3)


# In[273]:


group_amt[group_amt['GROUP']=='B']


# In[296]:


cls1_amt=pd.read_excel('D:/자료/업무/표준진열/22년_유형_점별중분류매출.xlsx')
cls1_amt.head(3)


# In[19]:


#지수표현 풀기
pd.options.display.float_format = '{:.5f}'.format


# In[297]:


cls0list=list(set(group_amt['GOOD_CLS0NM']))
cls1list=list(set(cls1_amt['GOOD_CLS1NM']))


# In[298]:


cls0list.remove('조리식품')
cls1list.remove('외주조리')


# In[291]:


###대분류 기준 --cohen's d
cls0_result1=pd.DataFrame(columns=['cls0','kruskal','effect_AB','effect_AC','effect_BC'])
cls0_result1['cls0']=cls0list
for i in range(len(cls0list)):
    A_1tm=group_amt[(group_amt['GOOD_CLS0NM']==cls0list[i])&(group_amt['GROUP']=='A')][['CLS0_RATIO']].values
    B_1tm=group_amt[(group_amt['GOOD_CLS0NM']==cls0list[i])&(group_amt['GROUP']=='B')][['CLS0_RATIO']].values
    C_1tm=group_amt[(group_amt['GOOD_CLS0NM']==cls0list[i])&(group_amt['GROUP']=='C')][['CLS0_RATIO']].values
    len_a=len(A_1tm)
    len_b=len(B_1tm)
    len_c=len(C_1tm)
    cls0_result1.iloc[i,1]=kruskal(A_1tm,B_1tm,C_1tm)  #크루스칼-왈리스 유형별 카테고리별 매출비중 차이 검정
    cls0_result1.iloc[i,2]=(np.mean(A_1tm)-np.mean(B_1tm))/(np.sqrt(((len_a-1)*np.std(A_1tm)*np.std(A_1tm)+(len_b-1)*np.std(B_1tm)*np.std(B_1tm))/(len_a+len_b-2)))
    cls0_result1.iloc[i,3]=(np.mean(A_1tm)-np.mean(C_1tm))/(np.sqrt(((len_a-1)*np.std(A_1tm)*np.std(A_1tm)+(len_c-1)*np.std(C_1tm)*np.std(C_1tm))/(len_a+len_c-2)))
    cls0_result1.iloc[i,4]=(np.mean(B_1tm)-np.mean(C_1tm))/(np.sqrt(((len_b-1)*np.std(B_1tm)*np.std(B_1tm)+(len_c-1)*np.std(C_1tm)*np.std(C_1tm))/(len_b+len_c-2)))
   
   


# In[306]:


###대분류 기준 ---nonparametric
cls0_result=pd.DataFrame(columns=['cls0','kruskal','effect_AB','effect_AC','effect_BC'])
cls0_result['cls0']=cls0list
for i in range(len(cls0list)):
    A_1tm=group_amt[(group_amt['GOOD_CLS0NM']==cls0list[i])&(group_amt['GROUP']=='A')][['CLS0_RATIO']].values
    B_1tm=group_amt[(group_amt['GOOD_CLS0NM']==cls0list[i])&(group_amt['GROUP']=='B')][['CLS0_RATIO']].values
    C_1tm=group_amt[(group_amt['GOOD_CLS0NM']==cls0list[i])&(group_amt['GROUP']=='C')][['CLS0_RATIO']].values
    median_a=np.median(A_1tm)
    median_b=np.median(B_1tm)
    median_c=np.median(B_1tm)
    len_a=len(A_1tm)
    len_b=len(B_1tm)
    len_c=len(C_1tm)
    mad_a=1.4826*np.median(np.abs(A_1tm-median_a))
    mad_b=1.4826*np.median(np.abs(B_1tm-median_b))
    mad_c=1.4826*np.median(np.abs(C_1tm-median_b))
    pmad_ab=np.sqrt((((len_a-1)*mad_a*mad_a)+((len_b-1)*mad_b*mad_b))/(len_a+len_b-2))
    pmad_ac=np.sqrt((((len_a-1)*mad_a*mad_a)+((len_c-1)*mad_c*mad_c))/(len_a+len_c-2))
    pmad_bc=np.sqrt((((len_b-1)*mad_b*mad_b)+((len_b-1)*mad_c*mad_c))/(len_b+len_c-2))
    cls0_result.iloc[i,1]=kruskal(A_1tm,B_1tm,C_1tm)[1]
    cls0_result.iloc[i,2]=(np.quantile(A_1tm,0.5)-np.quantile(B_1tm,0.5))/pmad_ab
    cls0_result.iloc[i,3]=(np.quantile(A_1tm,0.5)-np.quantile(C_1tm,0.5))/pmad_ac
    cls0_result.iloc[i,4]=(np.quantile(B_1tm,0.5)-np.quantile(C_1tm,0.5))/pmad_bc
   
   


# In[307]:


###중분류 기준 ---nonparametric
cls1_result=pd.DataFrame(columns=['cls1','kruskal','effect_AB','effect_AC','effect_BC'])
cls1_result['cls1']=cls1list
for i in range(len(cls1list)):
    A_1tm=cls1_amt[(cls1_amt['GOOD_CLS1NM']==cls1list[i])&(cls1_amt['GROUP']=='A')][['CLS1_RATIO']].values
    B_1tm=cls1_amt[(cls1_amt['GOOD_CLS1NM']==cls1list[i])&(cls1_amt['GROUP']=='B')][['CLS1_RATIO']].values
    C_1tm=cls1_amt[(cls1_amt['GOOD_CLS1NM']==cls1list[i])&(cls1_amt['GROUP']=='C')][['CLS1_RATIO']].values
    median_a=np.median(A_1tm)
    median_b=np.median(B_1tm)
    median_c=np.median(B_1tm)
    len_a=len(A_1tm)
    len_b=len(B_1tm)
    len_c=len(C_1tm)
    mad_a=1.4826*np.median(np.abs(A_1tm-median_a))
    mad_b=1.4826*np.median(np.abs(B_1tm-median_b))
    mad_c=1.4826*np.median(np.abs(C_1tm-median_b))
    pmad_ab=np.sqrt((((len_a-1)*mad_a*mad_a)+((len_b-1)*mad_b*mad_b))/(len_a+len_b-2))
    pmad_ac=np.sqrt((((len_a-1)*mad_a*mad_a)+((len_c-1)*mad_c*mad_c))/(len_a+len_c-2))
    pmad_bc=np.sqrt((((len_b-1)*mad_b*mad_b)+((len_b-1)*mad_c*mad_c))/(len_b+len_c-2))
    cls1_result.iloc[i,1]=kruskal(A_1tm,B_1tm,C_1tm)[1]
    cls1_result.iloc[i,2]=(np.quantile(A_1tm,0.5)-np.quantile(B_1tm,0.5))/pmad_ab
    cls1_result.iloc[i,3]=(np.quantile(A_1tm,0.5)-np.quantile(C_1tm,0.5))/pmad_ac
    cls1_result.iloc[i,4]=(np.quantile(B_1tm,0.5)-np.quantile(C_1tm,0.5))/pmad_bc
   
   


# non-parametric effect size 출처
# 
# 
# Doksum, Kjell. “Empirical probability plots and statistical inference for nonlinear models in the two-sample case.” The annals of statistics (1974): 267-277.
# 
# 
# Doksum, Kjell A., and Gerald L. Sievers. “Plotting with confidence: Graphical comparisons of two populations.” Biometrika, 63, no. 3 (1976): 421-434.

# In[295]:


cls0_result


# In[309]:


pd.set_option('display.max_row', 100)
cls1_result


# In[247]:


plt.hist(np.log(A_1tm+0.000001))

