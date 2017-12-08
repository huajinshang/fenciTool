<%--suppress ALL --%>
<%--
  Created by IntelliJ IDEA.
  User: admin
  Date: 2017/11/7
  Time: 16:04
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>分词功能</title>
    <meta name="keywords" content="简单的中文分词"/>
    <meta name="description" content="简单的中文分词"/>
    <script src="static/js/jquery-3.2.1.js"></script>
    <script src="static/js/tire.js"></script>
    <link rel="stylesheet" href="static/css/index.css">
</head>
<body>
<header>
    <div class="header">
        <div class="header-title">
            欢迎来到大状网络禁用词查询系统
        </div>
    </div>
</header>
<main>
    <div class="main-box">
        <div class="menu-tab">
            <div class="tab-item active">查询极限词</div>
            <div class="tab-item">添加极限词</div>
        </div>
        <ul class="content">
            <div class="selectbtn">
                <select name="" id="select-box">
                    <option value="1" selected>通用</option>
                    <option value="2">食品</option>
                    <option value="3">服装</option>
                    <option value="4">药物</option>
                </select>
            </div>
            <li class="active">
                <div class="selectbox">
                    <div class="selectcon">
                        <textarea name="" id="input" cols="50" rows="20" placeholder="请输入要筛查的文字内容"></textarea>
                        <input type="button" value="极限词查询" class="transform">
                        <div id="result">此处显示文本中的极限词</div>
                    </div>
                </div>
            </li>
            <li>
                <div class="addwordbox">
                    <div class="btnadd">
                        <textarea name="" id="addcon" cols="30" rows="10" class="addword"
                                  placeholder="请输入你要添加的极限词"></textarea>
                        <div class="btns">
                            <button class="add" style="">添加</button>
                            <button class="uploadbtn">上传文件</button>
                            <button class="downloadbtn">下载文件</button>
                        </div>
                    </div>
                    <div class="fileadd">
                        <div class="upload">
                            <form method="post" enctype="multipart/form-data" id="upload">
                                <input type="file" name="file" class="uploadfile" id="file">
                                <br>
                                <p><input type="checkbox" class="limitStatus" name="limitKinds" value="1" checked>通用
                                </p>
                                <p><input type="checkbox" class="limitStatus" name="limitKinds" value="2">食品</p>
                                <p><input type="checkbox" class="limitStatus" name="limitKinds" value="3">服装</p>
                                <p><input type="checkbox" class="limitStatus" name="limitKinds" value="4">药物</p>
                                <p><input name="flag" type="radio" value="true" checked/>追加上传&nbsp&nbsp&nbsp&nbsp<input
                                        name="flag" type="radio" value="false"/>覆盖上传</p>
                                <p><input type="button" value="上传" class="addbtn"></p>
                            </form>
                        </div>
                        <div class="download">
                            <form method="post" enctype="multipart/form-data" id="download">
                                <h4>请选择要下载的文件类型</h4>
                                <p>
                                    <input type="radio" name="fileType" class="fileType" checked value=".txt">.txt
                                    &nbsp&nbsp&nbsp&nbsp<input type="radio" name="fileType" class="fileType"
                                                               value=".xls">.xls
                                    &nbsp&nbsp&nbsp&nbsp<input type="radio" name="fileType" class="fileType"
                                                               value=".xlsx">.xlsx
                                </p>
                                <h4>请选择要下载的文件</h4>
                                <p><a href="" class="downStatus">通用极限词</a></p>
                                <p><a href="" class="downStatus">药物极限词</a></p>
                                <p><a href="" class="downStatus">食品极限词</a></p>
                                <p><a href="" class="downStatus">服装极限词</a></p>
                            </form>
                        </div>
                    </div>
                </div>
            </li>
        </ul>
    </div>
</main>

<%--右键自创的菜单--%>
<div id="menu">
    <div class="menu-item">添加极限词</div>
</div>
</body>
</html>

<script>    //获取相关的dom元素

    //获取呈现文字的文本域
    var forbid = document.querySelector("#result"); //输出内容
    var input = document.querySelector("#input");   //输入内容
    //获取中间的点击按钮
    var button = document.querySelector(".transform");

    //获取添加极限词区域的相关dom元素
    var addword = document.querySelector("#addcon");
    var addbtn = document.querySelector(".add");
    </script>

    <script>  //此js用来写选项卡
    $(".tab-item").each(function (i, v) {
        $(v).click(function () {
            $(this).addClass("active").siblings().removeClass("active");
            $(".content>li").eq(i).addClass("active").siblings().removeClass("active");
        })
    })
