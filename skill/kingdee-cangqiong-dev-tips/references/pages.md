Source: E:\AI\kingdee-kaifatips\苍穹开发必备100个小知识V2.1 (1).docx

Generated from the original DOCX for skill reference. Keep field identifiers, entity names, form IDs, and plugin context aligned with the current project when reusing snippets.



# 一、页面

## 表单页面取值

### 获取简单字段的值

问题1：获取办公用品登记单的备注字段（文本字段）的值？

参考答案：

数据模型IDataModel中存储了当前页面的数据包，对于文本类型、整数、时间字段等简单类型字段，可以直接通过IDataModel的get方法直接获取字段值，值的返回类型有String、Date、BigDecimal等。

IDataModel model = this.getModel();

String remark = (String)model .getValue("文本字段标识");

问题2：获取单据体数量字段的值？

参考答案：

取单据体中的字段值需要指定行数，下标从0开始，如获取第一行数量字段的值：

BigDecimal qty=this.getModel().getValue("数量字段标识",0)

### 获取基础资料的属性值

问题：如何获取创建人的生日？

参考答案：

创建人是基础资料字段，像创建人、修改人、用户字段本质都是基础资料字段，只是关联的基础资料类型已预置人员【bos_user】。对于基础资料， 通过this.getModel().getValue("基础资料字段标识")拿到是一个对象DynamicObject ，并且默认取出来的DynamicObject数据中只包含基础资料的id、name、number属性值。

DynamicObject creatorDObj = (DynamicObject) this.getModel().getValue("creator");

所以直接this.getModel().getValue（）默认无法获取到基础资料除id,name、number外的属性值，需要通过以下两种方式获取。

方式1：在表单设计器中引用人员的“生日”属性，然后再通过以下代码可以取到基础资料某个属性。

DynamicObject creatorDObj = (DynamicObject) this.getModel().getValue("creator");

String birthday = creatorDObj.getString("birthday");

方式2：先拿到基础资料的id，再通过orm接口去查基础资料的某个属性值。

//获取当前页面创建人字段的数据对象

DynamicObject creatorDObj = (DynamicObject) this.getModel().getValue("creator");

Object pkValue = creatorDObj.getPkValue();//拿主键即id

QFilter idQFilter = new QFilter("id", QCP.equals, pkValue);//构造过滤条件

DynamicObject queryRuselt =

QueryServiceHelper.queryOne("bos_user", "birthday",new QFilter[] {idQFilter} );//查 询数据库

String birthday = queryRuselt.getString("birthday");//拿属性的值

### 获取单据体某个字段或行对象

问题1：如何获取单据体某行某个字段的值？

答：this.getModel().getValue("kded_textfield", 0);//0代表第一行

问题2：如何获取单据体中各行的数据？

参考答案：

单据体中的数据是多行数据的集合，每行数据都是一个DynamicObject 数据包，每行数据又包含多个字段（简单值、复杂值）值。

方式1：

//获取当前页面的数据包

DynamicObject dataEntity = this.getModel().getDataEntity(true);

//获取单据体数据的集合

DynamicObjectCollection goodsEntities=dataEntity.getDynamicObjectCollection(" 单据体标识");

for (DynamicObject entryObj : goodsEntities) {

//获取某行数据的id

Object pk=entryObj.getPkValue();

//获取某行的某个字段的值

Object object = entryObj.get("字段标识");

}

方式2：

DynamicObjectCollection entryRows = this.getModel().getEntryEntity("单据体标识");

### 获取子单据体某个字段或行

问题1：如何获取子单据体某行某个字段的值？

参考答案：

this.getModel().getValue("kded_textfield", 0,0);

//第一个整数代表子单据体行号，第二个整数代表父单据体行号

问题2：如何获取子单据体中各行的数据？

参考答案：

子单据体中的数据也是是多行数据的集合，并且是挂在单据体行里的，所以需要先得到单据体的行数据对象，再从单据体行数据对象获取子单据数据行集合。

//获取当前页面的数据包

DynamicObject dataEntity = this.getModel().getDataEntity(true);

//先获取单据体数据的集合

DynamicObjectCollection goodsEntities=dataEntity.getDynamicObjectCollection(" 单据体标识");

for (DynamicObject entryObj : goodsEntities) {

//再获取子单据体行某行数据的id

DynamicObjectCollection cols=entryObj .getDynamicObjectCollection("子单据体 标识");

for (DynamicObject col: cols) {

col.get("字段标识");//获取子单据体字段的值

}

}

### 获取富文本控件的值

问题：如何获取富文本控件的值？

