# 故障排查

## 常见问题

### Q1: 服务启动失败

**现象**: `laya_server.py` 启动时报错

**排查步骤**:
```bash
# 1. 检查依赖是否安装
pip show laya transformers tokenizers

# 2. 检查模型目录是否存在
ls ~/laya-multilingual/multilingual/

# 3. 查看完整错误日志
python ~/.agents/skills/laya/laya_server.py 2>&1 | head -50
```

**解决方案**:
```bash
# 重新安装依赖
uv pip install --system laya --break-system-packages --no-deps
uv pip install --system transformers tokenizers numpy huggingface_hub --break-system-packages
```

### Q2: 连接被拒绝

**现象**: `无法连接 http://127.0.0.1:8008`

**排查步骤**:
```bash
# 检查服务是否在运行
pgrep -f laya_server.py

# 检查端口是否监听
netstat -tlnp | grep 8008
```

**解决方案**:
```bash
# 杀掉残留进程
pkill -f laya_server.py

# 重新启动
python ~/.agents/skills/laya/laya_server.py &
```

### Q3: 预测结果不准确

**可能原因**:
1. 标签定义不清
2. 输入文本过于模糊
3. 模型未针对特定领域优化

**解决方案**:
```bash
# 尝试更具体的标签
python laya_cli.py "我要退货" -q intent -c "退货,换货,维修,咨询"

# 添加更多上下文
python laya_cli.py "订单12345退货七天未到账" -q urgency -t score -c "low,medium,high,urgent"

# 检查置信度，低置信度时人工复核
python laya_cli.py "..." -q ... --json
# 查看 confidence 字段
```

### Q4: 性能问题（响应慢）

**排查步骤**:
```bash
# 检查模型加载状态
curl http://127.0.0.1:8008/health

# 查看服务器资源占用
htop | grep python
```

**优化建议**:
1. 使用离线模式：`LAYA_OFFLINE=1 python laya_server.py`
2. 减少输入长度：提取关键句再送检
3. 批量请求时复用连接

## 监控建议

### 健康检查
```bash
# 定期检查服务状态
while true; do
  curl -s http://127.0.0.1:8008/health && echo "OK" || echo "DOWN"
  sleep 60
done
```

### 日志收集
```bash
# 将服务日志重定向到文件
nohup python ~/.agents/skills/laya/laya_server.py > /tmp/laya-server.log 2>&1 &

# 实时查看日志
tail -f /tmp/laya-server.log
```

## 联系支持

如果以上方法无法解决问题，请提供以下信息：
1. 错误日志（`/tmp/laya-server.log`）
2. 操作系统版本
3. Python 版本
4. 完整的调用命令和参数