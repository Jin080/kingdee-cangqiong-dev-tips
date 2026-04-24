Source: E:\AI\kingdee-kaifatips\苍穹开发必备100个小知识V2.1 (1).docx

Generated from the original DOCX for skill reference. Keep field identifiers, entity names, form IDs, and plugin context aligned with the current project when reusing snippets.



# 四、操作

## 代码触发操作

### 界面插件触发操作

界面模型View提供了触发操作的接口。

this.getView().invokeOperation("submit");

### 非界面插件触发操作

非界面插件没有界面模型View，需要通过操作服务工具类触发（也可以界面插件使用）。

OperationResult operationResult =

OperationServiceHelper.executeOperate("submit","kded_simplebill",new DynamicObject[]{data},OperateOption.create());

if(!operationResult.getSuccessPkIds().isEmpty()){

//todo;

}

### 代码触发操作如何忽略验权

通过OperateOption传递对应参数，可以绕过权限校验。

OperateOption option = OperateOption.create();

option.setVariableValue(OperateOptionConst.ISHASRIGHT, "true");OperationResult

## 操作后如何刷新字段

### 配置实现

单据状态、日期这两种类型的字段可以在操作配置刷新字段实现。

### 代码实现

@Override

public void afterDoOperation(AfterDoOperationEventArgs

afterDoOperationEventArgs) {

super.afterDoOperation(afterDoOperationEventArgs);

FormOperate formoperate = (FormOperate)

afterDoOperationEventArgs.getSource();

if("操作代码".equals(formoperate.getOperateKey())) {

if(!afterDoOperationEventArgs.getOperationResult().getSuccessPkIds().

isEmpty()) {

this.getView().updateView("字段标识");

}

}

## 操作后如何提示

### 配置提示

固定的提示语可以直接在操作进行配置，如图：

### 代码修改操作后的提示

首先得在操作配置操作成功后提示，通过代码修改提示内容才会弹出显示。

方式1：在操作插件实现。

@Override

public void afterExecuteOperationTransaction(AfterOperationArgs e) {

if("save".equals(e.getOperationKey())&&!this.getOperationResult().getSuccessPkI ds().isEmpty()) {

this.getOperationResult().setMessage("保存成功啦-操作插件");

}

}

方式2：在界面插件实现。

@Override

public void afterDoOperation(AfterDoOperationEventArgs

afterDoOperationEventArgs) {

super.afterDoOperation(afterDoOperationEventArgs);

FormOperate formoperate = (FormOperate)

afterDoOperationEventArgs.getSource();

if("save".equals(formoperate.getOperateKey())&&!afterDoOperationEventA rgs.getOperationResult().getSuccessPkIds().isEmpty()) {

afterDoOperationEventArgs.getOperationResult().setMessage("保存成

功！-界面插件");

}

}

## 操作插件跟界面插件如何传递参数

#### 从界面传递参数给操作插件

首先在界面插件给操作塞参数

@Override

public void beforeDoOperation(BeforeDoOperationEventArgs args) {

super.beforeDoOperation(args);

FormOperate formoperate = (FormOperate) args.getSource();

if("save".equals(formoperate.getOperateKey())) {

formoperate.getOption().setVariableValue("customItem",this.getView().

getPageCache().get("customItem"));

}

}

然后在操作插件取参数：

@Override

public void beginOperationTransaction(BeginOperationTransactionArgs e) {

super.beginOperationTransaction(e);

if ("save".equals(e.getOperationKey())) {

//取出界面传过来的参数

String customItem = this.getOption().getVariableValue("customItem");

}

}

#### 从操作插件传递参数给界面

首先在操作插件给操作Option塞参数

@Override

public void afterExecuteOperationTransaction(AfterOperationArgs e) {

if("save".equals(e.getOperationKey())&&!this.getOperationResult().getSuccessPkI ds(). isEmpty()) {

this.getOption().setVariableValue("allBillNo","");

}

}

然后在界面插件取参数

@Override

public void afterDoOperation(AfterDoOperationEventArgs

afterDoOperationEventArgs) {

super.afterDoOperation(afterDoOperationEventArgs);

FormOperate formoperate = (FormOperate)

afterDoOperationEventArgs.getSource();

if("save".equals(formoperate.getOperateKey())&&!afterDoOperationEventArgs.g etOperationResult().getSuccessPkIds().isEmpty()) {

String allBillNo = formoperate.getOption().getVariableValue("allBillNo");

}

}