参考答案：富文本是通用控件，通用控件不能存储数据，所以不能通过model来取值，富文本的控件模型提供了相应的接口。

RichTextEditor edit = this.getView().getControl("富文本控件标识");

String text = edit.getText();

因此需要保存时把富文本的数据保存到一个大文本字段上，打开保存后的单据时，将该大文本的值绑定到富文本控件上。

//在保存单据时，将富文本控件的内容保存到大文本字段

public void beforeDoOperation(BeforeDoOperationEventArgs e) {

FormOperate operate = (FormOperate)e.getSource();

String key = operate.getOperateKey();

if(key.equalsIgnoreCase("save")) {

RichTextEditor edit = this.getView().getControl("富文本控件标识");

String text = edit.getText();

this.getModel().setValue("大文本字段标识",text );//赋值到大文本字段上

}

//在打开单据时，将大文本字段的值显示到富文本控件

public void afterBindData(EventObject e) {

super.afterBindData(e);

RichTextEditor edit = this.getView().getControl("富文本控件标识");

String text = edit.setText((String) this.getModel().getValue("大文本字段标识"));

}

注意事项：能够通过model去获取值的字段，必须在表有对应的表字段，比如富文本、基础资料属性这类字段，是没有表字段的，自然不能通过model去取值及赋值。

### 获取多选基础资料的值

多选基础资料字段配置的时候是要写表名的，通过model拿到的就是该表某些数据的集合，遍历集合才能拿到实际选择的基础资料数据对象。

DynamicObjectCollection multiCols = (DynamicObjectCollection) this.getModel().getValue("kded_mulbasedatafield");

for(DynamicObject col:multiCols){

//获取选择的基础资料数据对象

DynamicObject baseData = (DynamicObject) col.get("fbasedataid");

}

## 表单页面赋值

### 给简单字段赋值

问题：新增单据时，如何自动给办公用品登记单备注字段（文本）设置默认值？

参考答案：简单字段的赋值，直接通过当前页面的数据模型IDataModel 赋值给字段赋值。

@Override

public void afterCreateNewData(EventObject e) {

IDataModel model = this.getModel();

model.setValue("kded_remark", "我的备注数据");

}

### 给基础资料字段赋值

问题：如何给办公用品登记单的登记人字段赋值？

参考答案：因为登记人的是“用户”类型字段，而用户字段又是特殊的基础资料字段。

所以给基础资料赋值必须用基础资料的id或者基础资料的DynamicObject。

@Override

public void afterCreateNewData(EventObject e) {

long currentUserId = UserServiceHelper.getCurrentUserId();

//方式1：通过id赋值-推荐

this.getModel().setValue("kded_registrant", currentUserId );

//方式2：通过对象赋值

DynamicObject user = BusinessDataServiceHelper.loadSingle(currentUserId, "bos_user");

this.getModel().setValue("kded_registrant", user);

}

注意：不能使用QueryServiceHelper.queryOne查到的平铺对象赋值给基础资料字段。

### 给单据体的字段赋值

问题：如何给单据体某个字段赋值？

参考答案：

方式1：如果是知道行号index，且只需要给这行的字段赋值，则参考：

this.getModel().setValue("字段标识","字段值",index);

方式2：需要给每行赋值，则需遍历单据体进行赋值：

DynamicObjectCollection entryRows = this.getModel().getEntryEntity("单据体标识");

for (DynamicObject entryObj : entryRows) {

//修改某行的某个字段的值

entryObj.set("kded_textfield", "测试");}

}

this.getView().updateView("entryentity")i

注意点：方式2如果在afterCreateNewData事件则不需要updateView,否则需要代码刷新前台才会显示。

### 给单据体新建行

问题：如何给办公用品登记单的单据体添加一行数据？

方式1：单据体虽然是集合，但是数据模型IModel提供了直接增加行的接口，需要知道要增加的行数row。

int[] newEntryRow = this.getModel().batchCreateNewEntryRow("单据体标识", row);

for (int index : newEntryRow) {

this.getModel().setValue("单据体某个字段标识", 值, index);

}

方式2：给单据体创建行对象，再调用IModel增加行的接口。

DynamicObject entry = ORM.create().newDynamicObject(this.getModel().getEntryEntity("单据体标识 ").getDynamicObjectType());

entry.set("kded_textfield1","44");

entry.set("kded_amountfield","10");

int rowindex = this.getModel().createNewEntryRow("单据体标识", entry);

注意：如果单据体字段有设置默认值，此方式默认值会覆盖代码设置的值。

方式3：通过数据包给单据体直接新增行对象。

