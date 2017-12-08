package com.lawsiji.txtcheck.controller;

import com.lawsiji.txtcheck.common.*;

import com.lawsiji.txtcheck.service.WordDBService;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;
import java.io.*;
import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


@Controller
@RequestMapping("/")
public class TxtCheckController {
    @Resource
    private WordDBService wordDBService;


    //    数据库插入数据
    @ResponseBody
    @RequestMapping(value = "/writeLimitWords", method = RequestMethod.POST)
    public String writeLimitWords(@RequestParam(value = "categoryId", required = true) String categoryId, @RequestParam(value = "insertWordContent", required = true) String insertWordContent) {
        String result = new String();

        List<HashMap> list = new ArrayList<>();
        String[] insertWordArr = insertWordContent.split(",");

        for (int i = 0; i < insertWordArr.length; i++) {

            Map map = new HashMap<>();
            map.put("wordPid", Integer.parseInt(categoryId));
            map.put("word", insertWordArr[i]);

            //数据库排重
            String word = wordDBService.selectByWord(map);
            System.out.println(word);
            if (null != word) {
                continue;
            } else {
                list.add((HashMap) map);
            }
        }

        if (list.isEmpty()) {
            result = "ok";
        } else {
            int insertNum = wordDBService.insertWord(list);
            System.out.println("插入条数" + insertNum);
            if (insertNum > 0) {
                result = "ok";
            } else {
                result = "err";
            }
        }

        return result;

    }

    //    查询数据库
    @ResponseBody
    @RequestMapping(value = "/getLimitWords", method = RequestMethod.GET)
    public String[] getLimitWords(@RequestParam(value = "categoryId", required = true) String categoryId, @RequestParam(value = "selectWordContent", required = true) String selectWordContent) {
        List<HashMap> word = wordDBService.getWordByPid(Integer.parseInt(categoryId));        //从数据库中取数据
        String dic = WordTools.SqlWordStr(word);
        String[] dicResult = AnsjTools.splitWord(dic, selectWordContent);
        return dicResult;
    }

    //    上传文件
    @ResponseBody
    @RequestMapping(value = "/uploadFile", method = RequestMethod.POST)
    public String uploadFile(@RequestParam(value = "fileInfo", required = false) MultipartFile file, HttpServletRequest request, HttpServletResponse response) {
        String result = new String();
        List<String> ls = new ArrayList<>();
        //处理参数
        Boolean flag = Boolean.valueOf(request.getParameter("flag"));
        System.out.println("是否追加" + flag);
        String limitStatus = request.getParameter("limitStatus");
        String[] array = limitStatus.split(",");
        String fileType = request.getParameter("fileType");
        //上传文件的路径
        String path = FileTools.getFileInfo(request, response, file);

        //用来区分excel和txt
        if (fileType.equals("excel")) {
            String s = ExcelPoiTools.read(path);
            String str = s.replaceAll("\\s{1,}", ",");
            ls = java.util.Arrays.asList(str.split(","));
        } else if (fileType.equals("txt")) {
            //读取上传文件里的内容
            ls = FileTools.getFileString(path);
        }
        System.out.println(ls);

        //循环要加入的分类
        for (int j = 0; j < array.length; j++) {
            List<HashMap> list = new ArrayList<>();
            String selectResult = new String();
            if (!flag) {
                wordDBService.deleteWordByPid(Integer.parseInt(array[j]));
            }
            for (int i = 0; i < ls.size(); i++) {
                Map map = new HashMap<>();
                map.put("wordPid", Integer.parseInt(array[j]));
                map.put("word", ls.get(i));

                selectResult = wordDBService.selectByWord(map);
                if (null != selectResult) {
                    continue;
                } else {
                    list.add((HashMap) map);
                }
            }
            if (list.isEmpty()) {
                System.out.println("数据库已包含此极限词");
                result = "ok";
            } else {
                int insertNum = wordDBService.insertWord(list);
                System.out.println("插入条数" + insertNum);
                if (insertNum > 0) {
                    System.out.println(array[j] + "类极限插入成功");
                    result = "ok";
                } else {
                    System.out.println(array[j] + "类极限插入失败");
                    result = "err";
                }
            }
        }

        //直接删除上传的文件
        String deletePath = request.getSession().getServletContext().getRealPath("./") + "upload";
        FileTools.delFolder(deletePath);
        System.out.println("临时文件删除成功");

        return result;

    }


