Source: E:\AI\kingdee-kaifatips\苍穹开发必备100个小知识V2.1 (1).docx

Generated from the original DOCX for skill reference. Keep field identifiers, entity names, form IDs, and plugin context aligned with the current project when reusing snippets.



# 二、前后端交互

## 用户输入

### 数据联动

问题：办公用品登记单选择物品后，如何自动给物品分类赋值？

参考答案：

方式1：使用基础资料属性字段，然后绑定物品字段，显示属性选择物品分类名称。

方式2：通过业务规则配置【计算定义公式的值并填写到指定列 】服务实现。

方式3：在值更新事件propertyChanged中获取变更的物品值，并给“物品分类”字段赋值。

@Override

public void propertyChanged(PropertyChangedArgs e) {

if (e.getProperty().getName().equals("物品字段标识")) {

ChangeData changeData = e.getChangeSet()[0];

//变更后的数据

DynamicObject newValue = (DynamicObject) changeData.getNewValue();

DynamicObject

goodObj=BusinessDataServiceHelper.loadSingle(newValue.getPkValue(), "物 品的标识", "物品里分类字段标识");

DynamicObject groupObj = goodObj.getDynamicObject("物品里分类字段标 识");

this.getModel().setValue("物品分类字段标识", groupObj);

}

}

### 通过代码赋值后不想触发值更新事件

方式1：在afterCreatedNewData事件赋值，是不会触发值更新事件的。

方式2：在其他事件赋值时，使用以下方式赋值。

this.getModel().beginInit();

this.getModel().setValue("字段标识","字段值");

this.getModel().endInit();

## 用户点击

苍穹平台表单页面的点击及触发原理也是基于Java委托事件处理机制，关键对象包括如下：

Event Source(事件源)：事件发生的场所，通常就是各个组件，例如按钮、窗口、菜单、工具栏（在苍穹上对应Toolbar控件）等。

Event(事件)：事件封装了GUI组件上发生的特定事情（用户动作、行为）。

Event Listener(事件监听器)：注册于某个事件源上，用于响应特定的事件。

在苍穹平台中，所有标准控件的事件源（Button.class,Toolbal.class,EntryGrid.class等）已经定义好了，用户点击苍穹表单页面某个地方时，是否会触发特定的响应方法（click、itemClick、billListHyperLinkClick等），需要满足以下两个条件。

①事件的产生：以用户点击工具栏新增按钮为例，表单微服务根据前端发送的指令最终调用事件源（Toolbar控件模型）创建了两个事件（BeforeItemClickEvent、ItemClickEvent）。

②在表单插件的registerListener方法中注册ToolBar事件源的事件监听器（ClickListener、ItemClickListener）并重写监听器对应的响应事件方法click、itemClick。

由于只产生了BeforeItemClickEvent、ItemClickEvent这两个事件，没有ClickEvent事件，所以只会响应itemClick方法。

以上举例介绍了下事件的处理机制，下面列举几种常见的干预用户点击事件的处理方法。

### 文本字段/按钮点击

问题：如何在点击办公用品登记单的备注（文本字段）时，提示“备注信息不允许修改”？

参考答案：文本字段设置属性“编辑风格”为”按钮点击编辑“时，在register事件中注册监听。

@Override

public void registerListener(EventObject e) {

// TODO Auto-generated method stub

super.registerListener(e);

TextEdit tEdit = this.getView().getControl("备注字段标识");

tEdit.addClickListener(this);

}

并重写Click方法。

@Override

public void click(EventObject evt) {

// TODO Auto-generated method stub

super.click(evt);

Control source = (Control)evt.getSource();

if ("备注字段标识".equals(source.getKey())){

// TODO 在此添加业务逻辑

}

}

### 工具栏按钮点击

问题：点击办公用品登记单的提交按钮时，弹出确认提示框是否确认提交。

参考答案：确认是否提交，所以必须在提交按钮执行前处理，点击确认提交后再继续执行提交操作。

@Override

