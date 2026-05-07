Source: E:\AI\kingdee-kaifatips\苍穹开发必备100个小知识V2.1 (1).docx

Generated from the original DOCX for skill reference. Keep field identifiers, entity names, form IDs, and plugin context aligned with the current project when reusing snippets.



# 三、后端数据操作

## 如何新建数据对象并赋值

### 新建空数据对象

可以使用DynamicObject的构造函数，也可以使用BusinessDataServiceHelper或ORM提供的接口。

方式1：

DynamicObject data

=BusinessDataServiceHelper.newDynamicObject("kded_simplebill");

方式2：

DynamicObject kded_simplebill =

ORM.create().newDynamicObject("kded_simplebill");

方式3

MainEntityType type =

EntityMetadataCache.getDataEntityType("kded_simplebill");

DynamicObject data1 = new DynamicObject((DynamicObjectType) type);

### 给对象赋简单字段的值

data.set("billno","测试0002");

data.set("billstatus","A");

### 给对象新增单据体并赋值

DynamicObjectCollection entryentity =

data.getDynamicObjectCollection("entryentity");

//新增单据体方式一：

DynamicObject dynamicObject = entryentity.addNew();

dynamicObject.set("kded_textfield","代码新增单据体方式1");

//新增单据体方式二：

DynamicObject dynamicObject1 =

new DynamicObject(entryentity.getDynamicObjectType());

dynamicObject1.set("kded_textfield","代码新增单据体方式2");

entryentity.add(dynamicObject1);

### 给对象新增子单据体并赋值

DynamicObjectCollection entryentity = data.getDynamicObjectCollection("entryentity");

DynamicObject entry = new DynamicObject(entryentity.getDynamicObjectType()); entry.set("kdec_textfield","hello1");

entry.set("kdec_integerfield", 95271);

entryentity.add(entry);

//单据体数据

DynamicObjectCollection subentryentity = entry.getDynamicObjectCollection("subentryentity");

//单据体的子单据体

DynamicObject subentry = new DynamicObject(subentryentity.getDynamicObjectType());

subentry.set("kdec_textfield1","world");

subentry.set("kdec_integerfield1", 12138); subentryentity.add(subentry);

## 如何保存数据对象

## SaveServiceHelper

//方式1-走保存操作的校验

OperationResult operationResult1 =

SaveServiceHelper.saveOperate("kded_simplebill", new DynamicObject[]{data},

OperateOption.create());

//方式2-直接存库

SaveServiceHelper.save(new DynamicObject[]{data});

## OperationServiceHelper

该接口可以执行单据的操作，如执行提交操作：

OperationResult operationResult =

OperationServiceHelper.executeOperate("submit","kded_simplebill",new DynamicObject[]{data},OperateOption.create());

if(!operationResult.getSuccessPkIds().isEmpty()){

//执行成功

}

## 如何查询数据对象

### 查询简单字段&使用简单字段做过滤条件

//方式1-根据单据id查询-可以查询所有字段

Object billId = "1515996182680175616";

DynamicObject simpleBill = BusinessDataServiceHelper.loadSingle(billId,

"kded_simplebill");

//方式2-根据单据id查询-查询指定字段，查询结果是平铺的

QFilter filter = new QFilter("id", QCP.equals, billId);

DynamicObject simpleBillObject =

QueryServiceHelper.queryOne("kded_simplebill", "id,billno,createtime", new QFilter[]{filter});

### 查询复杂字段&使用复杂字段做过滤条件

//方式1-根据创建人的名称构造过滤条件-BusinessDataServiceHelper

QFilter filter2 = new QFilter("creator.name", QCP.equals, "XXX");

DynamicObject simpleBill2 =

BusinessDataServiceHelper.loadSingle("kded_simplebill","id,billno,creator,creato r.id,createtime",new QFilter[]{filter2});

DynamicObject creator = simpleBill2.getDynamicObject("creator");

long creatorId = simpleBill2.getLong("creator.id");

//方式2-根据创建人的名称构造过滤条件-QueryServiceHelper