DynamicObjectCollection entryentityCols = this.getModel().getDataEntity(true).getDynamicObjectCollection("entryentity");

DynamicObject entryCol = entryentityCols.addNew();

entryCol.set("kded_textfield", "方式4");

this.getView().updateView("entryentity");

获取单据体数据包，在数据包新增行对象，是需要代码调用updateView才会将新内容显示到界面上。

### 给子单据体新建一行

问题：如何给子单据体添加一行数据？

参考答案：

//先设置父单据体选中行

this.getModel().setEntryCurrentRowIndex("entryentity",0);

//创建子单据体行-方式1

int[] ints = this.getModel().batchCreateNewEntryRow("kded_subentryentity", 1);

for (int index : ints) {

this.getModel().setValue("kded_textfield2", "文本值", index);

}

//创建子单据体行-方式2

DynamicObject subEntry = ORM.create().newDynamicObject(this.getModel().getEntryEntity("kded_subentryentit y").getDynamicObjectType());

subEntry.set("kded_textfield2","行对象");

int rowindex = this.getModel().createNewEntryRow("kded_subentryentity", subEntry);

### 给富文本控件赋值

问题：如何给富文本控件赋值？

参考答案：富文本是通用控件，不能像实体字段一样直接用数据模型this.getmodel赋值，需要通过富文本控件模型RichTextEditor 提供的方法setText设置值。

RichTextEditor edit = this.getView().getControl("richtexteditorap");

edit.setText("要设置的内容");

### 给多选基础资料赋值

参考答案：

【https://vip.kingdee.com/article/198799132897594368?productLineId=29】

## 列表页面赋值

### 单据列表

问题：如何在列表中动态修改或更新当前流程处理人字段？

参考答案：列表是用来显示单据存储在数据库中的数据的，如果要在列表显示的时候，修改列表数据，可以在列表插件中重写beforeCreateListDataProvider方法，构建自定义的列表取数器，实现自主取数，具体参考：【https://vip.kingdee.com/article/306390194805169920?productLineId=29】

## 数据复制

### 如何复制单据数据

问题：办公物品登记单添加添加一个备份功能，保存时，如果数据库中已存在该表单数据，则生成该条单据的副本数据，要求业务数据和原来保持一致（id这种唯一性数据不做要求），并把备注字段赋值："备份数据"。

参考答案：首先，要找到在哪个事件中去备份数据。要求保存时，要先查询数据库中是否有数据，那就是该次保存还未正式保存到数据库中的时候去处理。即在操作插件beginOperationTransaction事件中同步备份数据。

public class SrSubmitOpPlugin extends AbstractOperationServicePlugIn {

@Override

public void onPreparePropertys(PreparePropertysEventArgs e) {

super.onPreparePropertys(e);

e.getFieldKeys().add("kded_srstatus");

}

@Override

public void beginOperationTransaction(BeginOperationTransactionArgs e) {

super.beginOperationTransaction(e);

DynamicObject[] dataEntities = e.getDataEntities();

for(DynamicObject data : dataEntities) {

//单据标识

String entityNumber = data.getDataEntityType().getName();

//data是保存前且校验通过的数据包，此处备份数据

Object pkValue = obj.getPkValue()

boolean exists = QueryServiceHelper.exists(entityNumber , pkValue);

if(exists){

//如下复制数据方案1或者方案2

)else{

}

}

}

}

数据复制有两种方案：

方案1：创建空数据包，并逐一赋值-不推荐，后续表单增加字段，需要不断迭代代码。

//创建空的数据包

DynamicObject newDynamicObject = BusinessDataServiceHelper.newDynamicObject(entityNumber);

newDynamicObject.set("单据头字段标识a", data.get("单据头字段标识a"));

newDynamicObject.set("备注字段标识", "备份数据");

//单据体数据行

DynamicObjectCollection newCol = newDynamicObject.getDynamicObjectCollection("单据体标识");

DynamicObjectCollection oldCol = data.getDynamicObjectCollection("单据体标 识 ");

//复制当前分录数据到新增数据包的新增分录行上

for (DynamicObject oldEntry : oldCol) {

//创建一个空的分录行

DynamicObject newEntry = new DynamicObject(newCol.getDynamicObjectType());

newEntry.set("单据体字段标识x", oldEntry.get("单据体字段标识x"));

//新增数据行添加到单据体上

newCol.add(newEntry);

}

//保存数据

SaveServiceHelper.saveOperate(entityNumber, new DynamicObject[] {newDynamicObject})

方案2：直接克隆整个数据包-增加字段无需迭代代码，推荐。

DynamicObject newData = (DynamicObject) new CloneUtils(false,true).clone(data );

