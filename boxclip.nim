import parsecsv
import strutils
import os
import plotly
import stats
import math
import parseopt
import strformat
import times

var tme=newSeq[float](0)
var goodsig=newSeq[float](0)
var yy=newSeq[string](0)
var mid=newSeq[float](20)
var sms=newSeq[float](20)
var count= 0
var countmin=0

var filename,timelabel,datelabel,siglabel,line,storeNA,mode:string

var na=(9999.0)

var clipit, mx1, mn1, mx2, mn2, this,test, lo, hi :float
var full, part,rest,hgt,sm, num1, num2, miny, mea :float  
 
var rs:RunningStat
var width:int
var nbins: int
var mm:int
var all:int

datelabel=""
timelabel="x"
siglabel="y"
clipit=(-1)
miny=15.0
width=0
hgt=0.0
storeNA="y"

var pc = initOptParser()
while true:
  pc.next()
  case pc.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    if pc.val == "":
      if pc.key=="v":         
         echo ("Version:  0.1 by Thomas Ruf; Vetmeduni Vienna Austria; GPL 3.0")   
         echo("  ")
      if pc.key=="h":
          echo "-h help"
          echo "-v Version"
          echo "--clipit=cut off value"
          echo "--c=cut off value works as well"
          echo "--width=half the width of box in units of x"
          echo "--height=half the height of the box in units of the signal"
          echo "--time=name of the x-column"
          echo "--date=name of the x-column"
          echo "--signal=name of the signal column"
          echo "--miny=minimal value oy signals"
          echo "--storeNA=y or n"
          echo "--NA=value for NA"
          echo "--mode=h for histogram of neighbors"
          echo ""
  
    else:
      if pc.key=="c": 
          clipit=parseFloat(pc.val)
      if pc.key=="clipit": 
          clipit=parseFloat(pc.val)   
      if pc.key=="width":
          width=parseInt(pc.val)
      if pc.key=="height":
          hgt=parseFloat(pc.val)
      if pc.key=="time":
        timelabel= toLowerAscii($(pc.val))   
      if pc.key=="date":
          datelabel= toLowerAscii($(pc.val)) 
          timelabel=""       
      if pc.key=="signal":
          siglabel= toLowerAscii($(pc.val)) 
      if pc.key=="storeNA":
          storeNA=toLowerAscii($(pc.val))
      if pc.key=="miny":
          miny=parseFloat(pc.val)
      if pc.key=="NA":
          na=parseFloat(pc.val)
      if pc.key=="mode":
          mode=toLowerAscii($(pc.val))
            
  of cmdArgument:
    filename=pc.key
    

     
if filename=="":
    quit("No Filename provided, sorry")

#Read data
var p: CsvParser
p.open(filename)
p.readHeaderRow()

if timelabel!="":
    echo "time:",timelabel

if datelabel=="auto":
    datelabel=""
    timelabel="auto"
    
if datelabel!="":
    echo "date:",datelabel 
    echo "converting to Unixtime" 
     
if timelabel=="auto":
    echo ("Forcing regular times")
    

while p.readRow():
    count=count+1
    if timelabel=="auto":
        tme.add( float(count))
    if datelabel!="":
        var tStr = (p.rowEntry(datelabel))
        var tmestr= parseTime(tStr, "yyyy-MM-dd HH:mm:ss", utc())
        tme.add(toUnixFloat(tmestr))
    if timelabel!="" and timelabel!="auto":
        tme.add(parseFloat(p.rowEntry(timelabel)))
       
    yy.add(p.rowEntry(siglabel))
p.close()

let n=yy.len                        # length of signal

var sig=newSeq[float](n)
echo "signal:",siglabel
for i in 0..n-1:
    sig[i]=0.0
    if yy[i]=="NA":
        sig[i]=na
    else:
        sig[i]=parseFloat(yy[i])  # make signal, may contain NA



var neighbors=newSeq[float](n)   # will store the neighbor proportiom
var filtered=newSeq[float](n)    # willstore the filtered data including NA

    
if width==0:
    width=int(float(n)*0.01)     # default width


for i in 0..n-1:                 # sinal w/o NA
     if sig[i]!=na:
         goodsig.add(sig[i])

         
if hgt==0.0:
    rs.push(goodsig)             # default height
    mea= rs.mean()
    hgt=floor(mea/4)


let k=n+2*width                  # data extention to estimate to both ends
var ndat=newSeq[float](k)


for i in 0..width-1:             # Left
  ndat[i]=sig[i]
     
count=0
for i in width..width+n-1:       # Center
    ndat[i]=sig[count]
    count+=1

count=0
for i in n+width..n+(2*width)-1: # Right
    ndat[i]=sig[count]
    count+=1

