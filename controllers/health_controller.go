package controllers

import (
	"net/http"

	"gin-project/config"
	"gin-project/response"

	"github.com/gin-gonic/gin"
)

type HealthController struct{}

// NewHealthController 创建健康检查控制器
func NewHealthController() *HealthController {
	return &HealthController{}
}

// HealthCheck 健康检查
// @Summary 系统健康检查
// @Description 检查API服务和数据库连接状态
// @Tags 系统管理
// @Accept json
// @Produce json
// @Success 200 {object} models.HealthResponse "服务正常"
// @Failure 500 {object} models.ErrorResponse "服务异常"
// @Router /api/v1/health [get]
func (hc *HealthController) HealthCheck(c *gin.Context) {
	// 检查数据库连接
	sqlDB, err := config.DB.DB()
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "数据库连接失败", err.Error())
		return
	}

	if err := sqlDB.Ping(); err != nil {
		response.Error(c, http.StatusInternalServerError, "数据库Ping失败", err.Error())
		return
	}

	data := map[string]interface{}{
		"status":   "ok",
		"database": "connected",
		"message":  "API服务正常",
	}

	response.Success(c, data, "健康检查通过")
}
