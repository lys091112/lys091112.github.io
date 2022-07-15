---
title: "Guava常用工具类"
date: 2022-07-15T15:52:37+08:00
draft: true
top: true
---

TODO 待整理
```java
List<Integer> list2 = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

        List<List<Integer>> sublist = Lists.partition(list2, 2);

        System.out.println(sublist);

        int signum = 1 | ((10 ^ 2) >> (Integer.SIZE - 1));
        System.out.println(signum);
        signum = 1 | ((10 ^ -2) >> (Integer.SIZE - 1));
        System.out.println(signum);

        String j = Joiner.on("->").join(list2);
        System.out.println(j);

        Iterable<String> r = Splitter.on("->").split(j);
        System.out.println(r);

        // BiMap - 双向Map : 根据value查找对应的key
        HashBiMap<String, String> biMap = HashBiMap.create();
        biMap.put("二维码", "100");
        biMap.put("身份证", "400");
        biMap.put("替换测试", "900");
        biMap.forcePut("替换测试", "1000");//强制更新替换
        //使用key获取value
        System.out.println(biMap.get("身份证"));

        BiMap<String, String> inverse = biMap.inverse();
        //使用value获取key
        System.out.println(inverse.get("300"));

        Multimap<String, String> multimap = ArrayListMultimap.create();
        multimap.put("类型", "二维码");
        multimap.put("类型", "身份证");
        multimap.put("类型", "卡");
        multimap.put("人", "小王");
        multimap.put("人", "小刘");
        System.out.println(multimap);

        RangeMap<Integer, String> rangeMap = TreeRangeMap.create();
        //  0<= 范围   <100
        rangeMap.put(Range.closedOpen(0, 100), "没有优惠");
        //  100<= 范围   <500
        rangeMap.put(Range.closedOpen(100, 500), "优惠70");
        //  500<= 范围   <=1000
        rangeMap.put(Range.closed(500, 1000), "8折优惠");
        //  1000<= 范围   <=10000
        rangeMap.put(Range.openClosed(1000, 10000), "5折优惠");
        System.out.println("59:" + rangeMap.get(59));
        System.out.println("100:" + rangeMap.get(100));
        System.out.println("200:" + rangeMap.get(200));

        List<String> list = Lists.newArrayList("100", "2", "900", "313", "41", "544", "15", "25", "二维码", "人脸", "卡");

        //natural 正序排序
        Ordering<Comparable> natural = Ordering.natural();
        list.sort(natural);
        System.out.println(list);
        //反转 反过来
        list.sort(natural.reverse());
        System.out.println(list);

        // 按首字母
        Ordering<String> stringOrdering = new Ordering<String>() {
            @Override
            public int compare(String left, String right) {
                return Collator.getInstance(Locale.CHINA).compare(left, right);
            }
        };
        list.sort(stringOrdering);
        System.out.println(list);

        List<Integer> ints = Lists.newArrayList(121, 12, 13, 433, 3, 444, 7, 5);
        //natural 正序排序
        ints.sort(natural);
        System.out.println(ints);
        //反转 反过来
        ints.sort(natural.reverse());
        System.out.println(ints);
```

