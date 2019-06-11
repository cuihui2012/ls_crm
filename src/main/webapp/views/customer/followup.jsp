<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://shiro.apache.org/tags" prefix="shiro" %>    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<script src="js/myutil.js"></script>

<div style="width: 96%;margin-left: 2%; margin-top: 12px">
        <!-- 跟踪记录 -->
        <%--<shiro:hasPermission name="6002">
	        <div>
	                <button class="layui-btn" id="add-follow">新建跟踪记录</button>
	                <!-- <button class="layui-btn" id="delete-follow">删除</button> -->
	        </div>
        </shiro:hasPermission>--%>
        <div class="layui-form" style="width:100%;margin-top: 20px;">
            <blockquote class="layui-elem-quote quoteBox">
                <label style="margin-left: 20px;" class="layui-label">客户：</label>

                <div style="width: 120px;" class="layui-inline" lay-filter="customerId">
                    <select id="customerId" name="customerId" style="width:100%;" lay-verify="required">
                        <option value="">请选择</option>
                    </select>
                </div>

                <button style="margin-left: 20px;" id="searchBtn" class="layui-btn"
                        type="button" lay-filter="userForm">搜索</button>
            </blockquote>
        </div>
        <div id="show-followup">
            <ul class="layui-timeline" id="follow-flow">
            </ul>          
        </div>
</div>
	
<script type="text/javascript">
layui.use(['table','flow'],function(){
	var flow = layui.flow;
	var layer = layui.layer;
	var form = layui.form;
	var table = layui.table;
	var $ = layui.$;
    showCustomer();

	//使用流加载跟踪记录
	flow.load({
	   elem: '#follow-flow' //指定列表容器
	   ,done: function(page, next){ //到达临界点（默认滚动触发），触发下一页
	     var lis = [];
	     //以jQuery的Ajax请求为例，请求下一页数据（注意：page是从2开始返回）
	     $.post('${pageContext.request.contextPath}/followup/list',{'page':page}, function(res){
	       //假设你的列表返回在data集合中
	       layui.each(res.data, function(index, item){
	    	 var str = '<li class="layui-timeline-item"><i class="layui-icon layui-timeline-axis">&#xe63f;</i>';
	         str += '<div class="layui-timeline-content layui-text" >';
	         str += '<h3 class="layui-timeline-title"><a href="javascript:" style="color:black;" id="customerInfo-' + item[0].customer.id + '">' + index + '</a>(共计'+ item.length +'条) </h3><p>';

               layui.each(item, function(index1, item1){
                   var gzTime = '' + item1.time[0] + '年' + item1.time[1] + '月' + item1.time[2] + '日' + '   ' + ((item1.time[3] == undefined || item1.time[3] == 0)?'00':item1.time[3]+'') + ':' +((item1.time[4] == undefined || item1.time[4] == 0)?'00':item1.time[4]+'') + ':' +((item1.time[5] == undefined || item1.time[5] == 0)?'00':item1.time[5]+'');
                   str += '跟踪日期：<a href="javascript:" style="font-size: 16px;" id="followup-' + item1.id + '">' + gzTime + '</a><br/>';
                   str += '跟踪人：<a id="manager-' + item1.manager.id + '" style="font-size: 16px;">' + item1.manager.account + '</a><br/>';
                   str += '概要信息：' + item1.general + '<br/>';
                   str += '<br/>';
               });
               str += '</p></div></li>';
               lis.push(str);
	       });

	       //执行下一页渲染，第二参数为：满足“加载更多”的条件，即后面仍有分页
	       //pages为Ajax返回的总页数，只有当前页小于总页数的情况下，才会继续出现加载更多
	       next(lis.join(''), page < res.pages);    
	         
	     });
	   }
	 });                                   
                  
                  
     //点击新建跟踪记录按钮        
     $('#add-follow').click(function(){
    	 layer.open({
             type:2,
             title:'新建跟踪',
             area:['500px','710px'],
             closeBtn:1,
             shadeClose:false,
             content:'${pageContext.request.contextPath}/views/customer/editfollowup.jsp?type=add',
             end:function(){
            	  location.reload();
             }       
         });
     });             
                  
     
	//展示跟踪记录详细信息
	//动态加载出来的元素需要使用on来绑定
	$(document).on("click","a[id^=followup]",function(){
        //layer.msg('click');
        //console.log(this);
        var id = this.id.split("-")[1];
        layer.open({
            type:2,
            title:'详情',
            area:['400px','60%'],
            closeBtn:1,
            shadeClose: true,
            content:'${pageContext.request.contextPath}/views/customer/followupInfo.jsp?id=' + id,
            end:function(){
                 //location.reload();
            }       
        });
    });

   $(document).on("click","a[id^=manager]",function(){
        //layer.msg('click');
        //console.log(this);
        
        var id = this.id.split("-")[1];
        layer.open({
            type:2,
            title:'用户信息',
            area : ['1000px','400px'],
            clostBtn:1,
            shadeClose: true,
            content:'${pageContext.request.contextPath}/views/user/showUserInfo.jsp?id='+ id
        }); 
    });
	
	$(document).on("click","a[id^=customerInfo]",function(){
		   var customerid = this.id.split("-")[1];
		   layer.open({
		        type:2,
		        title:'客户详情',
		        area:['80%','100%'],
		        clostBtn:1,
		        shadeClose: true,
		        maxmin:true,
		        offset:'r',
		        content:'${pageContext.request.contextPath}/views/customer/customerInfo.jsp?id='+ customerid
		    });	
		
	});

	function localDateTimeToStr(time){
		var str = '';
		var len = time.length;
		switch(len){
			case 1: str = '' + time[0];break;
			case 2: str = '' + time[0] + '-' + time[1];break;
			case 3: str = '' + time[0] + '-' + time[1] + '-' + time[2];break;
			case 4: str = '' + time[0] + '-' + time[1] + '-' + time[2] + '   ' + time[3];break;
			case 5: str = '' + time[0] + '-' + time[1] + '-' + time[2] + '   ' + time[3] + ':' + time[4];break;
			case 6: str = '' + time[0] + '-' + time[1] + '-' + time[2] + '   ' + time[3] + ':' + time[4] + ':' + time[5];break;
		}
		return str;
	}


    //展示角色菜单
    function showCustomer(){
        debugger;
        var load = null;
        $.ajax({
            type : "POST",
            async: false,
            url : "${pageContext.request.contextPath}/customer/list",
            dataType : "json",

            //请求前执行，无论请求是否成功
            beforeSend : function() {
                //显示加载动画
                load = layer.load(2);
            },
            complete : function() {
                //关闭加载动画
                layer.close(load);
            },
            success : function(data) {
                var html = '';
                if (data.data.length > 0) {
                    debugger;
                    $("#customerId").html("");
                    var customers = data.list;
                    html += "<option value=''></option>";
                    for(var i = 0 ; i < customers.length ; i++ ){
                        html += "<option value='"+customers[i].id+"'>"+customers[i].name+"</option>";
                    }
                    $("#customerId").html(html);
                }
                form.render('select');
            }
        });
    };
});
</script>
