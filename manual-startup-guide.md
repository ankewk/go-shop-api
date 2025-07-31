# 🚨 Go Shop 开发环境手动启动指南

## 📋 **如果自动脚本启动失败，请按以下步骤手动启动**

### 🔍 **第一步：运行诊断工具**

双击运行：`startup-diagnosis.cmd`

这会生成 `startup-diagnosis.txt` 文件，告诉你具体哪里出了问题。

### 🛠️ **第二步：根据诊断结果解决问题**

#### **问题1：Docker Desktop未运行**
```
解决方案：
1. 双击桌面上的 Docker Desktop 图标
2. 等待启动完成（托盘图标变为绿色）
3. 如果没有图标，从开始菜单启动 Docker Desktop
```

#### **问题2：Go环境未安装**
```
解决方案：
1. 访问 https://golang.org/dl/
2. 下载 Go 1.21 或更高版本
3. 安装并重启命令行
```

#### **问题3：端口被占用**
```
解决方案：
1. 按 Win+R，输入 cmd
2. 执行：netstat -ano | findstr :3307
3. 找到占用端口的进程ID
4. 执行：taskkill /F /PID [进程ID]
```

### 🐳 **第三步：手动启动Docker服务**

打开命令行（CMD），执行以下命令：

#### **启动MySQL数据库：**
```cmd
docker run -d --name gin-mysql-manual ^
  -p 3308:3306 ^
  -e MYSQL_ROOT_PASSWORD=dev_root_123 ^
  -e MYSQL_DATABASE=gin_dev ^
  -e MYSQL_USER=gin_dev_user ^
  -e MYSQL_PASSWORD=gin_dev_pass ^
  mysql:8.0
```

#### **启动Redis缓存：**
```cmd
docker run -d --name gin-redis-manual ^
  -p 6380:6379 ^
  redis:7-alpine redis-server --requirepass dev_redis_123
```

#### **验证容器启动：**
```cmd
docker ps
```

### 🚀 **第四步：手动启动Go微服务**

每个服务需要在单独的命令行窗口中启动：

#### **启动用户服务（窗口1）：**
```cmd
cd services\user-service
set DB_HOST=localhost
set DB_PORT=3308
set DB_USER=gin_dev_user
set DB_PASSWORD=gin_dev_pass
set DB_NAME=gin_dev
set PORT=8085
set GIN_MODE=debug
go run main.go
```

#### **启动产品服务（窗口2）：**
```cmd
cd services\product-service
set DB_HOST=localhost
set DB_PORT=3308
set DB_USER=gin_dev_user
set DB_PASSWORD=gin_dev_pass
set DB_NAME=gin_dev
set PORT=8082
set GIN_MODE=debug
go run main.go
```

#### **启动购物车服务（窗口3）：**
```cmd
cd services\cart-service
set DB_HOST=localhost
set DB_PORT=3308
set DB_USER=gin_dev_user
set DB_PASSWORD=gin_dev_pass
set DB_NAME=gin_dev
set PORT=8083
set GIN_MODE=debug
go run main.go
```

#### **启动订单服务（窗口4）：**
```cmd
cd services\order-service
set DB_HOST=localhost
set DB_PORT=3308
set DB_USER=gin_dev_user
set DB_PASSWORD=gin_dev_pass
set DB_NAME=gin_dev
set PORT=8084
set GIN_MODE=debug
go run main.go
```

### ✅ **第五步：验证启动成功**

在浏览器中访问以下地址：

- 👥 用户服务：http://localhost:8085/health
- 📦 产品服务：http://localhost:8082/health
- 🛒 购物车服务：http://localhost:8083/health
- 📋 订单服务：http://localhost:8084/health

### 🔧 **常见错误及解决方案**

#### **错误1：`docker: command not found`**
```
原因：Docker未正确安装或PATH配置问题
解决：重新安装Docker Desktop或重启计算机
```

#### **错误2：`go: command not found`**
```
原因：Go未正确安装或PATH配置问题
解决：重新安装Go或配置环境变量
```

#### **错误3：`dial tcp: connect: connection refused`**
```
原因：数据库未启动或端口配置错误
解决：检查Docker容器状态，确认端口配置正确
```

#### **错误4：`bind: address already in use`**
```
原因：端口被占用
解决：更换端口或结束占用进程
```

#### **错误5：`Access denied for user`**
```
原因：数据库用户名密码错误
解决：确认使用正确的连接参数
```

### 🆘 **终极解决方案**

如果以上都不行，可以尝试：

1. **重启计算机**
2. **重新安装Docker Desktop**
3. **重新安装Go环境**
4. **检查防火墙和杀毒软件设置**

### 📞 **获取帮助**

如果仍然有问题，请提供以下信息：

1. `startup-diagnosis.txt` 文件内容
2. 具体的错误信息截图
3. 操作系统版本
4. Docker和Go的版本信息

---

**💡 提示：推荐先运行诊断工具找出具体问题，再按相应解决方案操作！** 