public void registerListener(EventObject e) {

super.registerListener(e);

//监听工具栏按钮点击事件

this.addItemClickListeners(KEY_TOOlBAR);

}

@Override

public void beforeItemClick(BeforeItemClickEvent evt) {

//工具栏上的所有按钮的点击都会激活itemClick和beforeItemClick方法， 需 //要开发人员实现不同按钮的逻辑

if (evt.getItemKey().equals("bar_submit")){

evt.setCancel(true);

ConfirmCallBackListener confirmCallBackListener = new ConfirmCallBackListener("submitconfirm", this);

//设置页面确认框，参数为：标题，选项框类型，回调监听

this.getView().showConfirm("您确认提交该办公用品登记单吗？", MessageBoxOptions.YesNoCancel, confirmCallBackListener);

}

super.beforeItemClick(evt);

}

@Override

public void confirmCallBack(MessageBoxClosedEvent messageBoxClosedEvent) {

super.confirmCallBack(messageBoxClosedEvent);

//判断是否是对应确认框的点击回调事件

if (("submitconfirm").equals(messageBoxClosedEvent.getCallBackId())) {

if (MessageBoxResult.Yes.equals(messageBoxClosedEvent.getResult())) {

//如果点击确认按钮，则调用提交操作

this.getView().invokeOperation("submit");

} else if (MessageBoxResult.No.equals(messageBoxClosedEvent.getResult())) {

} else if (MessageBoxResult.Cancel.equals(messageBoxClosedEvent.getResult())) {

// 点击取消的相关处理逻辑。。。。

}

}

### 基础资料点击

问题：办公用品登记单先选择物品分类，然后在选择物品时，只显示已选物品分类的物品。

参考答案：在选择物品前，添加过滤条件。需要监听物品基础资料的选择前事件。

@Override

public void registerListener(EventObject e) {

super.registerListener(e);

BasedataEdit bde = this.getView().getControl("物品字段字段标识");

bde.addBeforeF7SelectListener(this)

}

并实现BeforeF7SelectListener接口及重写beforeF7Select方法。最后在beforeF7Select方法中设置过滤条件，参考开发案例【https://vip.kingdee.com/article/198077267325441280?productLineId=29】。

### 单据体点击

#### ①单据体单元格点击

问题1：单据体上添加了个文本字段，数据存储了某个附件url的下载地址，锁定状态；点击某个url时，下载该文件。

参考答案：先在registerListener事件注册单据体单元格监听器。

@Override

public void registerListener(EventObject e) {

super.registerListener(e);

EntryGrid eg = this.getView().getControl("sunp_entryentity");

eg.addCellClickListener(this);

}

然后实现CellClickListener接口及cellClick方法

@Override

public void cellClick(CellClickEvent arg0) {

//获取点击单元格的字段及值

String fieldKey = arg0.getFieldKey();

if (fieldKey.equals("字段标识")) {

String url = (String) this.getModel().getValue(fieldKey, arg0.getRow());

this.getView().openUrl(url);

//或者this.getView().download(url);

}

System.out.println("xx");

}

#### ②单据体行点击

问题2：在办公用品登记单的单据体的工具栏上添加一个查看库存按钮，查看选择行的物品的库存，在选择行时，校验是否物品为空。

参考答案：单据体选择行不需要考虑点击的字段，主要鼠标点击时在单据体某行上时即可。

所以注册行点击监听器。

@Override

public void registerListener(EventObject e) {

super.registerListener(e);

EntryGrid eg = this.getView().getControl("sunp_entryentity");

eg.addRowClickListener(this);

}

并实现接口RowClickEventListener及实现entryRowClick方法，在entryRowClick方法中获取物品值是否为空，为空则取消选择行。

#### ③用代码选中单据体行

this.getModel().setEntryCurrentRowIndex("单据体标识",rowIndex);

#### ④ 获取单据体当前选中行

//方式1-获取当前选中行

this.getModel().getEntryCurrentRowIndex("单据体标识");//只能获取当前选中行

//方式2-获取所有选中行

//通过单据体控件获取选中行

EntryGrid entryGrid = this.getView().getControl("sunp_entryentity");

int[] selectRows = entryGrid.getSelectRows();

### 单据列表超链接点击

问题：办公用品登记单的单据列表点击某个超链接时，取消原有的弹窗逻辑，自定义弹出该表单。

参考答案：

/**

* 用户点击超链接单元格时，触发此事件

*/

@Override

public void billListHyperLinkClick(HyperLinkClickArgs args) {

if (StringUtils.equals("超链接所在列的字段标识", args.getHyperLinkClickEvent().getFieldName())){

// 取消系统自动打开本单的处理

args.setCancel(true);

int rowIndex = args.getRowIndex();//点击的行下标

BillList bl = this.getView().getControl("billlistap");

ListSelectedRowCollection currentListAllRowCollection =

bl.getCurrentListAllRowCollection();

ListSelectedRow listSelectedRow = currentListAllRowCollection.get(rowIndex);

//点击行数据

Object primaryKeyValue = listSelectedRow.getPrimaryKeyValue();//主键值

String formID = listSelectedRow.getFormID();

BillShowParameter bsp = new BillShowParameter();

bsp.setFormId(formID);

bsp.setPkId(primaryKeyValue);

bsp.getOpenStyle().setShowType(ShowType.Modal);

bsp.setStatus(OperationStatus.EDIT);

this.getView().showForm(showParameter);

}

}

点击单据列表时，同时会触发执行listRowClick方法。大家可能好奇为什么单据列表中点击为什么不用注册监听器。这是因为标准的单据列表视图模型对象中注册了相关监听器：kd.bos.mvc.list.AbstractListView.registerListener()。

### 列表获取当前选中行

方式1：通过列表控件模型获取

BillList billlistap = this.getView().getControl("billlistap");

ListSelectedRowCollection selectedRows = billlistap.getSelectedRows();

方式2： 在列表插件实例自带接口

ListSelectedRowCollection selectedRows1 = this.getSelectedRows();

### 获取报表数据

#### ①获取报表指定行数据

ReportList reportList= this.getView().getControl("reportlistap");

//获取第一行数据

DynamicObject rowData = reportList.getReportModel().getRowData(1);

//第一行第一列数据

Object o=reportList.getReportModel().getRowData(1).get(0);

Object o=reportList.getReportModel().getValue(1,"kded_vaccinea");

#### ②获取报表选择行数据

ReportList reportList= this.getControl("reportlistap");

//获取报表列表选中行下标，根据下标查数据行，参考①获取指定行数据

int[] rows = reportList.getEntryState().getSelectedRows();

for(int index:rows){

DynamicObject rowData = reportList.getReportModel().getRowData(index);

}

#### ③获取报表所有行数据

ReportList reportList= this.getView().getControl("reportlistap");

int rowCount = reportList.getReportModel().getRowCount();

//遍历所有行数据

for (int index=1;index<=rowCount;index++) {

DynamicObject rowData=reportList.getReportModel().getRowData(index);

}

## 父子页面交互

比如办公用品登记单点击物品新增申请，在新增申请表单点击确定后把物品名称给办公物品登记单的备注字段”。

### 代码弹出表单页面

第一步：办公用品登记单插件的itemClick方法中弹出物品新增申请单。

@Override

public void itemClick(ItemClickEvent evt) {

FormShowParameter fsp = new FormShowParameter();

fsp.setFormId("物品新增申请单");

fsp.getOpenStyle().setShowType(ShowType.Modal);

fsp.setCloseCallBack(new CloseCallBack(this, "show-kded_supaddnew"));//

this.getView().showForm(fsp);

super.itemClick(evt);

}

### 如何修改父页面的数据

方案1：直接在子页面的表单插件中拿到父页面的数据模型model进行赋值。

@Override

public void click(EventObject evt) {

if (evt.getSource() instanceof Button) {

Button bt=(Button) evt.getSource();

String key = bt.getKey();

if (key.equals("btnok")) {

Object goodName = this.getModel().getValue("物品名称字段标识");

IFormView parentView = this.getView().getParentView();//父页面

IDataModel parentModel = parentView.getModel();

parentModel.setValue("sunp_textfield",goodName ) );//修改父页面数据

parentView .updateView();//刷新

//调用了其他表单的控制方法时，需调用以下方法将目标表单的控制 指 //令发给前端

this.getView().sendFormAction(this.getView().getParentView()); this.getView().close();

}

}

super.click(evt);

}