</script>

<script>   //极限词查询相关

    //极限词检测点击事件
    button.onclick = function () {
        // 接收待分词的字符串
        var selectWordContent = input.value;
        var categoryId = $("#select-box").val();

        if (selectWordContent.length > 0) {
            var result = getAnsjResult(categoryId, selectWordContent);
            console.log(result);
            var str = changeRed(selectWordContent, result);
            forbid.innerHTML = str;

            rightText();

        } else {
            alert("请输入要检索内容");
        }
    };

    //封装ajax获取检测到的极限词
    function getAnsjResult(categoryId, selectWordContent) {
        var result = new Array();
        $.ajax({
            url: '/getLimitWords',
            data: {'categoryId': categoryId, 'selectWordContent': selectWordContent},
            async: false,
            success: function (e) {
                for (var i = 0; i < e.length; i++) {
                    result.push(e[i]);
                }
            },
            error: function (e) {
                alert("您访问的服务器已上天");
            }
        })
        return result;
    }

    //此函数用来处理极限词包装变红输出
    function changeRed(words, result) {
        if (result.length == 1) {
            return words.replace(new RegExp(result, 'g'), "<span>" + result + "</span>");
        } else {
            return findKey(result, words)
        }
    }

    //替换标签，往关键字前后加上标签
    function findKey(key, words) {
        var arr = null;
        var regStr = null;
        var Reg = null;
        var content = words;
        regStr = createExp(key);
        content = content.replace(/<\/?[^>]*>/g, '');
        Reg = new RegExp(regStr, "g");
        console.log(Reg);//        /如：(前端|过来)/g
        var str = content.replace(Reg, "<span>$1</span>");
        return str;
    }

    //创建正则
    function createExp(strArr) {
        //此处逆序排列查询结果集，旨在正确匹配替换文字
        //例如：“最” “最好” “最佳”
        var strArr = strArr.reverse();
        var str = "";
        for (var i = 0; i < strArr.length; i++) {
            if (i != strArr.length - 1) {
                str = str + strArr[i] + "|";
            }
            else {
                str = str + strArr[i];
            }
        }
        return "(" + str + ")";
    }

</script>

<script>    //添加极限词有关

    //添加极限词按钮触发
    addbtn.onclick = function () {
        var addtext = removeLeftSpace(addword.value);

        //调用添加极限词函数
        addLimit(addtext);
    };

    //去除左空格
    function removeLeftSpace(str) {
        return str.replace(/^\s*/, '');
    }

    //封装极限词添加函数
    function addLimit(addtext) {
        var categoryId = $("#select-box").val();
        if (addtext == "") {
            alert("不能添加空内容");
            addword.value = null;
        } else {
            var insertWordContent = addtext.replace(/(\n)|(\s)|(\t)|(，)/g, ',') + ",";
            console.log(insertWordContent);

            //调用插入
            insertWord(categoryId, insertWordContent);
            addword.value = "";
        }

    }

    //封装插入极限词的ajax请求
    function insertWord(categoryId, insertWordContent) {
        var num;
        $.ajax({
            url: "/writeLimitWords",
            data: {'categoryId': categoryId, 'insertWordContent': insertWordContent},
            type:"post",
            async: false,
            success: function (e) {
                console.log("返回结果" + e);
                if (e == "ok") {
                    alert("极限词添加成功");
                } else {
                    alert("极限词添加失败");
                }
            },
            error: function (e) {
                alert("您访问的服务器已上天");
            }
        })
        return num;
    }

    //右键快速添加极限词
    function rightText() {
        //禁用浏览器鼠标右键菜单
        document.oncontextmenu = function (ev) {
            return false;    //屏蔽右键菜单
        };

        var txt;
        //用来获取左键选中的文字
        $('#input').mouseup(function () {
            onMouseDownFlag = false;
            mouseDownAndUpTimer = setTimeout(function () {
                txt = window.getSelection().toString();
                console.log("左键字:" + txt);
                onMouseDownFlag = true;
            }, 200);
        });
        $('#result').mouseup(function () {
            onMouseDownFlag = false;
            mouseDownAndUpTimer = setTimeout(function () {
                txt = window.getSelection().toString();
                console.log("左键字:" + txt);
                onMouseDownFlag = true;
            }, 200);
        });

        document.onmousedown = function (e) {
            onMouseDownFlag = false;
            mouseDownAndUpTimer = setTimeout(function () {
                // OnMouseDown Code in here
                // e.button  查询是哪个键    0——左键   2——右键 1——滑轮
                var button = e.button;
                if (button == 2) {
                    menu.style.left = e.clientX + "px";
                    menu.style.top = e.clientY + "px";
                    menu.style.display = "block";
                } else {
                    menu.style.display = "none";
                }
                onMouseDownFlag = true;
            }, 200);
        };

        $("#menu").on("click", ".menu-item", function () {
            console.log(222);
            if (txt == '') {
                alert("不能添加空内容");
            } else {
                var categoryId = $("#select-box").val();
                var inserNum = insertWord(categoryId, txt);
            }
        });
    }