for i in width..width+n-1:       # Main loop
    this=ndat[i]
    hi=this+hgt
    lo=this-hgt
    if this != na:
        sm=0
        count=0
        for j in i-width.. i+width:
            count+=1
            test=ndat[j]
            if test!=na:
                if test>=lo and test<=hi:
                     sm+=1   
        all=count
    neighbors[i-width]=sm/float(all)


countmin=0
for i in 0..n-1:                # restore too small values 
    if sig[i]<miny:
        neighbors[i]=0
        countmin+=1
    filtered[i]=na

if n<10000:
    nbins=10
else:
    nbins=20


var bin:int
var dd:float

for i in 0..nbins-1:
        sms[i]=0.0

for i in 0..n-1:
    if  neighbors[i]!=na:
            if neighbors[i]>0.999:
                dd=0.000001
            else:
                dd=0
    bin=int(floor(neighbors[i]*float(nbins)-dd))
    sms[bin]+=1             # bin neighbors
      

let midincr=1/(float(nbins))
for i in 0..nbins-1:
    mid[i]=float(i)*midincr+midincr/2
    

let max1=max(sms[2..nbins-1])
for i in 1..nbins-1:    
    if sms[i]==max1:
        mm= i

let min1=min(sms[1..mm])
for i in 1..nbins-1:
    if sms[i]==min1:
        mm=i               # compute clipit from first trough in histo

if clipit<0:                    # Compute clipit if required           
    clipit=mid[mm]

    
echo()
echo( "clipit: " & $(fmt"{clipit:>2.3f}"))
echo ("width : " & $(width))
echo ("height: " & $(fmt"{hgt:>3.1f}"))

count=0
for i in 0..n-1:
     if sig[i]!=na:
        if  neighbors[i]>clipit:
                filtered[i]=sig[i]
                count+=1
     else:
        filtered[i]=na

            
                                # Report data length
                                
full=float(goodsig.len)
part=float(count)

echo()
echo ("Full w/o NA: " & $(full))
echo ("Remaining  : " & $(part))

rest=abs(part/full)*100.0

echo( $(fmt"{rest:>2.1f}") & "% values remain")
echo()

proc histo (sms: seq[float], mid: seq[float]) =

    let
      x=mid
      y = sms
      d = Trace[float](`type`: PlotType.Bar,
                       xs: x,
                       ys: y,
                       orientation: Vertical)

    let
      layout = Layout(title: "Histogram of neighbor proportions",
                      xaxis: Axis(title:"proportion"),
                      yaxis: Axis(title:"count", ty: AxisType.Log),
                      width: 800, height: 500,
                      autosize: false)
      ppp = Plot[float](layout: layout, traces: @[d])
    ppp.show()

   
if mode=="h":
    histo(sms,mid)
    quit()

  
let f=open("box.csv",fmWrite) #store results on disk
line = timelabel & "," & siglabel
f.writeLine(line)
    
for i in 0..n-1:
        num1 = tme[i]
        num2 = filtered[i]

        if num2==na:
            if storeNA=="y":
                line=num1.formatFloat(ffDecimal, 4) & ",NA" 
                f.writeLine(line)
        else:
            line=num1.formatFloat(ffDecimal, 4) & "," & num2.formatFloat(ffDecimal, 6)
            f.writeLine(line)
f.close()

        
  
mx1=(-1e12)                 #plot result
mn1=1e12
for i in 0..n-1:
    if sig[i]!=na:
        mn1=min(mn1,sig[i])
        mx1=max(mx1,sig[i])
mn1=mn1*0.8
mx1=mx1*1.2


mx2=(-1e12)
mn2=1e12
for i in 0..n-1:
    if filtered[i]!=na:
        mn2=min(mn2,filtered[i])
        mx2=max(mx2,filtered[i])
mn2=mn2*0.8
mx2=mx2*1.2



let
        d1 = Trace[float](mode: PlotMode.Markers, `type`: PlotType.Scatter, xs:tme, ys:sig, name: "Before")
        d2 = Trace[float](mode: PlotMode.Markers, `type`: PlotType.Scatter, xs:tme, ys:filtered,name: "After" )
    
let
            layout1 = Layout( title:"",width:600, height: 400,
            xaxis: Axis(title:"time"),
            yaxis: Axis(title: "signal",
            range:(mn1, mx1)),
            autosize: false)
            
            layout2 = Layout( title:"",width:600, height: 400,
            xaxis: Axis(title:"time"),
            yaxis: Axis(title: "signal",
            range:(mn2, mx2)),
            autosize: false)
            
            pl1 = Plot[float](layout: layout1, traces: @[d1])
            pl2 = Plot[float](layout: layout2, traces: @[d2])
  


let baseLayout = Layout(title: "boxfilter", width: 800, height: 800,autosize: false)


let pltS2 = subplots:
  baseLayout: baseLayout

  grid:
    rows: 2
    columns: 1
  plot:
    pl1
  plot:
    pl2

pltS2.show()


  



