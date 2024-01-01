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
if not min or off<min then
eqz.min=off
end
return eqz
end
end
end
function nextlvl(old,offmax,src,deep)
gg.internal3(offmax)
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
function lvl(max,offmax,dump,fast)
local deep={}
local old=gg.getResults(1)[1]
old={[old.address//offmax]=old}
for i=1,max do
local list=nextlvl(old,offmax,dump,deep)
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
file:write("t={")
local link={}
for k,s in pairs(out) do
obj=src[s.index]
adr=s.address-(obj.start+of)
local next
if of==0 then
next="{[-1]='"..obj.state.."',[0]='"..obj.internalName:match("[^/]+$").."',"
else
next="{"
end
link[1]=adr
len=1
v=s.link
while v do
len=len+1
link[len]=v.min
v=v.link
end
next=next..table.concat(link,",",1,len).."}"
print(string.format("%d>%x=%s",s.index,s.address,next))
file:write(next..",\n")
end
file:write("}dofile('goto.lua')")
file:close()
end
function check(deep)
list=deep
while #list>1 do
next=gg.getValues(list)
list={}
for k,s in pairs(deep) do
v=s.go or s
if v and v.next then
if v==s then
adr=k
else
adr=v
end
gt=next[adr]
if gt then
if v.value==gt.value then
to=v.next
s.go=to
list[to]=to
else
deep[k]=nil
end
else
s.go=false
end
end
end
end
end
--[[
function checkTree(deep)
--tree fast
list=deep
all={}
while #list>1 do
lvl={}
all[#all+1]=lvl
for k,v in pairs(list) do
go=v.next or k
if go then
put=lvl[go]
if not put then
put={}
lvl[go]=put
end
put[#put+1]=v
end
end
list=lvl
end
list={}
for k,v in pairs(all[#all]) do
list[k]=k
end
for k=#all,1,-1 do
v=all[k]
next=gg.getValues(list)
list={}
for i,t in pairs(v) do
if i.value==next[i].value then
for m,n in pairs(t) do
list[n]=n
end
end
end
end
for k,v in pairs(deep) do
if not next[v] then
deep[k]=nil
end
end
end
]]
data=gg.prompt({"寻找基址","深度","最大偏移","最大条目"},{true,1,1000,10},{"checkbox"})
max=tonumber(data[2])
offmax=tonumber(data[3])
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
out=lvl(max,offmax,src,tonumber(data[4]))
check(out)
if of~=0 or data[1] then
show(src,out,of)
end
end