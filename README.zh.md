# DSH 跨模型推理等级适配插件

这是一个可安装、可卸载的 DSH bundle。它不覆盖 Harness 核心文件；provider 原生参数转换继续由宿主自带 `dsh-llm-pi-ai` 负责。

插件为 DeepSeek Harness 中的 GPT、Codex、Gemini 和 OpenAI-compatible 模型按模型暴露推理等级（`off` / `minimal` / `low` / `medium` / `high` / `xhigh`），让自定义模型网关接入后也能选择合适的推理强度。

# 效果图

<img width="432" height="194" alt="image" src="https://github.com/user-attachments/assets/00198ec6-a8eb-4002-91b7-0149b8621f32" />
注：原版导入其他模型无思考等级可选
<img width="432" height="194" alt="image" src="https://github.com/user-attachments/assets/57aecb45-596c-40a2-96eb-f73db2fb0634" />

## 安装（插件市场）

发布到 npm 后：

```
dsh plugin add dsh-more-models-thinking-level
```

或直接使用本仓库：

```
dsh plugin add https://github.com/Henta111/dsh-more-models-thinking-level
```

## 卸载

```
dsh plugin remove dsh-more-models-thinking-level
```

## 模型设置

模型设置中的 `reasoningEfforts` 可填写：

```
low=low,medium=medium,high=high
```

左侧是逻辑等级，右侧是 provider 原生 wire 值。空值回到默认能力，`false` 表示模型不支持推理等级。

## 许可

MIT
