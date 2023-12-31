list=gg.getRangesList("^/da*.s")
xl={Cd={},Cb={},Xa={}}
for k,v in pairs(list) do
put=xl[v.state]
if put then
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
if k>0 then
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
adr={value=adr}
for i,t in pairs(list) do
if i>0 then
adr=adrCache(adr.value+t)
end
end
return adr
end
for k,v in pairs(test) do
print(getAdr(v,xl[v[-1]][v[0]]).address)
end