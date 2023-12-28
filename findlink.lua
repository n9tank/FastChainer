function bnd(old,value)
st=1
ed=#old
mid=0
local adr
while st<=ed do
md=(st+ed)//2
eqz=old[md]
adr=eqz.address
if math.abs(md-mid)<=1 then
if value>adr and md+1<#old then
eqz=old[md+1]
end
return eqz
end
mid=md
if adr<value then
st=mid+1
else
if adr>value then
ed=mid-1
else
return eqz
end
end
end
end
function find(old,value,len)
eqz=bnd(old,value)
if st<=ed then
off=eqz.address-value
if off>8 and off<len then
min=eqz.min
if min==nil or off<min then
eqz.min=off
end
return eqz
end
end
end
function nextlvl(old,len,offmax)
gg.internal3(len)
new=gg.getResults(100000)
for t=1,#new do
adr=new[t]
value=adr.value
link=find(old,value,offmax)
adr.link=link
end
list={}
for t=1,#new do
adr=new[t]
link=adr.link
if link~=nil then
off=link.address-adr.value
if off==link.min then
list[#list+1]=adr
end
end
end
return list
end
function lvl(max,len,offmax,dump,fast)
old=gg.getResults(1)
for i=1,max do
list=nextlvl(old,len,offmax)
if dump then
for k,v in pairs(dump) do
local adr=v.value
link=bnd(old,adr)
if link and link.address-adr==link.min then
v.off=v.address-src
v.link=link
print(v)
if fast then
return
end
end
end
end
old=list
if dump==nil or i~=max then
gg.loadResults(old)
end
end
end
gg.setRanges(32)
data=gg.prompt({"深度","扫描偏移","最大偏移"},{1,1000,1000})
max=tonumber(data[1])
len=tonumber(data[2])
offmax=tonumber(data[3])
old=gg.getResults(1)
src=gg.getSelectedListItems()[1]
if src then
src=src.address
rff=gg.prompt({"内存区域","最短"},{3,true},{"number","checkbox"})
off=tonumber(rff[1])<<32
gg.clearResults()
gg.searchNumber(src-off.."~"..src+off,32,false,gg.SIGN_EQUAL,src-offmax,src+offmax)
dump=gg.getResults(10000)
end
gg.loadResults(old)
lvl(max,len,offmax,dump,rff[2])