方案2：将子页面的字段值传给父页面，然后在父页面的表单插件的closedCallBack方法中修改备注字段值。

新增物品申请单表单插件：

@Override

public void click(EventObject evt) {

if (evt.getSource() instanceof Button) {

Button bt=(Button) evt.getSource();

String key = bt.getKey();

if (key.equals("btnok")) {//确定按钮或者是邮件通知按钮

Object goodName = this.getModel().getValue("物品名称字段标识");/

this.getView().returnDataToParent(goodName);//返回数据给父页面

this.getView().close();

}

}

}

办公用品登记单插件：

@Override

public void closedCallBack(ClosedCallBackEvent closedCallBackEvent) {

if (closedCallBackEvent.getActionId().equals("show-kded_supaddnew")) {

Object returnData = closedCallBackEvent.getReturnData();

this.getModel().setValue("sunp_textfield",returnData);

}

super.closedCallBack(closedCallBackEvent);

}

方案3：将子页面的值放到父页面缓存，由父页面插件进行赋值处理。

新增物品申请单表单插件：

@Override

public void click(EventObject evt) {

if (evt.getSource() instanceof Button) {

Button bt=(Button) evt.getSource();

String key = bt.getKey();

if (key.equals("btnok")) {//确定按钮或者是邮件通知按钮

Object goodName = this.getModel().getValue("物品名称字段标识");/

//通过界面缓存传递值

this.getView().getParentView().getPageCache().put("name", goodName );

this.getView().close();

}

}

}

}

