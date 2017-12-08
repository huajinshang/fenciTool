package com.lawsiji.txtcheck.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public interface WordDBService {
    public List<HashMap> getWordByPid(int pid);

    public String selectByWord(Map map);

    public int insertWord(List list);

    public int insertWordOne(Map map);

    public int deleteWordByPid(int wordPid);
}
