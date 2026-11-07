# Laya 快速开始

## 一键启动

```bash
# 启动服务（首次约需 1 分钟加载模型）
LAYA_OFFLINE=1 python ~/.agents/skills/laya/laya_server.py &

# 验证服务是否就绪
curl http://127.0.0.1:8008/health
```

## 最简用法

```bash
# 分类：从多个选项中选一个
python ~/.agents/skills/laya/laya_cli.py "我要退款" -q intent -c purchase,return,complaint

# 评分：按等级打分
python ~/.agents/skills/laya/laya_cli.py "系统宕机" -q urgency -t score -c "low,high,urgent"

# 判断：是/否问题
python ~/.agents/skills/laya/laya_cli.py "我不满意" -q churn -t noul
```

## 结果含义

```
结论: billing (置信度 91.28%)
概率分布:
  billing  91.28%  ██████████████████
  other    6.23%  █
  ...
整体置信度: 73.6%
```

- **结论**：预测概率最高的选项
- **置信度**：模型对预测结果的把握程度
- **整体置信度 < 60%**：建议人工复核

## 何时使用 Laya

| ✅ 适合 | ❌ 不适合 |
|---------|----------|
| 工单自动分诊 | 需要代码理解的 bug 分析 |
| 紧急度初步筛选 | 数学推理、逻辑判断 |
| 流失风险判断 | 复杂架构问题诊断 |
| 情感极性分类 | 模糊/歧义描述 |
| 意图快速识别 | 需要上下文的多轮对话 |

## 下一步

- 📖 [使用指南](./guides/usage.md) — 详细参数说明
- 📋 [示例库](./examples/) — 常见场景的调用示例
- 📊 [性能基准](./references/benchmarks.md) — 各场景的实测准确率