</script>

<script>

    //上传文件的ajax
    $(".addbtn").click(function () {
        var flag = $("input[name='flag']:checked").val();
        var fileInfo = $("#file")[0].files[0];
        console.log(fileInfo);
        var allowFileType = new Array("xls", "xlsx", "txt");    //定义上传文件的类型
        var maxSize = 1024 * 1024 * 10;   //定义上传文件的大小
        var isUpload = true;    //定义标志是否可以提交上传
        var errNum = 0;         //定义一个错误参数：1代表大小超出 2代表类型不支持

        if (!fileInfo) {
            alert("请选择上传文件");
            return false;
        } else {
            var fileName = fileInfo.name;
            var file_typeName = fileName.substring(fileName.lastIndexOf(".") + 1, fileName.length);      //截取文件的后缀名
            if (fileInfo.size > maxSize) {
                isUpload = false;
                errNum = 1;
            } else {
                if ($.inArray(file_typeName, allowFileType) > -1) {
                    isUpload = true;
                } else {
                    isUpload = false;
                    errNum = 2;
                }
            }
        }

        if (!isUpload) {
            if (errNum == 1) {
                var size = maxSize / 1024 / 1024;
                alert("上传的文件必须为小于" + size + "M的图片！");
            } else if (errNum = 2) {
                alert("上传的" + file_typeName + "文件类型不支持！只支持" + allowFileType.toString() + "格式");
            }
        } else {
            var check = [];
            $(".limitStatus:checked").each(function (i, v) {
                check.push($(v).val());
            });
            var formData = new FormData();
            formData.append("fileInfo", fileInfo);
            formData.append("limitStatus", check);
            formData.append("flag", flag);

            if (file_typeName == "xls" || file_typeName == "xlsx") {
                formData.append("fileType","excel");
            } else if (file_typeName == "txt") {
                formData.append("fileType","txt");
            }
            uploadFile(formData);
        }
    })

    function uploadFile(formData) {
        $.ajax({
            url: "/uploadFile",
            type: "POST",
            data: formData,
            processData: false,       //必不可缺
            contentType: false,       //必不可缺
            success: function (e) {
                if(e=="ok"){
                    alert("文件上传成功");
                }else if(e=="err"){
                    alert("文件上传失败");
                }else{
                    alert("未知错误上传失败");
                }
            },
            error: function (e) {
                alert("您访问的服务器以上天！")
            }
        })
    }


    //按钮区域的相关js
    $(".uploadbtn").click(function () {
        $(".upload").show().siblings("div").hide();
    });
    $(".downloadbtn").click(function () {
        var arr = ["common", "medicines", "foods", "clothes"];
        $(".download").show().siblings("div").hide();
        $(".downStatus").each(function (i, v) {
            $(v).click(function () {
                var fileDownType = $("input[name='fileType']:checked").val();
                if (fileDownType == ".txt") {
                    $(v).attr('href', "/downloadTxt?checkStatus=" + arr[i]);
                } else if (fileDownType == ".xls" || fileDownType == ".xlsx") {
                    $(v).attr('href', "/downloadExcel?checkStatus=" + arr[i] + "&fileDownType=" + fileDownType);
                }
            })
        })
    });


</script>