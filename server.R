#server.R
library(shiny)
library(plyr)
#library(sm)
source('global.R',local=TRUE)

shinyServer(function(input, output, session) {
  ######OLD CODE IS IN global.R#######
  
  sim_dat<- function()
  {
    #sim<- Raw_Spectrum_Setup()
    sim<-COMBOS
    #bring in mll
    sim$quality<-as.numeric(unlist(strsplit(input$quality,",")))
    sim$quality<-sim$quality*25.4
    mll<-as.numeric(unlist(strsplit(input$mll,",")))
    mll<-mll*25.4
    #merge mll with big dataframe.  creates a list of dataframes with a ll as a column, then combines all dataframes
    func<-function(x,y){y=data.frame(x,y)}
    mf<-lapply(mll,func,sim)
    mf<-do.call("rbind",mf)
    colnames(mf)[1]<-"mll"
    ###Moved these calculations in the original raw_spectrum build
    #mf$u<-mf$uprop*mf$A ###Calculate Fmort
    #mf$Z<--log(1-mf$A)
    #mf$Fmort<-(mf$u*mf$Z)/mf$A
    ##set time of fishery recruitment from mll
    mf$tr=((log(1-(mf$mll/mf$Linf))/(-(mf$k)))+mf$t0)
    mf$tquality<-ifelse(mf$quality<=mf$Linf,((log(1-(mf$quality/mf$Linf))/(-(mf$k)))+mf$t0),999)
    out<-mf
    return(out)
  }
  
  #  Adams-Bashforth
  preppop<-reactive({
    sim<-sim_dat()
    maxage<-8
    #sim1<-subset.data.frame(sim, lake==1)
    #sim2<-subset.data.frame(sim, lake==2)
    #sim3<-subset.data.frame(sim, lake==3)
    step<- 0.1
    ages<-seq(0,maxage+1,step)
    L1<-Y1<-N1<-NH1<-QH1<-matrix(0,nrow(sim),length(ages))
    N1[,1]<- 1000 #Initial Recruitment N0
    
    
    for(i in 2:ncol(N1))
    {
      #    indx1<-ifelse(ages[i]>=sim$min_age_harvested & ages[i]<sim$tr,1,0)
      indx2<-ifelse(ages[i]>=sim$tr,1,0)
      indx3<-ifelse(ages[i]>=sim$tquality,1,0)
      harvested<-N1[,i-1]*(sim$Fmort*indx2)
      qharvested<-N1[,i-1]*(sim$Fmort*indx3)
      mortality<- N1[,i-1]*(sim$Z-sim$Fmort)
      dN<- (mortality+harvested)*step
      dNH<-harvested*step
      dQH<-qharvested*step
      Lt<-sim$Linf * (1 - exp(-sim$k* (ages[i-1]-sim$t0)))
      ###WEIGHT AT AGE
      Wt = (sim$a*Lt^sim$b)/1000
      dY<-ifelse(harvested==0,0,(Wt*harvested)*step)
      # AvgWeightharvested<-ifelse(harvested==0,0,())
      N1[,i]<-N1[,i-1]-dN
      #N[,2]<-N[,1]-dN
      #N[,i+1]<-N[,i]+(1.5*dN[i])-0.5(dN[i-1])
      Y1[,i]<- Y1[,i-1]+dY
      #Y[,2]<- Y[,1]+dY
      #Y[,i+1]<- Y[,i]+(1.5*dY[i])-0.5(dY[i-1])
      L1[,i]<-  Lt*(1/N1[,i-1])
      NH1[,i]<- NH1[,i-1]+dNH
      QH1[,i]<- QH1[,i-1]+dQH
    }
    sim$Yab<- Y1[,ncol(Y1)]
    sim$AvgWt<-sim$Yab/(NH1[,ncol(NH1)])
    sim$Harvestrate<-NH1[,ncol(NH1)]/(maxage-sim$tr)
    sim$QualityHarvest<-QH1[,ncol(QH1)]/(maxage-sim$tr)
    return(sim)
  })
  ######PUT SUBSET HERE TO MAKE IT GO FASTER#######
  vals<-function()
  {
    tmp<-preppop()
    
    tmp<-subset(tmp,
                (rLinf %in% as.numeric(input$Linf)) &
                  (rA %in% as.numeric(input$A)) &
                  (ruprop %in% as.numeric(input$up)) &
                  (rb %in% as.numeric(input$b)))
    #(Linf>=min(indx1)) & (Linf<=max(indx1)) &
    #(A>=min(indx2)) & (A<=max(indx2)) &
    #(uprop>=min(indx3)) & (uprop<=max(indx3)) &
    #(b>=min(indx4)) & (b<=max(indx4)))
    #tmp$quality<-as.numeric(unlist(strsplit(input$quality,",")))
    #tmp$quality<-tmp$quality*25.4
    #add all your inputs 
    #out$t0<-runif(input$nlakes,min(input$t0),max(input$t0)) example of previous method
    # out$nLakes<-input$nLakes
    sim<-tmp
    return(sim)
  }
  #####utility scores 11/30/2016 Method to Normalize utility scores
  
  #function to normalize inputs
  attrib_norm<-reactive({
    A_init<-c(input$Yieldweight,input$AvgWtweight,input$Hrateweight,input$QHrateweight)
    A_tot<-sum(A_init)
    A_norm<-A_init
    for(i in 1:length(A_init)){
      A_norm[i]<-A_init[i]/A_tot  
    }
    return(A_norm)
  })

  LLscore<-reactive({
    output<-vals()
    A_norm<-attrib_norm()
    ##RANK LENGTH LIMITS BASED ON NormalYield+NormalAvgWt
    scoringYield<-aggregate(Yab~mll,output,mean)
    scoringAvgWt<-aggregate(AvgWt~mll,output,mean)
    scoringHrate<-aggregate(Harvestrate~mll,output,mean)
    scoringQHrate<-aggregate(QualityHarvest~mll,output,mean)
    Scores<-join_all(list(scoringYield,scoringAvgWt,scoringHrate,scoringQHrate),by="mll")
    #Scores<-merge(scoringYield,scoringAvgWt,scoringHrate,scoringQHrate,by="mll")
    Scores$Yieldscore<-((Scores$Yab-min(Scores$Yab))/(max(Scores$Yab)-min(Scores$Yab)))*100*A_norm[1]
    Scores$AvgWtscore<-((Scores$AvgWt-min(Scores$AvgWt))/(max(Scores$AvgWt)-min(Scores$AvgWt)))*100*A_norm[2]
    Scores$Hratescore<-((Scores$Harvestrate-min(Scores$Harvestrate))/(max(Scores$Harvestrate)-min(Scores$Harvestrate)))*100*A_norm[3]
    Scores$QHratescore<-((Scores$QualityHarvest-min(Scores$QualityHarvest))/(max(Scores$QualityHarvest)-min(Scores$QualityHarvest)))*100*A_norm[4]
    Scores$Total<-Scores$Yieldscore+Scores$AvgWtscore+Scores$Hratescore+Scores$QHratescore
    Scores$mll<-round((Scores$mll/25.4),0)
    
    return(Scores)
  })
  
  output$ScoreLL<-renderTable({
    LLscore()
  })
  
  ##Dynamically gives LL radio buttons an updated list of choices
  llinput<-reactive({
    llinput<-unique(vals()$mll)
    llinput<-llinput/25.4
    # llinput<-list(llinput)
    
    return(llinput)
  })
  observe({
    updateRadioButtons(session, "llselect", choices = c(llinput()[[1]],llinput()[[2]],llinput()[[3]],"Show All"))
  })
  
  output$text1<-renderText({
    paste("You have selected", input$llselect)
  })
  
  
  data <- reactive({
    dat<-vals()
    #if(input$llselect=="Show All"){ ####11/14/16 took out if statement so the plots can have the same axes
    datt <-switch(input$datt,
                  Yield = data.frame(dat$Yab,dat$mll),
                  AverageWt = data.frame(dat$AvgWt,dat$mll),
                  HarvestRate = data.frame(dat$Harvestrate,dat$mll),
                  QualityHarvest = data.frame(dat$QualityHarvest,dat$mll)
    )
    return(datt) 
    #else{llselect<-as.numeric(input$llselect)*25.4 
    #dat<-subset(dat,mll==llselect)
    #datt <-switch(input$datt,
    #              Yield = dat$Yab,
    #              AverageWt = dat$AvgWt,
    #              HarvestRate = dat$Harvestrate,
    #              QualityHarvest = dat$QualityHarvest
    #              )
    #return(datt)}
  })
  
  output$plot<-renderPlot({
    datt<-input$datt
    llselect<-input$llselect
    # if(input$llselect=="Show All"){
    ###SHOW ALL DENSITY PLOT###
    den<-data()
    xlim<-range(den[,1])
    mll<-unique(den[,2])
    dena<-subset(den,den[,2]==mll[1])
    denb<-subset(den,den[,2]==mll[2])
    denc<-subset(den,den[,2]==mll[3])
    # dena<-dena[,1]
    #  denb<-denb[,1]
    # denc<-denc[,1]
    dena<-density(dena[,1])
    denb<-density(denb[,1])
    denc<-density(denc[,1])
    ylim<-range(dena$y,denb$y,denc$y)
    if(input$llselect=="Show All"){
      plot(dena,col="black", type="l",xlim=xlim,ylim=ylim,xlab=paste(datt),main=paste(datt, 'for all length limits',sep=' '))
      polygon(dena,col=trans_black)
      lines(denb)
      polygon(denb,col=trans_red)
      lines(denc)
      polygon(denc,col=trans_green)} 
    ######
    #if(input$llselect=="Show All") {d<-data()
    #sm.density.compare(d[,1],d[,2], xlab=paste(datt, 'for all length limits',sep=' '))} 
    ####INDIVIDUAL LL DENSITY####
    else{d<-subset(den,den[,2]==(as.numeric(llselect)*25.4))
    d<-density(d[,1])
    plot(d,xlim=xlim,ylim=ylim,xlab=paste(datt),main=paste(datt, 'for',llselect,'inch length limit',sep=' ' ))
    polygon(d, col=trans_black)}
    #hist(data(),main=paste(datt, 'for',llselect,'inch length limit',sep=' ' ))
  })
  
})
