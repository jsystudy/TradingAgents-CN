# Render 部署指南

## 前置准备

### 1. 创建 MongoDB Atlas 免费数据库

Render 不提供免费 MongoDB，需要使用 MongoDB Atlas 免费版：

1. 访问 https://www.mongodb.com/atlas
2. 注册免费账户
3. 创建免费集群（M0 Sandbox，512MB 存储）
4. 创建数据库用户（用户名和密码）
5. 设置网络访问（允许所有 IP：0.0.0.0/0）
6. 获取连接字符串（格式：mongodb+srv://username:password@cluster.mongodb.net/tradingagents）

### 2. 注册 Render 账户

1. 访问 https://render.com
2. 使用 GitHub 账户登录

## 部署步骤

### 步骤 1：连接 GitHub 仓库

1. 登录 Render Dashboard
2. 点击 "New +" -> "Blueprint"
3. 连接 GitHub 仓库：hsliuping/TradingAgents-CN
4. 选择 "main" 分支

### 步骤 2：配置环境变量

在 Render Dashboard 中为后端服务设置以下环境变量：

#### 必需的环境变量：
```
MONGODB_URL=mongodb+srv://username:password@cluster.mongodb.net/tradingagents
```

#### 可选的环境变量（根据需要配置）：
```
DASHSCOPE_API_KEY=your_dashscope_api_key_here
DEEPSEEK_API_KEY=your_deepseek_api_key_here
OPENAI_API_KEY=your_openai_api_key_here
GOOGLE_API_KEY=your_google_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here
TUSHARE_TOKEN=your_tushare_token_here
```

### 步骤 3：部署服务

1. 点击 "Apply" 开始部署
2. 等待构建完成（约 5-10 分钟）
3. 部署成功后，Render 会提供访问域名

## 访问地址

部署完成后，您将获得以下访问地址：

- 前端：https://tradingagents-frontend.onrender.com
- 后端：https://tradingagents-backend.onrender.com

## 默认登录账号

- 用户名：admin
- 密码：admin123

## 注意事项

1. **免费计划限制**：
   - 服务在 15 分钟无活动后会休眠
   - 首次访问可能需要等待 30 秒左右唤醒
   - 每月 750 小时免费运行时间

2. **数据库限制**：
   - MongoDB Atlas 免费版：512MB 存储
   - Redis 免费版：25MB 存储

3. **如果部署失败**：
   - 检查环境变量是否正确配置
   - 查看 Render 日志获取错误信息
   - 确保 MongoDB Atlas 网络访问已设置为允许所有 IP

## 故障排除

### 问题：服务无法启动
- 检查 Docker 构建日志
- 确认环境变量格式正确

### 问题：数据库连接失败
- 验证 MongoDB 连接字符串
- 检查 MongoDB Atlas 网络访问设置

### 问题：前端无法访问后端
- 确认 CORS_ORIGINS 环境变量包含前端域名
- 检查 VITE_API_BASE_URL 是否正确

### 问题：管理员用户创建失败
- 检查 MongoDB 连接字符串是否正确
- 确保 MongoDB Atlas 用户有读写权限
- 查看后端日志获取详细错误信息

## 部署后验证

### 1. 检查服务状态
- 在 Render Dashboard 中查看服务状态
- 确保所有服务都显示 "Live"

### 2. 测试 API 端点
```bash
# 健康检查
curl https://tradingagents-backend.onrender.com/api/health

# 用户登录
curl -X POST https://tradingagents-backend.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

### 3. 访问前端
- 打开 https://tradingagents-frontend.onrender.com
- 使用 admin/admin123 登录
- 测试股票分析功能

## 更新部署

当代码更新时：
1. 推送代码到 GitHub
2. Render 会自动重新部署（如果启用了自动部署）
3. 或者手动触发部署：Render Dashboard -> 服务 -> Manual Deploy

## 监控和日志

### 查看日志
- Render Dashboard -> 服务 -> Logs
- 实时查看应用日志和错误信息

### 性能监控
- Render Dashboard -> 服务 -> Metrics
- 监控 CPU、内存使用情况

## 扩展建议

如果需要更好的性能：
1. 升级到付费计划（$7/月）
2. 使用独立的 MongoDB Atlas 集群
3. 配置自定义域名
4. 启用 CDN 加速
