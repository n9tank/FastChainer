--[[
[1]=link
[2]=next
[3]=len
[4]=min
[5]=index
]]--
local x32=not gg.getTargetInfo().x64
function nextlvl(old,offmax,src,deep)
gg.internal3(offmax)
local new=gg.getResults(100000)
for t,adr in pairs(new) do
local value=adr.value
if x32 then
value=value&0xffffffff
adr.value=value
end
local ed=value//offmax
local link=old[ed]
if link then
if value>link.address then
ed=link[3]
local st,ed=ed&0xffffffff,ed>>32
if st>ed or value>old[ed].address then
link=link[2]
else
local md,to
while st<=ed do
md=(st+ed)>>1
link=old[md]
to=link.address
if value<to then
ed=md-1
else
if value>to then
st=md+1
else
break
end
end
end
if value>to then
link=old[md+1]
end
end
end
else
link=old[ed+1]
end
if link then
local off=link.address-value
if off>=0 and  off<offmax then
local min=link[4]
if not min or off<=min then
adr[1]=link
link[4]=off
end
end
end
end
local list,top,ed,lt={},1,0,0
local lf,rf,st,last,rt
for k,adr in pairs(new) do
local link=adr[1]
if link and link.address-adr.value==link[4] then
local t=adr.address
while ed and t>ed do
top=top+1
ed=src[top]
if ed then
st=ed.start
ed=ed["end"]
end
end
if ed and t>=st then
deep[#deep+1]=adr
adr[5]=top
else
lf=t//offmax
if lf==rf then
lt=lt+1
list[lt]=adr
else
if last then
last[3]=lt<<32|rt
last[2]=adr
end
rt=lt+1
last=adr
list[lf]=adr
end
rf=lf
end
end
end
if last then
last[3]=lt<<32|rt
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
local new={}
for k,v in pairs(old) do
new[#new+1]=v
end
gg.loadResults(new)
end
end
return deep
end
function show(src,out,of)
local file=io.output(os.time()..".lua")
file:write("t={")
local link={}
for k,s in pairs(out) do
local obj=src[s[5]]
local next
if of==0 then
next="{i='"..obj.state..obj.internalName:match("lib([^/]+).so[^o]*$").."',"
else
next="{"
end
link[1]=s.address-(obj.start+of)
local len=1
local v=s[1]
while v do
len=len+1
link[len]=v[4]
v=v[1]
end
next=next..table.concat(link,",",1,len).."}"
print(string.format("%d>%x=%s",s[5],s.address,next))
file:write(next..",\n")
end
file:write("}dofile('goto.lua')")
file:close()
end
function check(deep)
local list,c,eq=deep,2
while c>1 do
c=0
local next=gg.getValues(list)
list={}
for k,s in pairs(deep) do
local v
if eq then
v=s[2]
else
v=s
end
if v and v[1] then
local adr,gt
if eq then
adr=v
else
adr=k
end
gt=next[adr]
if gt then
if v.value==gt.value then
c=c+1
local to=v[1]
s[2]=to
list[to]=to
else
deep[k]=nil
end
else
s[2]=false
end
end
end
eq=0
end
end
local data=gg.prompt({"寻找基址","深度","最大偏移","最大条目"},{true,1,1000,10},{"checkbox"})
local max=tonumber(data[2])
local offmax=tonumber(data[3])
local old=gg.getResults(1)
local src=gg.getSelectedListItems()
local xl,of,tag,out
if #src>0 then
for k,v in pairs(src) do
local v=v.address
src[k]={start=v-offmax,["end"]=v+offmax}
end
of=offmax
else
if data[1] then
of=0
src={}
xl={["Cd"]=8,["Cb"]=16,["Xa"]=16384}
tag=xl[gg.getValuesRange(old)[1]]
local r=tag or gg.getRanges()
for k,v in pairs(xl) do
if r&v~=0 then
xl[k]=0
end
end
for k,v in pairs(gg.getRangesList("^/da*.s")) do
if xl[v.state]==0 and v.type:sub(2,2)=="w" then
v[5]=k
src[#src+1]=v
end
end
end
end
if tag then
local adr=old.address
out={}
for k,v in pairs(xl) do
if v.start<=adr and v['end']>=adr then
out[#out+1]=v
end
end
else
out=lvl(max,offmax,src,tonumber(data[4]))
check(out)
end
if of~=0 or data[1] then
show(src,out,of)
end