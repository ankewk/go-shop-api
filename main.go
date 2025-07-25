package main

import (
	"gin-project/app"
	_ "gin-project/docs"
)

// @title Gin MVC API
// @version 1.0
// @description 这是一个使用Gin框架和MVC架构构建的RESTful API服务
// @description 提供用户管理功能，支持完整的CRUD操作

// @contact.name API 支持
// @contact.url https://github.com/gin-project
// @contact.email support@gin-project.com

// @license.name MIT
// @license.url https://opensource.org/licenses/MIT

// @host localhost:8080
// @BasePath /

// @schemes http https

// @tag.name 用户管理
// @tag.description 用户相关的增删改查操作

// @tag.name 系统管理
// @tag.description 系统状态和健康检查相关接口

func main() {
	// 创建应用程序实例
	application := &app.App{}

	// 初始化应用程序
	application.Initialize()

	// 启动服务器
	application.Run(":8080")
}
