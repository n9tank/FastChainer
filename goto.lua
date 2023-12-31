list=gg.getRangesList("^/da*.s")
xl={Cd={},Cb={},Xa={}}
for k,v in mrg do
put=xl[v.state]
if put and then
put[v.internalName:match("[^/]+^")]=v.start
end
end
tree={}
x32=gg.getTargetInfo().x64
if x32 then
x32=32
else
x32=4
end
function x64(value)
if x32==4 then
value=value&0xffffffff
end
return value
end
function treeCache(adr,list)
local next
local adr={value=adr}
local last=tree
for k,v in pairs(list) do
next=last[v]
if next==nil then
next={}
last[v]=next
adr=gg.getValues({{address=x64(adr.value)+v,flags=x32}})[1]
next.adr=adr
else
adr=next.adr
end
last=next
end 
return adr
end
heep={}
function adrCache(adr)
local next=heep[adr]
if next==nil then
next=gg.getValues({{address=x64(adr),flags=x32}})[1]
heep[adr]=next
end
return next
end
function getAdr(list,adr)
if not adr then
adr=mrg[list[-1]][list[0]]
end
print(adr)
adr={value=adr}
end
for i,t in pairs(list) do
if i>0 then
adr=adrCache(adr.value+t)
end
end
return adr
end
for k,v in pairs(test) do
print(getAdr(v).address)
end