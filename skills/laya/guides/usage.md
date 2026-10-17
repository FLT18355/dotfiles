# 使用指南

## 参数详解

### 基本参数

| 参数 | 说明 | 示例 |
|-----|------|------|
| `-q` | 问题类型 | `department`, `urgency`, `churn`, `sentiment`, `intent` |
| `-t` | 问题类型（choice/score/noul） | `choice`, `score`, `noul` |
| `-c` | 选项列表（逗号分隔） | `billing,technical,sales` |
| `--json` | 输出 JSON 格式 | 便于程序解析 |
| `--max-len` | 最大输入长度 | 默认截断，建议设为 8192 |

### 问题类型说明

#### choice — 从选项中选择
用于将文本归类到预设类别。

```bash
python laya_cli.py "我要退款" -q intent -c purchase,return,complaint
```

#### score — 按等级评分
用于对文本进行有序评分（0~N）。

```bash
python laya_cli.py "系统宕机" -q urgency -t score -c "low,medium,high,urgent"
```

#### noul — 是/否判断
用于二元判断，输出"是"的概率。

```bash
python laya_cli.py "我不满意" -q churn -t noul
```

## 标签设计原则

### ✅ 好的标签设计

```bash
# 清晰互斥的选项
-c "syntax,runtime,dependency,config"

# 有序的评分档位
-c "not urgent,soon,blocking"

# 明确的二元判断
# 无需 -c，直接问
```

### ❌ 避免的标签设计

```bash
# 语义重叠
-c "inquiry,question"  # 两个都是询问
-c "return,cancel"     # 在某些场景难以区分

# 选项过多
-c "a,b,c,d,e,f,g,h,i,j"  # 超过 5 个选项准确率下降

# 模糊标签
-c "bad,not_bad"  # 不如具体描述
```

## 阈值建议

| 场景 | 推荐阈值 | 动作 |
|-----|---------|------|
| 自动分诊 | > 0.9 | 直接路由 |
| 一般分类 | > 0.7 | 自动处理 |
| 人工复核 | < 0.6 | 转人工或 LLM |
| 紧急度排序 | > 0.8 | 优先处理 |

## 常见模式

### 工单分诊流水线

```bash
# 第一步：判断紧急度
URGENT=$(python laya_cli.py "$text" -q urgency -t score -c "low,medium,high,urgent" --json)

# 第二步：确定部门（仅非紧急）
if [ $URGENT <= 1 ]; then
    DEPT=$(python laya_cli.py "$text" -q department -c "billing,technical,sales,other" --json)
fi
```

### 情感过滤

```bash
# 只处理负面反馈
SENTIMENT=$(python laya_cli.py "$text" -q sentiment -c "positive,neutral,negative" --json)
# 如果 negative > 0.8，标记为需跟进
```

### 流失预警

```bash
# 判断流失风险
RISK=$(python laya_cli.py "$text" -q churn -t noul --json)
# 如果 是概率 > 0.7，触发挽留流程
```