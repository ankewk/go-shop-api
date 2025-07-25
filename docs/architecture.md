# Gin MVC 架构设计

## 项目架构概述

本项目采用经典的 MVC（Model-View-Controller）分层架构，结合领域驱动设计（DDD）的思想，提供清晰的代码组织结构。

## 目录结构

```
gin-project/
├── app/                    # 应用程序主入口
│   └── app.go             # 应用初始化和依赖注入
├── config/                 # 配置相关
│   └── database.go        # 数据库配置
├── controllers/           # 控制器层 (MVC-Controller)
│   ├── user_controller.go # 用户控制器
│   └── health_controller.go # 健康检查控制器
├── middleware/            # 中间件层
│   ├── cors.go           # CORS中间件
│   └── logger.go         # 日志中间件
├── models/               # 模型层 (MVC-Model)
│   └── user.go          # 用户模型
├── repositories/         # 仓储层 (数据访问层)
│   └── user_repository.go # 用户仓储
├── response/            # 响应层 (MVC-View的JSON版本)
│   └── response.go      # 统一响应格式
├── routes/              # 路由层
│   └── routes.go        # 路由定义
├── services/            # 服务层 (业务逻辑层)
│   └── user_service.go  # 用户服务
├── scripts/             # 脚本文件
│   ├── init.sql         # 数据库初始化脚本
│   └── seed_data.go     # 测试数据脚本
├── docs/                # 文档
│   └── architecture.md  # 架构设计文档
├── main.go              # 程序入口
├── Makefile            # 项目管理命令
└── README.md           # 项目说明
```

## 分层职责

### 1. Model 层 (models/)
- **职责**: 定义数据结构和业务实体
- **包含**: 
  - 数据库实体模型
  - 请求/响应DTO
  - 数据验证规则
- **特点**: 纯数据结构，不包含业务逻辑

### 2. Repository 层 (repositories/)
- **职责**: 数据访问抽象层
- **包含**:
  - 数据库CRUD操作
  - 查询方法封装
  - 数据持久化逻辑
- **特点**: 隔离数据库操作，便于测试和切换数据源

### 3. Service 层 (services/)
- **职责**: 业务逻辑处理
- **包含**:
  - 业务规则实现
  - 数据验证
  - 事务管理
  - 复杂业务流程
- **特点**: 核心业务逻辑，可复用

### 4. Controller 层 (controllers/)
- **职责**: HTTP请求处理
- **包含**:
  - 请求参数解析
  - 调用Service层
  - 响应格式化
  - 错误处理
- **特点**: 薄薄一层，主要做请求转发

### 5. Response 层 (response/)
- **职责**: 统一响应格式 (类似MVC中的View)
- **包含**:
  - 统一响应结构
  - 错误码管理
  - 响应工具函数
- **特点**: 标准化API响应

### 6. Middleware 层 (middleware/)
- **职责**: 请求预处理和后处理
- **包含**:
  - 认证授权
  - 日志记录
  - 跨域处理
  - 限流控制
- **特点**: 横切关注点，可插拔

### 7. Routes 层 (routes/)
- **职责**: 路由定义和中间件绑定
- **包含**:
  - URL路径映射
  - 中间件链配置
  - 路由分组
- **特点**: 集中管理路由配置

### 8. App 层 (app/)
- **职责**: 应用程序启动和依赖注入
- **包含**:
  - 依赖注入容器
  - 应用初始化
  - 配置加载
- **特点**: 应用程序的组装点

## 数据流向

```
HTTP Request
    ↓
Middleware (CORS, Logger, Auth...)
    ↓
Routes (路由匹配)
    ↓
Controller (请求解析)
    ↓
Service (业务逻辑)
    ↓
Repository (数据访问)
    ↓
Database
    ↓
Repository (数据返回)
    ↓
Service (业务处理)
    ↓
Controller (响应格式化)
    ↓
Response (JSON响应)
    ↓
HTTP Response
```

## 依赖关系

```
main.go
    ↓
app/app.go (依赖注入)
    ↓
routes/ → controllers/ → services/ → repositories/ → models/
    ↓         ↓             ↓            ↓
middleware/  response/    config/     database
```

## 设计原则

### 1. 单一职责原则 (SRP)
每个层都有明确的单一职责，不承担超出其职责范围的工作。

### 2. 依赖倒置原则 (DIP)
上层模块不依赖下层模块，都依赖于抽象。通过接口定义契约。

### 3. 开闭原则 (OCP)
对扩展开放，对修改关闭。通过中间件和依赖注入实现。

### 4. 接口隔离原则 (ISP)
定义小而专一的接口，避免臃肿的接口。

## 优势

1. **清晰的代码组织**: 每个文件职责明确，易于维护
2. **高可测试性**: 各层解耦，便于单元测试
3. **易扩展性**: 通过依赖注入和接口，易于添加新功能
4. **团队协作**: 不同开发者可以专注不同层的开发
5. **代码复用**: Service层逻辑可在不同Controller中复用

## 最佳实践

1. **保持Controller薄弱**: Controller只做请求转发，不包含业务逻辑
2. **Service层事务管理**: 在Service层处理数据库事务
3. **统一错误处理**: 使用Response层统一错误响应格式
4. **接口驱动**: 定义接口约束各层交互
5. **配置外部化**: 将配置信息外部化，便于环境切换

## 扩展建议

1. 添加接口定义(interfaces/)
2. 引入依赖注入容器(如wire)
3. 添加配置管理(如viper)
4. 实现缓存层(cache/)
5. 添加事件系统(events/)
6. 引入消息队列支持 