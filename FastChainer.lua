function bnd(old,value,offmax)
local adr=old[value//offmax]
while adr and value>adr.address do
adr=adr.next
end
return adr
end
x32=not gg.getTargetInfo().x64
function x64(value)
if x32 then
value=value&0xffffffff
end
return value
end
function find(old,value,len)
local eqz=bnd(old,value,len)
if eqz then
local off=eqz.address-value
if off<len then
local min=eqz.min
if min==nil or off<min then
eqz.min=off
end
return eqz
end
end
end
function nextlvl(old,len,offmax,src,deep)
gg.internal3(len)
local link
local new=gg.getResults(100000)
for t,adr in pairs(new) do
local value=x64(adr.value)
adr.value=value
link=find(old,value,offmax)
adr.link=link
end
local list={}
top=1
ms=src[1]
for t,adr in pairs(new) do
link=adr.link
if link and link.address-adr.value==link.min then
if last then
last.next=adr
end
while ms and adr.address>=ms['end'] do
top=top+1
ms=src[top]
end
if ms and adr.address>=ms.start then
deep[#deep+1]=adr
adr.index=top
end
t=adr.address
last=adr
lf=t//offmax
if lf==rf then
list[t]=adr
else
list[lf]=adr
end
rf=lf
end
end
return list
end
function lvl(max,len,offmax,dump,fast)
local deep={}
local old=gg.getResults(1)[1]
old={[old.address//offmax]=old}
for i=1,max do
local list=nextlvl(old,len,offmax,dump,deep)
if fast-#deep<=0 then
return deep
end
old=list
if #dump==0 or i~=max then
new={}
for k,v in pairs(old) do
new[#new+1]=v
end
gg.loadResults(new)
end
end
return deep
end
function show(src,out,of)
file=io.output(os.time()..".lua")
file:write("test={")
for k,s in pairs(out) do
local next="{"
obj=src[s.index]
if of==0 then
str=obj.state..">"..obj.internalName:match("[^/]+$")..">"
else
str=s.index..">"
end
str=str..s.address.."="
adr=s.address-(obj.start+of)
if of==0 then
next=next.."[0]="..obj.index..","
end
next=next..adr
while s.link do
s=s.link
next=next..","..s.min
end
next=next.."}"
print(str..next)
file:write(next..",")
end
file:write("}\ndofile(gg.getFile():match('(.*/)')..'goto.lua')")
file:close()
end
data=gg.prompt({"寻找基址","深度","扫描偏移","最大偏移","最大条目"},{true,1,1000,1000,10},{"checkbox"})
max=tonumber(data[2])
len=tonumber(data[3])
offmax=tonumber(data[4])
old=gg.getResults(1)
src=gg.getSelectedListItems()
if #src>0 then
for k,v in pairs(src) do
v=v.address
src[k]={start=v-offmax,["end"]=v+offmax}
end
of=offmax
else
if data[1] then
of=0
src={}
xl={["Cd"]=8,["Cb"]=16,["Xa"]=16384}
tag=xl[gg.getValuesRange(old)[1]]
r=tag or gg.getRanges()
for k,v in pairs(xl) do
if r&v~=0 then
xl[k]=0
end
end
for k,v in pairs(gg.getRangesList("^/da*.s")) do
if xl[v.state]==0 and v.type:sub(2,2)=="w" then
v.index=k
src[#src+1]=v
end
end
end
end
if tag then
adr=old.address
for k,v in pairs(xl) do
out={}
if v.start<=adr and v['end']>=adr then
out[#list+1]=v
end
end
else
out=lvl(max,len,offmax,src,tonumber(data[5]))
end
if of~=0 or data[1] then
show(src,out,of)
end