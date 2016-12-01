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
#  COMBOS$rLinf<-1
#  COMBOS$rA<-1
#  COMBOS$ruprop<-1
#  COMBOS$rb<-1
#  
#  ###Subsets### To assign bin scores (1,2 or 3) 
#  #rLinf
#  tmp<-subset(COMBOS, Linf>=334 & Linf <=366)
#  tmp$rLinf<-2
#  tmpp<-subset(COMBOS,Linf>=367 & Linf <=400)
#  tmpp$rLinf<-3
#  tmppp<-subset(COMBOS, Linf<=333)
#  COMBOS<-rbind(tmp,tmpp,tmppp)
#  #rA                        
#  tmp<-subset(COMBOS, A>=0.417 & A <=0.583)
#  tmp$rA<-2
#  tmpp<-subset(COMBOS,A>=0.584 & A <=0.750)
#  tmpp$rA<-3
#  tmppp<-subset(COMBOS, A<=0.416)
#  COMBOS<-rbind(tmp,tmpp,tmppp)
#  #ruprop                        
#  tmp<-subset(COMBOS, uprop>=0.310 & uprop <=0.600)
#  tmp$ruprop<-2
#  tmpp<-subset(COMBOS,uprop>=0.601 & uprop <=0.900)
#  tmpp$ruprop<-3
#  tmppp<-subset(COMBOS, uprop<=0.309)
#  COMBOS<-rbind(tmp,tmpp,tmppp)
#  #rb                       
#  tmp<-subset(COMBOS, b>=3.231 & b<=3.360)
#  tmp$rb<-2
#  tmpp<-subset(COMBOS, b>=3.361 & b<=3.500)
#  tmpp$rb<-3
#  tmppp<-subset(COMBOS, rb<=3.230)
#  COMBOS<-rbind(tmp,tmpp,tmppp)
#  return(COMBOS)
#}) 
#
#saveRDS(COMBOS,"C:/Users/Andrew Shamaskin/Google Drive/YPR/YPR_NEW/YPR_DN/COMBOS.rds")
#
#COMBOS<-readRDS(file = "C:/Users/Andrew Shamaskin/Google Drive/YPR/YPR_NEW/YPR_DN/COMBOS.rds")
COMBOS<-readRDS(file = "C:/Users/Andrew Shamaskin/Desktop/GitHub/YPR_DN/COMBOS.rds") 
##Transparent colors for plotting
trans_black<- rgb(0,0,0,alpha=40,maxColorValue=255)
trans_red<- rgb(228,16,16,alpha=40,maxColorValue=255)
trans_green<- rgb(16,228,16,alpha=40,maxColorValue=255)