# Media.io

通过 `https://mcp.media.io/mcp` 使用七类静态生成操作：文生图、图生图、文生视频、图生视频、参考生视频、动作控制、图片加音频音乐视频。2026-10-15 冻结目录覆盖 119 个模型操作条目（包含历史 115 条）；参数范围以实际工具 schema 为准。OAuth 及 DCR 通过现有服务发现，不需要本地 CLI。

用户请求生成且已有积分/权益足够时，直接创建并正常消耗积分。`estimate_credits` 仅用于主动询价，不是前置步骤。插件不提供积分、订阅或数字商品交易入口。

用户查看历史生成任务时调用 `list_generations_card`，直接展示状态、时间和可用产物；默认展示第一页 10 条，翻页保留筛选条件。后台核对仍使用无 UI 的 `list_generations`。

用户查看账号、积分或会员时调用 `get_account_card`，卡片显示当前已授权账号的昵称、邮箱、已有会员状态与积分，仅提供由用户点击的 `My Assets` 资产页入口。身份仅通过工具结果 `_meta["mediaio/accountIdentity"]` 交付组件，不进入模型可见的 `content`、`structuredContent` 或工具定义；缺失昵称显示通用名称，缺失邮箱隐藏该行。`get_account` 仍只返回权益与积分数据。卡片不自动导航，不提供主页、购买、升级或账户管理按钮。

## 文件与分发

| 文件 | 用途 |
| --- | --- |
| `plugin.json` / `mcp.json` | 公开 portable 插件身份、审核预期用例与远程 MCP 配置 |
| `.codex-plugin/plugin.json` / `.mcp.json` | 本地 Codex 配置；与 portable manifest 保持版本和展示信息一致 |
| `.app.json` | 保留的历史本地 App 映射；当前 manifest 不引用，公开 ZIP 不包含 |
| `.agents/plugins/marketplace.json` | 本地 marketplace |
| `skills/mediaio-aigc/` | 静态多模型工具编排与生成的模型目录 |
| `chatgpt-app-submission.json` | Apps submission 导入材料：App Info、17 个工具注解理由及五正三负预期用例，覆盖七类动作及多模型选型；单独上传，不进入公开 ZIP，不代表真实验收已通过 |
| `package-web.sh` | 按明确文件清单生成公开远程 MCP ZIP |

此目录作为 MCP 插件源码根导出到 `media-io/plugin-mcp`。源码快照和公开送审 ZIP 用途不同：前者保留本地配置及维护工具，后者只包含 portable manifest、远程 MCP、Skill、许可和品牌资源。公开包不包含 App ID、hooks、辅助脚本、测试账号或凭据。

## 验证与打包

在主仓执行：

```bash
node --test deploy/*.test.mjs
bash plugin-mcp-main/package-web.sh /tmp/media-io-remediation.zip
```

公开格式依据 [OpenAI 打包规范](https://developers.openai.com/plugins/build/plugins) 和 [发布规范](https://developers.openai.com/plugins/deploy/submission)。`extensions.com.openai` 存在时不会与 Codex overlay 合并，因此公开包自行包含完整展示与审核设置。

首次 MCP 审核需要五个正向、三个负向用例、真实可访问演示录像，以及后台安全表单中的审核访问方式。JSON 用例描述的是预期行为，不能当作已实跑通过。正式送审前完成真实账号生成、扣费、素材权限、组件及宿主上传闭环；补齐录像，再部署同一 `/mcp`、重新扫描和提交。当前构建不代替这些步骤。

服务的两个 UI 资源使用部署环境生效的 `MCP_PUBLIC_BASE_URL` 作为 `ui.domain` 和 `openai/widgetDomain`，灰度为 `https://mcp-mcp.media.io`、生产为 `https://mcp.media.io`；图片、视频等外部资源仍由各组件的 CSP 白名单控制。Apollo 配置在启动时加载，更新后需重启服务。在 ChatGPT 刷新连接和工具扫描后，分别查看账号卡、历史卡及已有完成任务的结果卡，确认卡片、媒体、空态和翻页正常；这些只读渲染检查无需创建新任务或消耗生成积分。

## 本地开发

在本目录运行 `codex plugin marketplace add .` 和 `codex plugin add media-io@media-io`。插件使用远程服务；当前服务器尚未部署静态契约时，新 Skill 不能被认定已完成线上验证。

产品：[Media.io](https://www.media.io/ai/home)；隐私：[Privacy](https://www.media.io/privacy.html)；条款：[Terms](https://www.media.io/terms-of-service.html)。许可见 [LICENSE](LICENSE)。

## 多模型契约维护

生成请求为 `{request: {model, prompt?, inputs?, options?}, client_request_id, approved_credit?}`，询价为 `{request: {operation, generation: <同一业务 request>}}`。字段不是开放字典，必须满足所选模型的静态分支；一次调用创建一个任务。模型清单及 schema 从 MCP 仓内净化快照离线编译，不随线上目录自动扩充。

在 `media-plugin-mcp` 执行 `node scripts/generate-model-contracts.mjs --skill-dir ../media-plugin-main/plugin-mcp-main/skills/mediaio-aigc` 同步目录；加 `--check` 校验产物。来源、参数限制交集、119 条矩阵和待完成的真实宿主/计费验收见 [实施与验证记录](../../media-plugin-api/docs/mcp/MCP多模型实施与验证记录.md)。