办公用品登记单插件：

@Override

public void closedCallBack(ClosedCallBackEvent closedCallBackEvent) {

if (closedCallBackEvent.getActionId().equals("show-kded_supaddnew")) {

this.getModel().setValue("sunp_textfield",this.getView().getPageCache(). get("name"));

}

super.closedCallBack(closedCallBackEvent);

}

## 基础资料选择界面（F7）

### F7选择界面显示哪些字段

基本上F7选择界面都是统一的界面，普通基础资料用的是bos_listf7，分组基础资料和树形基础资料用的是bos_templatetreelistf7界面，部分基础资料，比如人员、组织、客户、供应商等基础资料有自己的f7界面。

F7选择界面的字段由基础资料列表的字段决定，给列表增加字段，并且【可见性】选上F7界面可见。

### F7选择界面显示未审核的数据

@Override

public void beforeF7Select(BeforeF7SelectEvent beforeF7SelectEvent) {

if("kded_basedatafield".equals(beforeF7SelectEvent.getProperty().getName())){

ListShowParameter listShowParameter = (ListShowParameter) beforeF7SelectEvent.getFormShowParameter();

listShowParameter.setShowApproved(false);

}

｝

### F7选择界面展示已选择的数据，开启多选等

public void beforeF7Select(BeforeF7SelectEvent beforeF7SelectEvent) {

if("kded_basedatafield".equals(beforeF7SelectEvent.getProperty().getName())){

ListShowParameter listShowParameter = (ListShowParameter)

beforeF7SelectEvent.getFormShowParameter();

listShowParameter.setShowApproved(false);

DynamicObject baseData = (DynamicObject) this.getModel().getValue("kded_basedatafield");

if(baseData != null) {

//设置单个已选

listShowParameter.setSelectedRow(baseData.getPkValue()); listShowParameter.setSelectedRows(new Object[]{baseData.getPkValue()});//设置多个已选

listShowParameter.setMultiSelect(true);//开启多选

}

｝
