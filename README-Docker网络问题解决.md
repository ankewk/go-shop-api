# 🔧 Docker 网络问题解决指南

## ❌ 问题描述

如果你遇到以下错误：
```bash
# 网络连接错误
failed to set up container networking: driver failed programming external connectivity on endpoint gin-mysql-dev

# 或者IP地址池冲突错误  
failed to create network go-shop-dev-network: Error response from daemon: invalid pool request: Pool overlaps with other one on this address space
```

这些都是Docker网络问题，通常由以下原因导致：
- 端口被其他进程占用
- Docker网络IP地址池冲突
- 网络驱动程序问题
- Docker服务状态异常

## 🚀 快速解决方案

### **方案一：一键快速修复（推荐）**

```bash
# 双击运行环境管理器
environment-launcher.cmd

# 选择选项 Q: 快速修复Docker网络问题
```

或者直接运行：
```bash
quick-fix-docker.cmd
```

### **方案二：使用备用端口**

```bash
# 双击运行环境管理器
environment-launcher.cmd

# 选择选项 B: 备用端口启动开发环境
```

或者直接运行：
```bash
start-dev-backup.cmd
```

### **方案三：修复IP地址池冲突**

```bash
# 双击运行环境管理器
environment-launcher.cmd

# 选择选项 I: 修复Docker网络IP冲突问题
```

或者直接运行：
```bash
fix-network-ip-conflict.cmd
```

### **方案四：无网络模式（终极方案）**

```bash
# 双击运行环境管理器
environment-launcher.cmd

# 选择选项 N: 无网络模式启动开发环境
```

或者直接运行：
```bash
start-dev-no-network.cmd
```

### **方案五：完整诊断**

```bash
# 双击运行环境管理器
environment-launcher.cmd

# 选择选项 F: 完整诊断Docker网络问题
```

或者直接运行：
```bash
docker-network-fix-ultimate.cmd
```

## 🎯 解决步骤详解

### 步骤1：确保Docker Desktop运行
- 检查系统托盘，确保Docker图标为绿色
- 如果未启动，双击桌面上的Docker Desktop图标

### 步骤2：运行快速修复
```bash
quick-fix-docker.cmd
```

这个脚本会：
1. 清理旧容器和网络
2. 重启Docker服务
3. 使用备用端口启动服务

### 步骤3：验证修复结果
成功后你会看到：
```
✅ MySQL启动成功！端口：3308
✅ Redis启动成功！端口：6380
```

### 步骤4：使用备用配置
如果快速修复成功，请使用备用配置启动你的应用：
```bash
start-dev-backup.cmd
```

## 📋 端口对比

| 服务 | 原端口 | 备用端口 | 无网络模式 | 状态 |
|------|--------|----------|------------|------|
| MySQL | 3307 | 3308 | 3309 | ✅ 可用 |
| Redis | 6379 | 6380 | 6381 | ✅ 可用 |
| API网关 | 8080 | 8080 | - | ✅ 不变 |

## 🎯 解决方案优先级

| 优先级 | 方案 | 适用场景 | 复杂度 |
|--------|------|----------|--------|
| 🥇 第一选择 | 快速修复 | 一般网络问题 | ⭐ 简单 |
| 🥈 第二选择 | IP冲突修复 | IP地址池冲突 | ⭐⭐ 中等 |
| 🥉 第三选择 | 备用端口 | 端口占用 | ⭐⭐ 中等 |
| 🆘 最后方案 | 无网络模式 | 所有网络方案失败 | ⭐ 简单 |

## 🔧 手动解决方案

如果自动修复失败，请尝试：

### 1. 检查端口占用
```cmd
netstat -ano | findstr :3307
netstat -ano | findstr :8080
netstat -ano | findstr :6379
```

### 2. 停止占用端口的进程
```cmd
# 找到占用端口的进程ID
tasklist /FI "PID eq [进程ID]"

# 结束进程
taskkill /F /PID [进程ID]
```

### 3. 重启Docker Desktop
- 右键点击托盘中的Docker图标
- 选择"Restart Docker Desktop"

### 4. 清理Docker资源
```cmd
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker network prune -f
docker system prune -f
```

### 5. 重置Docker网络
```cmd
docker network create go-shop-dev-network
```

## 🛡️ 预防措施

### 1. 确保Docker Desktop自动启动
- Docker Desktop 设置 → General → Start Docker Desktop when you login

### 2. 检查防火墙设置
- 确保Windows防火墙允许Docker Desktop
- 添加Docker到杀毒软件白名单

### 3. 使用WSL2后端
- Docker Desktop 设置 → General → Use WSL 2 based engine

### 4. 定期清理Docker资源
```cmd
# 每周运行一次
docker system prune -f
docker network prune -f
```

## 📞 获取帮助

如果问题仍然存在：

1. **查看诊断报告**：运行完整诊断后会生成`docker-diagnosis.txt`
2. **检查Docker版本**：确保使用最新版本的Docker Desktop
3. **重启计算机**：有时候重启可以解决网络驱动问题
4. **重新安装Docker**：最后的解决方案

## ✅ 验证解决方案

成功解决后，你应该能够：

1. **查看运行的容器**：
   ```cmd
   docker ps
   ```

2. **测试数据库连接**：
   ```cmd
   docker exec -it gin-mysql-dev-backup mysql -u gin_dev_user -p
   ```

3. **访问微服务**：
   - 用户服务：http://localhost:8085/health
   - 产品服务：http://localhost:8082/health
   - 购物车服务：http://localhost:8083/health
   - 订单服务：http://localhost:8084/health

---

**🎉 现在你的开发环境应该可以正常运行了！** 