package com.lawsiji.txtcheck.common;

import org.nlpcn.commons.lang.tire.GetWord;
import org.nlpcn.commons.lang.tire.domain.Forest;
import org.nlpcn.commons.lang.tire.library.Library;

import java.io.BufferedReader;
import java.io.StringReader;
import java.util.*;

public class AnsjTools {
    /**
     * @description 分词函数
     * @param dic   极限词字典
     * @return
     */
    public static String[] splitWord(String dic,String content){
        /**
         * 分词部分
         * 词典的构造.一行一个词后面是参数.可以从文件读取.可以是read流.
         */
        String resultStr=new String();
        Forest forest = null;
        try {
            forest = Library.makeForest(new BufferedReader(new StringReader(dic)));
        } catch (Exception e) {
            e.printStackTrace();
        }

        GetWord udg = forest.getWord(content);

        String temp = null;
        while ((temp = udg.getFrontWords()) != null) {
            resultStr+=temp+",";
        }
        String[] result=resultStr.split(",");

        //去除重复的元素
        Set set = new TreeSet();
        for (int i = 0; i < result.length; i++) {
            set.add(result[i]);
        }
        result = (String[]) set.toArray(new String[0]);

        return result;
    }



}//函数结束