newData.set("备注字段标识", "备份数据");

//保存数据

SaveServiceHelper.saveOperate(entityNumber, new DynamicObject[] {newData })

## 页面参数

### 如何判断界面是否新增界面？

问题：办公用品登记单打开时，如果是新增页面，则弹出提示“您正在新增办公用品登记单”；如果是编辑页面，则提示”您正在编辑一个办公用品登记单“。

参考答案：

①首先确认要重写的事件，要在“新增”和“编辑”状态下都会执行。而弹出提示是view的行为，所以一般建议在afterBindData事件中处理。

②每个界面视图中，都保存了相关界面的参数，包括但不局限于：页面pageid，表单标识、表单运行插件、父页面传过来的自定义参数等，例如当前页面是新增状态还是编辑状态，可以根据单据页面的界面参数FormShowParameter中的getStatus方法获取到。

BillShowParameter bsp=(BillShowParameter)this.getView().getFormShowParameter();

if(bsp.getStatus()==OperationStatus.ADDNEW ){

this.getView().showTipNotification("您正在新增办公用品登记单")；

}

if(bsp.getStatus()==OperationStatus.EDIT){

this.getView().showTipNotification("您正在编辑一个办公用品登记单")；

}

## 视图模型VIEW

### 取消打开页面

问题：如何控制办公用品登记单在周日的的时候不能新增单据？

参考答案：在表单显示前判断new Date()判断一下如果是周日，然后在preOpenForm事件中取消页面的打开。

@Override

public void preOpenForm(PreOpenFormEventArgs e) {

e.setCancel(true);

e.setCancelMessage("对不起，周日不能制单！");

}

### 设置控件的锁定性

#### 第一种：锁定单据头字段

问题1：办公用品登记单的总金额自动计算得出的，所以始终是锁定状态。

参考答案：

方式1：表单设计器上设置”新增锁定、修改锁定、提交锁定、审核锁定"。

方式2：通过如下代码设置锁定性。

@Override

public void afterBindData(EventObject e) {

super.afterBindData(e);

this.getView().setEnable(false, "字段标识");

}

说明:其他场景下，影响锁定性的因素还有单据类型、界面规则、布局等。

#### 第二种：锁定单据体或单据体字段

问题1：如何锁定单据体某几行？

参考答案：

//锁定单据体某几行，所有字段都锁定

EntryGrid entryGrid = this.getView().getControl("entryentity");

entryGrid.setRowLock(true,new int[]{0,1});

问题2：如何锁定单据体某一行某一列？

参考答案：

//锁定单据体某行某列

this.getView().setEnable(false,2,"kded_dealdesc");

问题3：如何锁定某一列？

参考答案：没有锁定整列的接口，需遍历单据体行锁定

int rowCount = this.getModel().getEntryRowCount("entryentity");

for(int i = 0,i<rowCount ,i++){

this.getView().setEnable(false,i,"kded_dealdesc");

}

问题4：如何锁定整个单据体？

参考答案：

this.getView().setEnable(false,"entryentity");

### 设置控件可见性

问题：如何设置单据在审核状态下审核人字段可见？

参考答案：

方式1：字段的可见性配置勾选“审核可见”。

方式2：同样在afterBindData事件中先判断单据状态是审核状态时，再设置审核人字段可见：this.getView().setVisible(true, "字段标识");

补充:其他场景下，影响可见性的因素还包括界面规则、单据类型、布局等。

### 设置字段必录性

苍穹V5.0.023支持按条件设置必录

https://developer.kingdee.com/article/463766090045075712?productLineId=29&isKnowledge=2

### 设置单据体选中行

问题：单据体有数据时，如何设置单据体默认选中第一行数据？

参考答案：苍穹平台的每个控件都有定义好的控件模型，通过控件模型的接口可以间接改变界面显示的内容；设置单据体默认选中行，首先想到这是单据体控件的独有控件属性，所以先获取单据体控件模型EntryGrid，查找EntryGrid有没有提供对应的方法，显然EntryGrid有设置选中行的设置方法selectRows。

//数据模型中获取单据体的数据行数

int entryRowCount = this.getModel().getEntryRowCount("sunp_entryentity");

if (entryRowCount!=0) {

//获取单据体控件模型

EntryGrid eg = this.getView().getControl("sunp_entryentity");

//通过单据体控件模型的方法实现选中行功能

eg.selectRows(0);

}

### 执行页面的按钮点击事件

问题：如何通过代码触发工具栏或按钮的点击逻辑？

参考答案：先获取对应的控件模型，控件模型提供了点击方法。

