# BDA400 Assignment 6 | Parvana Babali | 664430071
library(shiny)
library(ggplot2)
library(quantmod)
ui <- fluidPage(
 titlePanel("Stock Portfolio Technical Dashboard - Parvana Babali"),
 sidebarLayout(sidebarPanel(
  textInput("symbol","Yahoo Finance symbol","AAPL"),
  dateRangeInput("dates","Date range",start="2023-01-01",end=Sys.Date()),
  selectInput("period","Time frame",c("Daily","Weekly","Monthly")),
  selectInput("chart","Chart type",c("Line","Area","Candlestick")),
  checkboxGroupInput("ind","Indicators",c("Moving Averages"="MA","RSI","MACD"),selected=c("MA","RSI","MACD")),
  numericInput("fast","Fast SMA",20,min=2),
  numericInput("slow","Slow SMA",50,min=3),
  checkboxInput("markers","Show Buy/Sell annotations",TRUE),
  actionButton("refresh","Refresh")
 ),mainPanel(
  textOutput("summary"),plotOutput("price"),
  conditionalPanel("input.ind.indexOf('RSI') >= 0",plotOutput("rsi")),
  conditionalPanel("input.ind.indexOf('MACD') >= 0",plotOutput("macd")),
  tableOutput("signals")
 ))
)
server <- function(input,output,session){
 prices <- reactive({
  input$refresh
  validate(need(grepl("^[A-Za-z0-9.^=-]+$",input$symbol),"Invalid ticker"))
  tryCatch({
   x <- getSymbols(toupper(input$symbol),src="yahoo",from=as.Date(input$dates[1]),to=as.Date(input$dates[2])+1,auto.assign=FALSE)
   if(input$period=="Weekly") x <- to.weekly(x,indexAt="lastof")
   if(input$period=="Monthly") x <- to.monthly(x,indexAt="lastof")
   data.frame(Date=as.Date(index(x)),Open=as.numeric(Op(x)),High=as.numeric(Hi(x)),Low=as.numeric(Lo(x)),Close=as.numeric(Cl(x)))
  },error=function(e) validate(need(FALSE,conditionMessage(e))))
 })
 d <- reactive({
  x <- prices()
  validate(need(input$slow>input$fast && input$fast>=2,"Slow SMA must exceed fast SMA"))
  validate(need(nrow(x)>max(input$slow,35),"Select more observations"))
  x$Fast <- as.numeric(SMA(x$Close,n=input$fast))
  x$Slow <- as.numeric(SMA(x$Close,n=input$slow))
  x$RSI <- as.numeric(RSI(x$Close,n=14))
  m <- MACD(x$Close,nFast=12,nSlow=26,nSig=9,maType="EMA")
  x$MACD <- as.numeric(m[,1]);x$SignalLine <- as.numeric(m[,2])
  x$Hist <- x$MACD-x$SignalLine
  pf <- c(NA,head(x$Fast,-1));ps <- c(NA,head(x$Slow,-1))
  buy <- !is.na(pf)&!is.na(ps)&!is.na(x$Fast)&!is.na(x$Slow)&pf<=ps&x$Fast> x$Slow
  sell <- !is.na(pf)&!is.na(ps)&!is.na(x$Fast)&!is.na(x$Slow)&pf>=ps&x$Fast<x$Slow
  x$Signal <- ifelse(buy,"Buy",ifelse(sell,"Sell","Hold"))
  x
 })
 output$summary <- renderText({x<-d();paste("Last close:",round(tail(x$Close,1),2),"| Signal:",tail(x$Signal,1))})
 output$price <- renderPlot({
  x<-d()
  p<-ggplot(x,aes(x=Date))+theme_minimal()+labs(title=paste(input$symbol,"stock prices"),y="USD")
  if(input$chart=="Line") p<-p+geom_line(aes(y=Close))
  if(input$chart=="Area") p<-p+geom_area(aes(y=Close),alpha=.5)
  if(input$chart=="Candlestick") {
   x$Up<-x$Close>=x$Open
   p<-p+geom_linerange(data=x,aes(ymin=Low,ymax=High))+
    geom_rect(data=x,aes(xmin=Date-.35,xmax=Date+.35,ymin=pmin(Open,Close),ymax=pmax(Open,Close),fill=Up),alpha=.6)+
    scale_fill_manual(values=c("TRUE"="darkgreen","FALSE"="firebrick"))
  }
  if("MA"%in%input$ind) p<-p+geom_line(aes(y=Fast,color="Fast SMA"),na.rm=TRUE)+geom_line(aes(y=Slow,color="Slow SMA"),na.rm=TRUE)
  if(input$markers) {
   marks<-x[x$Signal!="Hold",,drop=FALSE]
   if(nrow(marks)>0) p<-p+geom_point(data=marks,aes(y=Close,shape=Signal),size=3)+
     geom_text(data=marks,aes(y=Close,label=Signal),vjust=-1,check_overlap=TRUE)
  }
  p
 })
 output$rsi<-renderPlot({
  ggplot(d(),aes(Date,RSI))+geom_line(na.rm=TRUE)+
   geom_hline(yintercept=c(30,70),linetype="dashed")+coord_cartesian(ylim=c(0,100))+
   labs(title="RSI (14)")+theme_minimal()
 })
 output$macd<-renderPlot({
  ggplot(d(),aes(Date))+geom_col(aes(y=Hist),alpha=.4,na.rm=TRUE)+
   geom_line(aes(y=MACD,color="MACD"),na.rm=TRUE)+
   geom_line(aes(y=SignalLine,color="Signal"),na.rm=TRUE)+
   labs(title="MACD (12,26,9)")+theme_minimal()
 })
 output$signals<-renderTable({
  x<-d();events<-x[x$Signal!="Hold",c("Date","Close","Signal"),drop=FALSE]
  if(nrow(events)==0) return(data.frame(Message="No crossover events"))
  tail(events,10)
 })
}
shinyApp(ui,server)
