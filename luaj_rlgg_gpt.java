
/*
在我的测试中，由于lua分析大量数据(90000)，依旧有较高的耗时(2s)
其中rlgg支持lua加载dex，并执行java代码，因此改用java实现可以避免较高的历遍耗时，这可能有10倍差距。
不过考虑到兼容问题，此分支优先级低，建议自行编写。
*/

import java.util.*;

public class LuaToJava {

    // function bnd(old,value,offmax)
    // local adr=old[value//offmax]
    // while adr and value>adr.address do
    // adr=adr.next
    // end
    // return adr
    // end
    public static Adr bnd(Map<Long, Adr> old, long value, long offmax) {
        Adr adr = old.get(value / offmax);
        while (adr != null && value > adr.address) {
            adr = adr.next;
        }
        return adr;
    }

    // x32=not gg.getTargetInfo().x64
    // function x64(value)
    // if x32 then
    // value=value&0xffffffff
    // end
    // return value
    // end
    public static boolean x32 = !gg.getTargetInfo().x64;
    public static long x64(long value) {
        if (x32) {
            value = value & 0xffffffffL;
        }
        return value;
    }

    // function find(old,value,len)
    // local eqz=bnd(old,value,len)
    // if eqz then
    // local off=eqz.address-value
    // if off<len then
    // local min=eqz.min
    // if not min or off<min then
    // eqz.min=off
    // end
    // return eqz
    // end
    // end
    // end
    public static Adr find(Map<Long, Adr> old, long value, long len) {
        Adr eqz = bnd(old, value, len);
        if (eqz != null) {
            long off = eqz.address - value;
            if (off < len) {
                Long min = eqz.min;
                if (min == null || off < min) {
                    eqz.min = off;
                }
                return eqz;
            }
        }
        return null;
    }

    // function nextlvl(old,offmax,src,deep)
    // gg.internal3(offmax)
    // local link
    // local new=gg.getResults(100000)
    // for t,adr in pairs(new) do
    // local value=x64(adr.value)
    // adr.value=value
    // link=find(old,value,offmax)
    // adr.link=link
    // end
    // local list={}
    // top=1
    // ms=src[1]
    // for t,adr in pairs(new) do
    // link=adr.link
    // if link and link.address-adr.value==link.min then
    // if last then
    // last.next=adr
    // end
    // while ms and adr.address>=ms['end'] do
    // top=top+1
    // ms=src[top]
    // end
    // if ms and adr.address>=ms.start then
    // deep[#deep+1]=adr
    // adr.index=top
    // end
    // t=adr.address
    // last=adr
    // lf=t//offmax
    // if lf==rf then
    // list[t]=adr
    // else
    // list[lf]=adr
    // end
    // rf=lf
    // end
    // end
    // return list
    // end
    public static Map<Long, Adr> nextlvl(Map<Long, Adr> old, long offmax, List<Ms> src, List<Adr> deep) {
        gg.internal3(offmax);
        Adr link;
        List<Adr> new = gg.getResults(100000);
        for (Adr adr : new) {
            long value = x64(adr.value);
            adr.value = value;
            link = find(old, value, offmax);
            adr.link = link;
        }
        Map<Long, Adr> list = new HashMap<>();
        int top = 1;
        Ms ms = src.get(1);
        Adr last = null;
        long lf = 0;
        long rf = 0;
        for (Adr adr : new) {
            link = adr.link;
            if (link != null && link.address - adr.value == link.min) {
                if (last != null) {
                    last.next = adr;
                }
                while (ms != null && adr.address >= ms.end) {
                    top++;
                    ms = src.get(top);
                }
                if (ms != null && adr.address >= ms.start) {
                    deep.add(adr);
                    adr.index = top;
                }
                long t = adr.address;
                last = adr;
                lf = t / offmax;
                if (lf == rf) {
                    list.put(t, adr);
                } else {
                    list.put(lf, adr);
                }
                rf = lf;
            }
        }
        return list;
    }

    // function lvl(max,offmax,dump,fast)
    // local deep={}
    // local old=gg.getResults(1)[1]
    // old={[old.address//offmax]=old}
    // for i=1,max do
    // local list=nextlvl(old,offmax,dump,deep)
    // if fast-#deep<=0 then
    // return deep
    // end
    // old=list
    // if #dump==0 or i~=max then
    // new={}
    // for k,v in pairs(old) do
    // new[#new+1]=v
    // end
    // gg.loadResults(new)
    // end
    // end
    // return deep
    // end
    public static List<Adr> lvl(int max, long offmax, List<Ms> dump, int fast) {
        List<Adr> deep = new ArrayList<>();
        Adr old = gg.getResults(1).get(1);
        Map<Long, Adr> map = new HashMap<>();
        map.put(old.address / offmax, old);
        for (int i = 1; i <= max; i++) {
            Map<Long, Adr> list = nextlvl(map, offmax, dump, deep);
            if (fast - deep.size() <= 0) {
                return deep;
            }
            map = list;
            if (dump.isEmpty() || i != max) {
                List<Adr> new = new ArrayList<>();
                for (Adr v : map.values()) {
                    new.add(v);
                }
                gg.loadResults(new);
            }
        }
        return deep;
    }

    // Define the classes for Adr, Ms and gg
    public static class Adr {
        public long address;
        public long value;
        public Adr next;
        public Adr link;
        public Long min;
        public int index;
        // Add constructors, getters and setters as needed
    }

    public static class Ms {
        public long start;
        public long end;
        // Add constructors, getters and setters as needed
    }

    public static class gg {
        public static boolean getTargetInfo() {
            // Implement this method as needed
            return false;
        }

        public static void internal3(long offmax) {
            // Implement this method as needed
        }

        public static List<Adr> getResults(int n) {
            // Implement this method as needed
            return null;
        }

        public static void loadResults(List<Adr> list) {
            // Implement this method as needed
        }
    }
}