DynamicObject simpleBillObject3 =

QueryServiceHelper.queryOne("kded_simplebill",

"id,billno,creator,creator.id,createtime", new QFilter[]{filter2});

DynamicObject creator1 = simpleBill2.getDynamicObject("creator");

### 查询单据体字段&使用单据体字段做过滤条件

#### ①使用BusinessDataServiceHelper

//根据单据体的字段构造过滤条件

QFilter filter3 = new QFilter("entryentity.kded_dealuser.name", QCP.equals, "金小

蝶");

DynamicObject simpleBill3 =

BusinessDataServiceHelper.loadSingle("kded_simplebill","id,billno,kded_dealuse r,kded_dealdesc",new QFilter[]{filter3});

DynamicObjectCollection cols =

simpleBill3.getDynamicObjectCollection("entryentity");

for(DynamicObject col:cols){

DynamicObject user = col.getDynamicObject("kded_dealuser");

String name = user.getString("name");

String dec = col.getString("kded_dealdesc");

}

注意点：

1.过滤条件使用单据体字段做过滤条件需要加上单据体标识，如entryentity.kded_dealuser.name；

2.查询字段selectfields查询单据体字段可不用加单据体标识，如

DynamicObject user = col.getDynamicObject("kded_dealuser");

3.user默认有id，number、name字段，如需其他字段，需要单据给该基础资料字段配置引用属性。

#### ②使用BusinessDataServiceHelper

QFilter filter5 = new QFilter("entryentity.kded_dealuser.name", QCP.equals, "金小

蝶");

DynamicObjectCollection simpleBills =

DynamicObject[] dojs = BusinessDataServiceHelper.load("kded_simplebill", "id,billno,entryentity.kded_dealuser.name,entryentity.kded_dealdesc", new QFilter[]{filter5});

for(DynamicObject doj:dojs){

DynamicObjectCollection col = doj.getDynamicObjectCollection("entryentity");//先查询单据体数据包

col.get(Integer.parseInt("kded_dealdesc"));//再从单据体某行数据包中获取某列字段的值

}

注意点：过滤条件和查询字段使用单据体字段都需要用单据体标识entryentity， 指定什么字段则查出什么字段。

### 查询子单据体字段&使用单据体字段做过滤条件

//根据单据体的字段构造过滤条件查询子单据体字段

QFilter filter4 = new QFilter("entryentity.kded_dealuser.name", QCP.equals, "金小蝶 ");

DynamicObject simpleBill4 =

BusinessDataServiceHelper.loadSingle("kded_simplebill","id,billno,kded_dealuser, kded_dealdesc,kded_subdealuser,kded_subdec",new QFilter[]{filter4});

DynamicObjectCollection cols1 =

simpleBill4.getDynamicObjectCollection("entryentity");

for(DynamicObject col:cols1){

//获取单据体字段

DynamicObject user = col.getDynamicObject("kded_dealuser");

String name = user.getString("name");

String dec = col.getString("kded_dealdesc");

DynamicObjectCollection subCols =

col.getDynamicObjectCollection("kded_subentryentity");

for (DynamicObject subCol:subCols) {

//获取子单据体字段

DynamicObject subDealUser =

subCol.getDynamicObject("kded_subdealuser");

String subDec = subCol.getString("kded_subdec");

}

}

## 如何删除数据对象

### （1）直接从数据库删除数据，不触发数据校验

DynamicObject dObj = null;

//IDataEntityType 为实体类型基类

IDataEntityType dataEntityType = dObj.getDataEntityType();

//pks为数据主键值

DeleteServiceHelper.delete(IDataEntityType type, Object[] pks)

### （2）删除数据时，触发数据校验

DeleteServiceHelper deleteServiceHelper = new DeleteServiceHelper();

deleteServiceHelper.deleteOperate("删除的操作代码", "单据标识", pks,

OperateOption.create());

//或者直接调用通用操作接口

OperationServiceHelper.executeOperate("删除的操作代码", "单据标识", pks,

OperateOption.create())
