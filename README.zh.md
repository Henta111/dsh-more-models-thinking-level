# DSH 跨模型推理等级适配插件

一个可安装、可卸载的 DSH（DeepSeek Harness）插件，用于为 GPT、Codex、Gemini 以及 OpenAI-compatible 模型**按模型暴露推理（思考）等级**，让通过自定义网关 / 中转站提供的模型也能选到与自身能力匹配的推理强度。

本插件**不覆盖 Harness 核心文件**。provider 原生参数转换仍由宿主自带的 `dsh-llm-pi-ai` 负责；插件只负责补上让宿主能在模型选择器中展示推理等级所需的**能力声明**。

## 为什么需要这个插件

DSH 只有在模型带有 `reasoning` / `reasoningEfforts` 能力声明时，才会显示推理等级控件。内置目录里的模型（官方 OpenAI GPT、Gemini 等）已经声明了，所以走官方 provider 时开箱即可选等级。

问题出在**自定义网关 / 中转站**上。中转站（pptoken、one-api、new-api、LiteLLM、自建代理……）暴露的是其后端提供的一堆模型 ID。其中很多 ID——厂商变体、`-openai-compact` 这类别名、带日期后缀的快照、`codex-*` 工具模型等等——**并不在 DSH 的内置目录里**。对于内置目录未描述的模型，DSH 一律按"无推理能力"处理，模型选择器不会给出任何推理等级选项。

本插件正好补上这块缺口：把缺失的 `reasoningEfforts` 声明写入你的模型设置，使这些自定义网关模型也能选择推理等级。

> 说明：如果你只通过 DSH 内置的官方 provider、用标准目录 ID（例如 `gpt-5.4`、`o3`）接入官方模型，推理等级本来就存在，此时本插件**并非必需**。它的价值集中在"内置目录覆盖不到"的模型上——而这正是大多数中转站会暴露出来的那一类。

## 插件的作用

- 按模型声明推理等级：`off` / `minimal` / `low` / `medium` / `high` / `xhigh`。
- 向 `~/.dsh/settings.yaml` 写入 `reasoningEfforts` 映射，例如：
  ```yaml
  reasoningEfforts:
    off: null
    minimal: minimal
    low: low
    medium: medium
    high: high
    xhigh: xhigh
  ```
  每一项把**逻辑等级**（左侧）映射为宿主要发送的 **provider 原生 wire 值**（右侧）。`off` 为 `null` 表示"完全省略该参数"；`false` 表示该模型不支持推理等级。
- 宿主 `dsh-llm-pi-ai` 依据这个声明生成模型选择器里的等级选项，并在每个请求中完成实际的 wire 值转换。
- 将图片模型（`gpt-image-*`）标记为非推理模型（`reasoningEfforts: false`）。
- 在设置页新增一个"推理适配"小节，说明等级映射规则。（目前该小节仅作说明，详见"局限性"。）

## 安装

发布到 npm 后：

```
dsh plugin add dsh-more-models-thinking-level
```

或直接使用本仓库：

```
dsh plugin add https://github.com/Henta111/dsh-more-models-thinking-level
```

通过 npm 安装只会注册 bundle，**不会自动修改模型设置**。请针对目标 profile 手动执行一次随包附带的辅助脚本，然后重启 DSH：

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.dsh\profiles\desktop\node_modules\dsh-more-models-thinking-level\enable-capabilities.ps1"
```

该脚本会先创建带时间戳的备份，然后：

- `gpt-image-*` → `reasoningEfforts: false`（非推理模型）。
- `gemini-*` → `reasoningEfforts: { off: null, minimal, low, medium, high }`。
- **其余所有非图片模型 ID**——包括 `gpt-*`、`codex-*`、`claude-*`、`qwen-*`、`deepseek-*`、`moonshot-*` 以及任意自定义中转站 ID——→ 完整的 `off…xhigh` 映射。
- 已有的 `reasoningEfforts` 声明不会被覆盖（脚本只补全没有该声明、或声明为空的模型）。

## 卸载

```
dsh plugin remove dsh-more-models-thinking-level
```

如需恢复脚本写入的声明，可执行随包附带的 `disable-capabilities.ps1`。为什么需要这一步手工清理，见下面的"局限性"。

## 局限性

安装前请先阅读以下内容——其中一些会实质影响你是否能得到预期效果。

- **插件市场搜不到它。** 市场注册表由 `awesome-dsh-plugin` 生成；由于相应的 PR 尚未合并 / 通过评审，**无法通过 `dsh plugin search` 搜索到**。请按包名（npm）或仓库地址直装，并在使用前确认它已登记到你所用 profile 中。

- **辅助脚本不会被自动调用。** 安装 / 启用插件不会运行 `enable-capabilities.ps1`。你必须针对每个 profile 手动执行一次，然后重启 DSH。在此之前，插件只添加设置页小节并打印一条日志——你的模型**不会**获得推理等级。

- **宿主入口基本是空操作。** `lib/index.js` 的 `apply` 只打印 `reasoning-adapter: enabled`。真正的能力来自脚本写入 `settings.yaml` 的声明，而不是插件运行时代码。可以把本插件理解成"围绕一次设置编辑的安装器 + 说明文档"，而非一个运行时适配器。

- **会持久化修改 `settings.yaml`。** 脚本就地改写你的设置文件（之前会备份），因此它**不是**无状态的运行时覆盖。之后如果你更换 provider、切换协议、或卸载插件，注入的 `reasoningEfforts` 以及默认的 `reasoning: medium` 会一直保留，直到你手工清理。这些字段的"所有权 / 卸载清理"属于需要手动关注的事项。

- **模型能力是按 ID 猜测的。** 脚本用正则识别模型（排除图片模型和 Gemini，其余一律按 GPT 风格处理）。它**无法知道**某个模型是否真的支持某个等级。如果中转站用任意 ID 暴露了非推理模型（例如 embedding、纯视觉、普通对话模型），它们也会被加上推理声明，而严格的网关可能会拒绝这个多余的推理参数。

- **最终能否生效取决于网关。** 声明只是让等级**可选**。中转站 / 网关是否真正接受 `reasoning` / `reasoning_effort` 参数、以及具体的 wire 值，由网关决定。部分严格的网关用固定 schema 校验请求，会拒绝它不认识的字段。插件无法保证某个等级在特定中转站上一定生效。

- **仅适用 Windows PowerShell + `desktop` profile。** 辅助脚本使用 Windows PowerShell 语法与路径约定，默认针对 `desktop` profile。非 Windows 主机或其它 profile 名需要手工适配。

- **设置页只是说明性内容，不是编辑器。** 客户端小节只解释映射规则并指向模型设置页，没有 provider / 模型可视化编辑器。更精细的按 provider 或按模型控制，需要你自己编辑 `settings.yaml`。

- **尚待完善的市场化工作。** 可配置的 profile 名称、把能力配置迁移到 DSH Settings API、针对 GPT / Gemini / 普通模型的自动化测试、网关拒绝参数时的明确错误提示、以及移除对早期核心运行时补丁的依赖等，都仍未完成。

## 许可

MIT
