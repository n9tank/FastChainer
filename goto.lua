list=gg.getRangesList("^/da*.s")
xl={Cd={},Cb={},Xa={}}
for k,v in pairs(list) do
put=xl[v.state]
if put then
put[v.internalName:match("[^/]+$")]=v.start
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
for k,v in ipairs(list) do
next=last[v]
if next then
adr=next.adr
else
next={}
last[v]=next
adr=gg.getValues({{address=x64(adr.value)+v,flags=x32}})[1]
next.adr=adr
end
last=next
end
return adr
end
heep={}
function adrCache(adr)
local next=heep[adr]
if not next then
next=gg.getValues({{address=x64(adr),flags=x32}})[1]
heep[adr]=next
end
return next
end
function getAdr(list,adr)
adr={value=adr}
for i,t in ipairs(list) do
adr=adrCache(adr.value+t)
end
return adr
end
for k,v in pairs(t) do
print(string.format("%x",getAdr(v,xl[v[-1]][v[0]]).address))
end