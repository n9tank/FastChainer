function cmpout(eqz)
where=gg.getFile():match(".*/")
cmp=gg.prompt({"文件1","文件2"},{where,where},{"file","file"})
file=io.input(cmp[1])
out=io.output("cmp_"..os.time()..".obj")
num2=-1/0
for line in io.lines(cmp[2]) do
num=tonumber(line:match("[^ ]+"))
while num>num2 do
str=file:read("*l")
if str then
num2=tonumber(str:match("[^ ]+"))
else num2=1/0
end
end
if num==num2 and (str~=line)==eqz then
out:write(line)
out:write("\n")
end
end
file:close()
out:close()
end
sw=gg.choice({"提取","相同截取","提取不同"})
if sw==1 then
list=gg.getSelectedListItems()
list2={}
bit=gg.prompt({"提取量"},{250})[1]
off=(-bit-1)*4+list[1].address
for index=1,bit*2 do
top=off+index*4
list[index]={address=top,flags=4}
list2[index]={address=top,flags=16}
end
list2=gg.getValues(list2)
list=gg.getValues(list)
file=io.output("dump_"..os.time()..".txt")
bit=-bit
for index=1,#list do
file:write(bit.." "..list[index].value.." "..list2[index].value.."\n")
bit=bit+1
end
file:close()
else
cmpout(sw==2)
end