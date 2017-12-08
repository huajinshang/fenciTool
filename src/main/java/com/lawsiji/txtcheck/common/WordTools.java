package com.lawsiji.txtcheck.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class WordTools {

    /**
     * @description     将检索的数据拼接成所需要的字符串
     * @param word      数据库中检索出的极限词（HashMap）
     * @return
     */
    public static String SqlWordStr(List<HashMap> word){
        String dic = new String();
        for (int i = 0; i < word.size(); i++) {
            Map map = word.get(i);
            Set<String> get = map.keySet();
            for (String test : get) {
                if (test.equals("WORD")) {
                    dic += map.get(test) + "\n";
                }
            }
        }
        return dic;
    }

}
