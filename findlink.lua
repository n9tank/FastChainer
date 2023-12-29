function bnd(old,value,st)
st=st or 1
local ed=#old
local mid=0
local adr
while st<=ed do
md=(st+ed)//2
local adr=old[md].address
if math.abs(md-mid)<=1 then
if value>adr and md+1<#old then
return md+1
end
return md
end
mid=md
if adr<value then
st=mid+1
else
if adr>value then
ed=mid-1
else
return md
end
end
end
end
x32=gg.getTargetInfo().x64
function x64(value)
if x32 then
value=value&0xffffffff
end
return value
end
function find(old,value,len)
local eqz=bnd(old,value)
if eqz then
eqz=old[eqz]
local off=eqz.address-value
if off>8 and off<len then
local min=eqz.min
if min==nil or off<min then
eqz.min=off
end
return eqz
end
end
end
function nextlvl(old,len,offmax)
gg.internal3(len)
local adr,link
local new=gg.getResults(100000)
for t=1,#new do
adr=new[t]
local value=x64(adr.value)
adr.value=value
link=find(old,value,offmax)
adr.link=link
end
local list={}
for t=1,#new do
adr=new[t]
link=adr.link
if link~=nil then
if link.address-adr.value==link.min then
list[#list+1]=adr
end
end
end
return list
end
function rage(old,dump)
local list={}
for k,v in pairs(dump) do
local st=bnd(old,v['end'],st)+1
if st then
for t=st-1,1,-1 do
local tmp=old[t]
local adr=tmp.address
if adr<=v['end'] then
if adr>=v.start then
list[#list+1]=tmp
else
break
end
else
st=t
end
end
end
end
return list
end
function lvl(max,len,offmax,dump,fast)
local deep={}
local old=gg.getResults(1)
for i=1,max do
local list=nextlvl(old,len,offmax)
if #dump>0 then
v=rage(list,dump)
deep[#deep+1]=v
fast=fast-#v
if fast<=0 then
return deep
end
end
old=list
if dump==nil or i~=max then
gg.loadResults(old)
end
end
return deep
end
gg.setRanges(32)
data=gg.prompt({"深度","扫描偏移","最大偏移","最大条目"},{1,1000,1000,1})
max=tonumber(data[1])
len=tonumber(data[2])
offmax=tonumber(data[3])
old=gg.getResults(1)
src=gg.getSelectedListItems()
if #src>0 then
for k,v in pairs(src) do
v=v.address
src[k]={start=v-offmax,["end"]=v+offmax}
end
end
out=lvl(max,len,offmax,src,tonumber(data[4]))
for k,v in pairs(out) do
src=src[k].start+offmax
for i,s in pairs(v) do
s.index=k
s.off=s.address-src
print(s)
end
end