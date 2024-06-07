local x32=false
function check(src)
local list,new,go=src,{}
while #list>0 do
local next=gg.getValues(list)
for k,v in pairs(src) do
go=v.go or v
if next[v.go or k].value~=go.value then
src[k]=nil
else
go=go.link
if go then
v.go=go
new[go]=go
end
end
end
list=new
end
end
function nextlvl(old,hash,offmax,src,deep)
gg.internal3(offmax)
local new=gg.getResults(100000)
for t,adr in pairs(new) do
local value=adr.value
if x32 then
value=value&0xffffffff
adr.value=value
end
local index=value//offmax
local ed=hash[index]
if not ed then
index=hash[index+1]
if index then
link=old[index&0xffffffff]
end
else
local st=ed&0xffffffff
ed=(ed>>32)
local md,next
while st<=ed do
md=(st+ed)>>1
link=old[md]
next=link.address
if next<value then
st=md+1
else
if next>value then
ed=md-1
else
break
end
end
end
if next<value then
link=old[md+1]
end
end
if link then
local off=link.address-value
if off>=0 and  off<offmax then
local min=link.min
if not min or off<=min then
adr.link=link
link.min=off
end
end
end
end
local list,hashoff,top,ed,lt,st={},{},0,0,0
local lf,rf,rt
for k,adr in pairs(new) do
local link=adr.link
if link and link.address-adr.value==link.min then
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
adr.index=top
else
lf=t//offmax
lt=lt+1
list[lt]=adr
if lf~=rf then
hashoff[(rf or lf)]=lt<<32|(rt or lt)
rf=lf
rt=lt
else
if k==#new then
hashoff[rf]=lt<<32|rt
end
end
end
end
end
return list,hashoff
end
function lvl(max,offmax,dump,fast)
local deep={}
local old=gg.getResults(1)
local hash={[old[1].address//offmax]=1<<32|1}
for i=1,max do
old,hash=nextlvl(old,hash,offmax,dump,deep)
if fast-#deep<=0 then
return deep
end
if #dump==0 or i~=max then
gg.loadResults(old)
end
end
return deep
end
function show(src,out,of)
local file=io.output(os.time()..".lua")
file:write("t={")
local link={}
for k,s in pairs(out) do
local obj=src[s.index]
local next
if of==0 then
next="{i='"..obj.state..obj.internalName:match("lib([^/]+).so[^o]*$").."',"
else
next="{"
end
link.link=s.address-(obj.start+of)
local len=1
local v=s.link
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
else
if data[1] then
src={}
xl={["Cd"]=8,["Cb"]=16}
tag=xl[gg.getValuesRange(old)[1]]
local r=tag or gg.getRanges()
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
if #src>0 then
show(src,out,data[1] and 0 or offmax)
end