//tbmain是工具栏标识，bar_save是工具栏项标识，save是工具栏绑定的操作

Toolbar toolbar = this.getView().getControl("tbmain");

toolbar.itemClick("bar_save", "save");

//触发按钮，kded_btsave是按钮标识

Button button = this.getView().getControl("kded_btsave");

button.click();

### 执行操作

问题：如何通过代码触发某个操作？

参考答案：界面模型提供了相关接口。

this.getView().invokeOperation("save");//save是操作标识

### 刷新数据

问题1：通过插件给单据头的字段赋值，发现值没显示出来时，应该如何刷新字段的值？

参考答案：

this.getView().updateView("字段标识");

//或者

this.getView().updateView();

问题2：通过插件给单据体的字段赋值，发现值没显示出来时，应该如何刷新单据体字段的值？

参考答案：

this.getView().updateView("单据体字段", 所在行号);

//如果刷新很多单据体字段，可以选择刷新整个单据体

this.getView().updateView("单据体标识");

//或者

this.getView().updateView();

问题3：在用户打开查看单据的某条数据时，并在插件中通过BusinessDataServiceHelper.loadSingle查数据库中对应的数据进行修改,并通过SaveServiceHelper.update更新数据到数据库，那么用户此时该如何刷新修改的数据到当前页面

参考答案：

//或者调用表单的“刷新”操作

this.getView().invokeOperation("refresh");

推荐：由于刷新是有性能消耗的，updateView建议指定刷新字段或刷新单据体的标识，尽量不要进行全局刷新-this.getView().updateView()。

### 页面关闭

问题1：在修改了数据之后，没有保存就退出，会提示如下图。如何取消该校验？

参考答案：提示是在页面关闭时的校验，那么可以在页面关闭前事件beforeClosed中，通过修改事件参数取消校验。

@Override

public void beforeClosed(BeforeClosedEvent e) {

super.beforeClosed(e);

e.setCheckDataChange(false);

}

问题2：如何通过代码关闭页面。

参考答案：

this.getView().close();

//或者

this.getView().invokeOperation("close");

### 页面弹出提示信息

问题1：如何通过代码弹出提示信息？

参考答案：

this.getView.showMessage("提示信息");

更多提示方式见：https://vip.kingdee.com/school/238714716992919296?topicId=239383452913417728&stageId=239383671570873856&pathId=239410657773565696&productLineId=29

### 修改控件名称

问题1：如何通过代码修改字段控件的名称？

参考答案：TextEdit的父类FieldEdit提供setCaption接口修改控件名称。如：

TextEdit textField = (TextEdit)this.getView().getControl("kded_textfield1");

textField.setCaption(new LocaleString("sss"));

注意：当通过该方式修改字段标题后，修改该字段退出界面会提示已有XXX字段修改，是否继续退出，这里还是显示修改前的字段名称，需要通过以下代码修改主数据模型对应属性的标题：

//对应修改元数据对应属性的标题

Map<String, IDataEntityProperty> allFields

=this.getModel().getDataEntityType().getAllFields();

IDataEntityProperty kded_textfield1 = allFields.get("kded_textfield1");

kded_textfield1.getDisplayName().setLocaleValue("sss");

问题2：如何通过代码修改非字段类型的控件名称，比如按钮、高级面板等？

参考答案：使用动态更新元数据属性的接口updateControlMetadata。

Map<String, Object> text = new HashMap<>();

Map<String, Object> text1 = new HashMap<>();

text.put("zh_CN", "test");

text1.put("text", text);

this.getView().updateControlMetadata("控件标识", text1);

### 页面缓存

问题：如何使用页面缓存？

参考答案：

this.getView().getPageCache().put("isLeaf","true");

String isLeaf = this.getView().getPageCache().get("isLeaf");

### 获取当前页面的元数据信息

问题：如何获取运行期表单及表单所有控件信息？

参考答案：

元数据相关的servicehelper：MetadataServiceHelper、AppMetaServiceHelper、ConvertMetaServiceHelper、LocaleMetadataServiceHelper等，优先使用这些。（注意不要用到非平台的）

//根据表单编码获取表单id

String id = MetadataDao.getIdByNumber("kdec_cehsi", MetaCategory.Form);

//获取表单元数据

FormMetadata formMeta = (FormMetadata) MetadataDao.readRuntimeMeta(id, Meta Category.Form);

//遍历获取所有控件集合

for (ControlAp<?> item : formMeta.getItems()) {

//可见性

String visible = item.getVisible();

//控件名称

String name = item.getName().getLocaleValue();

//控件编码

String key = item.getKey();

}
