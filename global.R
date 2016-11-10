##Needs to generate raw spectrum first and then subset from that given the parameter bounds##


Raw_Spectrum_Setup<-reactive({
  
  nreps=50000
  COMBOS<- data.frame(t0=runif(nreps,0.210,0.210),
                      Linf=runif(nreps,300,400),
                      A=runif(nreps,.25,.75),
                      uprop=runif(nreps,0.01,0.90),
                      b=runif(nreps,3.1,3.5),
                      aui=runif(nreps,-5.6,-5.6))
  COMBOS$u=COMBOS$uprop*COMBOS$A
  COMBOS$Z<--log(1-COMBOS$A)
  COMBOS$Fmort<-(COMBOS$u*COMBOS$Z)/COMBOS$A
  #lnk<- 6.62-1.32*(log(COMBOS$Linf))
  COMBOS$k<-exp(6.62-1.32*(log(COMBOS$Linf)))
  COMBOS$a<-10^COMBOS$aui
  return(COMBOS)
}) 
#
#
#
#
#
#  