    //    //文件下载
    @ResponseBody
    @RequestMapping(value = "/downloadTxt", method = RequestMethod.GET)
    public ResponseEntity<byte[]> downloadTxt(@RequestParam(value = "checkStatus", required = false) String checkStatus) throws IOException {

        String path = "d:/limitWords/" + checkStatus + ".txt";
        List<String> ls = FileTools.getFileString(path);
        StringBuffer body = new StringBuffer();
        for (String s : ls) {
            body.append(s);
        }

        File file = new File(path);
        String filename = file.getName();

        HttpHeaders headers = new HttpHeaders();
        headers.add("Content-Disposition", "attchement;filename=" + filename);
        HttpStatus statusCode = HttpStatus.OK;
        ResponseEntity entity = new ResponseEntity(body, headers, statusCode);
        return entity;

//        String path1 = "C:\\Users\\win8\\Desktop\\";
//        String Name = "被保险人员清单";
//        String fileType = "xlsx";
//        DownExcelPoiTools.writer(path1, Name, fileType, String.valueOf(body));
//
//        System.out.println(body);

        //jxl实现的
//        File targetFile = new File("C:\\Users\\win8\\Desktop\\work.xlsx");// 将生成的excel表格
//        textJxlTools.write(file,targetFile);
    }


    //    //文件下载
    @ResponseBody
    @RequestMapping(value = "/downloadExcel", method = RequestMethod.GET)
    public void downloadExcel(@RequestParam(value = "checkStatus", required = false) String checkStatus, @RequestParam(value = "fileDownType", required = false) String fileDownType, HttpServletRequest req, HttpServletResponse res) {
        String arr[] = {"common", "medicines", "foods", "clothes"};
        String[] arrcon = new String[4];
        for (int i = 0; i < arr.length; i++) {
            String path = "d:/limitWords/" + arr[i] + ".txt";
            StringBuffer body = new StringBuffer();
            List<String> ls = FileTools.getFileString(path);
            for (String s : ls) {
                body.append(s);
            }
            arrcon[i] = String.valueOf(body);
        }

        String tmpPath = req.getSession().getServletContext().getRealPath("/") + "upload";
        // 如果目录不存在则创建
        File uploadDir = new File(tmpPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        try {
            DownExcelPoiTools.writer(tmpPath, checkStatus, fileDownType, arrcon);
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            // path是指欲下载的文件的路径。
            String downFileInfo = tmpPath + File.separator + "LimitWords" + fileDownType;
            File file = new File(downFileInfo);
            // 取得文件名。
            String filename = file.getName();
            // 以流的形式下载文件。
            InputStream fis = new BufferedInputStream(new FileInputStream(downFileInfo));
            byte[] buffer = new byte[fis.available()];
            fis.read(buffer);
            fis.close();
            // 清空response
            res.reset();
            // 设置response的Header
            res.addHeader("Content-Disposition", "attachment;filename=" + new String(filename.getBytes()));
            res.addHeader("Content-Length", "" + file.length());
            OutputStream toClient = new BufferedOutputStream(res.getOutputStream());
            res.setContentType("application/vnd.ms-excel;charset=UTF-8");
            toClient.write(buffer);
            toClient.flush();
            toClient.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }

        //直接删除上传的文件
        FileTools.delFolder(tmpPath);
        System.out.println("临时文件删除成功");

    }


}//最大函数结束框