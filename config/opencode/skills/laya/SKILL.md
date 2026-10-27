---
name: laya
description: 用 Laya 多语言决策模型对文本做快速分类、评分或判断，支持 100+ 语言。当任务涉及工单分诊、意图分类、紧急度评估、流失风险判断、内容审核或垃圾邮件检测时使用。
---

# Laya 决策技能

Laya 是一个非自回归决策模型：输入文本和结构化问题，一次性返回带校准概率的答案，不生成文本，不会产生幻觉。单次预测约 30–40ms。

## 架构

```
laya_server.py   ← 常驻进程，加载模型，监听 127.0.0.1:8008
laya_cli.py      ← 轻量客户端，发 HTTP 请求，渲染结果
```

## 首次使用：启动服务

```bash
python ~/.agents/skills/laya/laya_server.py
```

服务启动时会加载本地模型（约 1 分钟，取决于设备），加载完成后打印：

```
[server] 监听 http://127.0.0.1:8008
```

**保持这个终端窗口常开**，或放到后台：

```bash
nohup python ~/.agents/skills/laya/laya_server.py > /tmp/laya-server.log 2>&1 &
```

如果 Hugging Face 联网探测导致加载慢，可以加上离线模式：

```bash
LAYA_OFFLINE=1 python ~/.agents/skills/laya/laya_server.py
```

## 三种问题类型

| 类型 | 用途 | 需要 criteria | 输出 |
| :--- | :--- | :: | :--- |
| `choice` | 从选项中选一个 | 是（≥2 个） | 选中项 + 概率 |
| `score` | 按有序档位打分 | 是（≥2 个） | 分数 + 概率 |
| `noul` | 判断是/否 | 否 | 是概率 |

## 调用示例

```bash
# 部门分诊
python ~/.agents/skills/laya/laya_cli.py \
  "我被重复扣款了，请尽快退款" \
  -q department -c billing,technical,sales,other

# 紧急度
python ~/.agents/skills/laya/laya_cli.py \
  "系统宕机，客户无法下单" \
  -q urgency -t score -c "not urgent,soon,blocking"

# 流失风险
python ~/.agents/skills/laya/laya_cli.py "再不解决我就退订" -q churn -t noul

# JSON 输出
python ~/.agents/skills/laya/laya_cli.py \
  "查询退款进度" -q department -c billing,technical --json

# 从文件读入
cat ticket.txt | python ~/.agents/skills/laya/laya_cli.py \
  -q department -c billing,technical
```

## 结果解读

- 概率已校准，可设阈值（如 billing > 0.9 自动分诊，否则转人工）
- 置信度 < 0.6 时建议人工或更强 LLM 复核

## 注意事项

- 服务未启动时，CLI 会提示先启动 `laya_server.py`
- 模型只需加载一次，之后每次调用约几十到几百毫秒
- 输入过长会被截断，建议 --max-len 8192 或先提取关键句
- `noul` 偶尔受标签影响，异常时改用等价双选项 `choice`

## 性能特征（实测）

### 擅长场景（置信度 > 85%）

| 场景 | 示例 | 准确率 |
|-----|------|-------|
| 明确语法错误 | "syntax error near unexpected token" | 99.4% |
| 明确权限问题 | "API 返回 403 Forbidden" | 97.2% |
| 明确 Git 问题 | "git push 被拒绝，提示需要合并" | 94.8% |
| 情感极性（极端） | "差评！物流太慢了" | 91%+ |
| 明确意图 | "我要取消订单" → cancel | 100% |
| 流失判断 | "再不解决我就退订" | 84.7% |
| 紧急度（明显） | "系统宕机，客户无法下单" | 94%+ |

### 不适用场景（置信度 < 50%）

| 场景 | 问题 |
|-----|------|
| 模糊错误描述 | "代码报错" — runtime/logic/syntax 几乎平手 |
| 复杂架构问题 | "Redis 缓存击穿" — 多个标签概率接近 |
| 紧急度评估（一般） | 需要上下文（影响用户数、业务损失） |
| 中性情感 | "退款能快点吗" — 被误判为 neutral |
| 意图边界模糊 | "优惠活动"被误判为return |

## 使用建议

1. **标签定义要清晰** — 避免语义重叠的选项（如 inquiry vs return）
2. **低置信度时人工复核** — 置信度 < 0.6 的结果不可靠
3. **不适合逻辑推理** — 数学、代码分析等需要推理的任务用 LLM
4. **适合做初筛/路由** — 用于工单分类、优先级排序等粗筛场景