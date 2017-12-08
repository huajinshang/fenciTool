package com.lawsiji.txtcheck.dao;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface WordDao {
    public List<HashMap> selectByPid(int pid);

    public String selectByWord(Map map);

    public int insertWord(List list);

    public int insertWordOne(Map map);

    public int deleteWordByPid(int wordPid);
}
