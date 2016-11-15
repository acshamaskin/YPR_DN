##Needs to generate raw spectrum first and then subset from that given the parameter bounds##


#Raw_Spectrum_Setup<-reactive({
#  
#  nreps=100000
#  COMBOS<- data.frame(t0=runif(nreps,0.210,0.210),
#                      Linf=round(runif(nreps,300,400),0),
#                      A=round(runif(nreps,.250,.750),3),
#                      uprop=round(runif(nreps,0.010,0.900),3),
#                      b=round(runif(nreps,3.100,3.500),3),
#                      aui=runif(nreps,-5.6,-5.6))
#  COMBOS$u=COMBOS$uprop*COMBOS$A
#  COMBOS$Z<--log(1-COMBOS$A)
#  COMBOS$Fmort<-(COMBOS$u*COMBOS$Z)/COMBOS$A
#  #lnk<- 6.62-1.32*(log(COMBOS$Linf))
#  COMBOS$k<-exp(6.62-1.32*(log(COMBOS$Linf)))
#  COMBOS$a<-10^COMBOS$aui
#  for(i in 1:nrow(COMBOS)){
#    COMBOS$rLinf[i]<-ifelse(COMBOS$Linf[i]>=300 & COMBOS$Linf[i]<=333,1,
#                            ifelse(COMBOS$Linf[i]>=334 & COMBOS$Linf[i]<=366,2,
#                                   ifelse(COMBOS$Linf[i]>=367 & COMBOS$Linf[i]<=400,3,COMBOS$rLinf[i])))
#    COMBOS$rA[i]<-ifelse(COMBOS$A[i]>=0.250 & COMBOS$A[i]<=0.416,1,
#                         ifelse(COMBOS$A[i]>=0.417 & COMBOS$A[i]<=0.583,2,
#                                ifelse(COMBOS$A[i]>=0.584 & COMBOS$A[i]<=0.750,3,COMBOS$rA[i])))
#    COMBOS$ruprop[i]<-ifelse(COMBOS$uprop[i]>=0.010 & COMBOS$uprop[i]<=0.300,1,
#                             ifelse(COMBOS$uprop[i]>=0.310 & COMBOS$uprop[i]<=0.600,2,
#                                    ifelse(COMBOS$uprop[i]>=0.610 & COMBOS$uprop[i]<=0.900,3,COMBOS$ruprop[i])))
#    COMBOS$rb[i]<-ifelse(COMBOS$b[i]>=3.100 & COMBOS$b[i]<=3.230,1,
#                         ifelse(COMBOS$b[i]>=3.231 & COMBOS$b[i]<=3.360,2,
#                                ifelse(COMBOS$b[i]>=3.361 & COMBOS$b[i]<=3.500,3,COMBOS$rb[i])))
#  }
#  return(COMBOS)
#}) 
#
#
#saveRDS(COMBOS,"C:/Users/Andrew Shamaskin/Google Drive/YPR/YPR_NEW/YPR_DN/COMBOS.rds")
#
COMBOS<-readRDS(file = "C:/Users/Andrew Shamaskin/Google Drive/YPR/YPR_NEW/YPR_DN/COMBOS.rds")
#  
##Transparent colors for plotting
trans_black<- rgb(0,0,0,alpha=40,maxColorValue=255)
trans_red<- rgb(228,16,16,alpha=40,maxColorValue=255)
trans_green<- rgb(16,228,16,alpha=40,maxColorValue=255)