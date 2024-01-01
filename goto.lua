list=gg.getRangesList("^/da*.s")
xl={Cd={},Cb={},Xa={}}
for k,v in pairs(list) do
put=xl[v.state]
if put and v.type:sub(2,2)=="w" then
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
local last=tree[adr]
if not last then
last={}
tree[adr]=last
end
for k,v in ipairs(list) do
next=last[v]
if next and next.adr then
adr=next.adr
else
next={}
last[v]=next
adr=gg.getValues({{address=x64(adr)+v,flags=x32}})[1]
next.adr=adr
end
adr=adr.value
last=next
end
return next
end
--[[
使用树优化你的代码，多个同路径避免重复获取。
node=treeCache(0,{0,1,2})
print(node.adr)
重建树（清空自己和所有子目标）
node.adr=nil
node=treeCache(0,{0,1,2})
]]--
heep={}
function getheep(adr,list)
local un,next
for i,t in ipairs(list) do
adr=x64(adr)+t
next=heep[adr]
if not next or un or next.un then
adr=gg.getValues({{address=adr,flags=x32}})[1]
if next.un then
un=true
adr.un=true
end
heep[adr]=adr
next=adr
end
adr=adr.value
end
return next
end
--[[
该函数性能比tree更优秀，但是这存在一些释放的问题
node=getheep(0,{0,1,2})
重新获取
node.un=true
node=getheep(0,{0,1,2})
node.un=false
]]--
for k,v in pairs(t) do
print(string.format("%x",getheep(v,xl[v[-1]][v[0]]).address))
end