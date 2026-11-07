# 示例库

## 基础示例

### 工单分诊
```bash
python laya_cli.py "我被重复扣款了，请尽快退款" -q department -c billing,technical,sales,other
# 输出: billing (91.3%)
```

### 紧急度评估
```bash
python laya_cli.py "系统宕机，客户无法下单" -q urgency -t score -c "low,medium,high,urgent"
# 输出: urgent (94.7%)
```

### 流失判断
```bash
python laya_cli.py "再不解决我就退订" -q churn -t noul
# 输出: 是 (84.7%)
```

## 编程相关示例

### 错误分类
```bash
# 语法错误
python laya_cli.py "syntax error near unexpected token" -q type -c "syntax,runtime,logic,dependency"

# 权限问题
python laya_cli.py "API 返回 403 Forbidden" -q type -c "syntax,runtime,auth,dependency,logic"

# Git 问题
python laya_cli.py "git push 被拒绝，提示需要合并" -q type -c "git,syntax,runtime,dependency"
```

### 意图识别
```bash
# 明确意图
python laya_cli.py "我要取消订单" -q intent -c "cancel,modify,return,complaint"
# 输出: cancel (100%)

# 咨询类
python laya_cli.py "你们的会员有什么权益" -q intent -c "inquiry,purchase,return,complaint"
# 输出: inquiry (98.6%)
```

## 客服场景示例

### 情感分析
```bash
python laya_cli.py "差评！物流太慢了，客服也不理人！" -q sentiment -c "positive,neutral,negative"
# 输出: negative (91.1%)
```

### 投诉识别
```bash
python laya_cli.py "你们的产品质量太差了，用了三天就坏了！" -q sentiment -c "positive,neutral,negative"
# 输出: negative (99.5%)
```

## JSON 输出示例

```bash
python laya_cli.py "查询退款进度" -q department -c billing,technical --json
```

输出：
```json
{
  "model": "laya-rl-agent",
  "answers": {
    "department": {
      "type": "choice",
      "choice": "technical",
      "probabilities": {
        "billing": 0.0462,
        "technical": 0.9083,
        ...
      },
      "confidence": 0.7137,
      "answer_confidence": 0.9083
    }
  }
}
```

## 文件输入示例

```bash
# 从文件读取工单内容
cat tickets.txt | python laya_cli.py -q department -c billing,technical,sales
```