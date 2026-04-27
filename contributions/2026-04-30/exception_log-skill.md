# java-plugin-pairing Skill 贡献整理

- 提交人：luofuwei
- 日期：2026-04-27
- 关键词苍穹、KDException、日志规范、协作偏好、异常处理
- 适用范围：在二开插件中做代码修改、review、工具类编写、异常处理清理或按固定协作习惯

## 问题场景

团队在这个仓库里协作时，不只是要“把代码改对”，还要遵守特定的沟通节奏、日志规范和 `KDException` / `ErrorCode` 约束。这个 skill 的价值在于把这些偏好前置，降低返工。

## 前置条件

- 任务发生在 编写苍穹\星瀚\EAS\等二开插件之中
- 代码属于业务插件、工具类、异常处理或日志处理范畴
- 需要遵守项目已有风格，而不是大范围重构
- 处理规范
  - 统一使用KDException，可自定义子异常；
  - 只catch需要处理的异常，其它放过 (任其往上抛)；
  - catch异常后，再往上抛出异常，通常不需要记录日志；
  - catch异常后，未往上抛出异常，务必记录日志；
  - UI显示的异常信息，应是业务语义，让用户知道下一步该怎么处理。

## 解决方案

先读现有代码，再做短进度同步，直接实现目标变更；异常处理统一靠 `KDException` / `ErrorCode`，日志统一靠 `kd.bos.logging.Log` 和 `LogFactory`。

## 关键代码 / API

`ErrorCode` 集中定义，业务校验直接抛 `KDException`，只 `catch` 当前层真正关心的业务异常，系统异常统一包装为业务异常并保留 `cause`。

```java
public final class FIGLErrorCode {

    private static ErrorCode create(String code, String message) {
        return new ErrorCode("fi.gl." + code, message);
    }

    public static final ErrorCode voucherNotInCurrentPeriod =
            create("voucherNotInCurrentPeriod", "凭证%s不在当前期间，不可编辑。");

    public static final ErrorCode doMyJobFailed =
            create("doMyJobFailed", "任务%s执行失败：%s");
}

// 1. 业务校验失败时，直接抛业务异常
if (!isInCurrentPeriod) {
    throw new KDException(FIGLErrorCode.voucherNotInCurrentPeriod, voucherNumber);
}

// 2. 只 catch 当前层真正需要处理的业务异常；不关心的异常继续往上抛
try {
    callMyBizMethod();
} catch (KDException e) {
    ErrorCode errorCode = e.getErrorCode();
    if (FIGLErrorCode.voucherNotInCurrentPeriod.equals(errorCode)) {
        // 做异常收尾处理
        // ...
    }
    throw e;
}

// 3. 系统异常不要吞，统一包装成业务异常并保留原始 cause
try {
    doMyJob();
} catch (KDException e) {
    throw e;
} catch (Exception e) {
    throw new KDException(e, FIGLErrorCode.doMyJobFailed, "jobname", e.getMessage());
}
```

## 注意事项 / 常见误区

- 误区 1：一改代码就顺手做大范围重构。这个 skill 明确要求改动范围收紧。
- 误区 2：catch 后重复打 error 日志再继续抛出，造成日志噪音。

## 可整理进正式 Skill 的结论

- 这类仓库里的协作规范本身就是可复用资产，应写进 skill，而不是靠口头约定。
- `KDException`、`ErrorCode`、`LogFactory` 三套规则要同时收口，否则实现风格会持续漂移。
- 先读代码、短同步、后改动，比先输出大段方案更符合这个仓库的工作方式。

