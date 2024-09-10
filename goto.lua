list=gg.getRangesList("^/da*.s")
xl={Cd=0,Cb=0,Xa=0}
for k,v in pairs(list) do
k=v.state
if xl[k] and v.type:sub(2,2)=="w" then
xl[k..v.internalName:match("lib([^/]+).so[^o]*$")]=v.start
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
if adr==0 then
return
end
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
local next,last
for k,v in ipairs(list) do
if adr==0 then
return
end
adr=x64(adr)+v
if next then
last=next.tree
if not last then
last={}
next.tree=last
end
end
next=heep[adr]
if not next then
next=gg.getValues({{address=adr,flags=x32}})[1]
if last then
last[adr]=next
end
heep[adr]=next
end
adr=next.value
end
return next
end
function cleartree(tree)
for k,v in pairs(tree) do
heep[k]=nil
tree=v.tree
if tree then
cleartree(tree)
end
end
end
function clearheep(adr)
local next=heep[adr]
if next then
heep[adr]=nil
cleartree(next.tree)
end
end
--[[
通过堆获取，避免重复获取
node=getheep(0,{0,1,2})
清理堆，这可能很耗时
node=clearheep(0)
]]--
function getAdr(adr,list)
local next
for k,v in ipairs(list) do
if adr==0 then
return
end
next=gg.getValues({{address=x64(adr)+v,flags=x32}})
adr=next.value
end
return next
end
--[[
直接获取
adr=getAdr(0,{0,1,2})
]]--
for k,v in pairs(t) do
print(string.format("%x",getheep(v,xl[v.i]).address))
end