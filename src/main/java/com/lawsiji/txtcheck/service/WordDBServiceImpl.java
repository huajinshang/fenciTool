package com.lawsiji.txtcheck.service;

import com.lawsiji.txtcheck.dao.WordDao;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service("wordDBService")
public class WordDBServiceImpl implements WordDBService {
    @Resource
    private WordDao testDao;

    @Override
    public List<HashMap> getWordByPid(int pid) {
        return testDao.selectByPid(pid);
    }

    @Override
    public String selectByWord(Map map){
        return testDao.selectByWord(map);
    }

    @Override
    public int insertWord(List list) {
        return testDao.insertWord(list);
    }

    @Override
    public int insertWordOne(Map map) {
        return testDao.insertWordOne(map);
    }

    @Override
    public int deleteWordByPid(int wordPid){
        return testDao.deleteWordByPid(wordPid);
    }

}
