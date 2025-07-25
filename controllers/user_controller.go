package controllers

import (
	"net/http"
	"strconv"

	"gin-project/models"
	"gin-project/response"
	"gin-project/services"

	"github.com/gin-gonic/gin"
)

type UserController struct {
	userService *services.UserService
}

// NewUserController 创建用户控制器
func NewUserController(userService *services.UserService) *UserController {
	return &UserController{
		userService: userService,
	}
}

// GetUsers 获取用户列表
// @Summary 获取用户列表
// @Description 分页获取用户列表，支持页码和每页条数参数
// @Tags 用户管理
// @Accept json
// @Produce json
// @Param page query int false "页码" default(1) minimum(1)
// @Param page_size query int false "每页条数" default(10) minimum(1) maximum(100)
// @Success 200 {object} models.UserListResponse "获取成功"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/users [get]
func (uc *UserController) GetUsers(c *gin.Context) {
	// 获取分页参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))

	// 参数验证
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 10
	}

	// 调用服务层
	users, total, err := uc.userService.GetUsers(page, pageSize)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "获取用户列表失败", err.Error())
		return
	}

	// 构建分页信息
	pagination := map[string]interface{}{
		"page":      page,
		"page_size": pageSize,
		"total":     total,
	}

	response.SuccessWithPagination(c, users, pagination, "用户列表获取成功")
}

// CreateUser 创建用户
// @Summary 创建新用户
// @Description 创建一个新的用户账户
// @Tags 用户管理
// @Accept json
// @Produce json
// @Param user body models.CreateUserRequest true "用户信息"
// @Success 201 {object} models.SingleUserResponse "创建成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/users [post]
func (uc *UserController) CreateUser(c *gin.Context) {
	var req models.CreateUserRequest

	// 绑定和验证请求数据
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "请求参数错误", err.Error())
		return
	}

	// 调用服务层创建用户
	user, err := uc.userService.CreateUser(&req)
	if err != nil {
		response.Error(c, http.StatusInternalServerError, "创建用户失败", err.Error())
		return
	}

	response.Success(c, user, "用户创建成功")
}

// GetUserByID 根据ID获取用户
// @Summary 根据ID获取用户信息
// @Description 通过用户ID获取用户详细信息
// @Tags 用户管理
// @Accept json
// @Produce json
// @Param id path int true "用户ID" minimum(1)
// @Success 200 {object} models.SingleUserResponse "获取成功"
// @Failure 400 {object} models.ErrorResponse "用户ID格式错误"
// @Failure 404 {object} models.ErrorResponse "用户不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/users/{id} [get]
func (uc *UserController) GetUserByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "用户ID格式错误", "ID必须是数字")
		return
	}

	// 调用服务层
	user, err := uc.userService.GetUserByID(uint(id))
	if err != nil {
		if err.Error() == "user not found" {
			response.Error(c, http.StatusNotFound, "用户不存在", "")
			return
		}
		response.Error(c, http.StatusInternalServerError, "获取用户失败", err.Error())
		return
	}

	response.Success(c, user, "用户信息获取成功")
}

// UpdateUser 更新用户
// @Summary 更新用户信息
// @Description 根据用户ID更新用户信息，支持部分字段更新
// @Tags 用户管理
// @Accept json
// @Produce json
// @Param id path int true "用户ID" minimum(1)
// @Param user body models.UpdateUserRequest true "更新的用户信息"
// @Success 200 {object} models.SingleUserResponse "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "用户不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/users/{id} [put]
func (uc *UserController) UpdateUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "用户ID格式错误", "ID必须是数字")
		return
	}

	var req models.UpdateUserRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, http.StatusBadRequest, "请求参数错误", err.Error())
		return
	}

	// 调用服务层
	user, err := uc.userService.UpdateUser(uint(id), &req)
	if err != nil {
		if err.Error() == "user not found" {
			response.Error(c, http.StatusNotFound, "用户不存在", "")
			return
		}
		response.Error(c, http.StatusInternalServerError, "更新用户失败", err.Error())
		return
	}

	response.Success(c, user, "用户信息更新成功")
}

// DeleteUser 删除用户
// @Summary 删除用户
// @Description 根据用户ID删除用户（软删除）
// @Tags 用户管理
// @Accept json
// @Produce json
// @Param id path int true "用户ID" minimum(1)
// @Success 200 {object} models.APIResponse "删除成功"
// @Failure 400 {object} models.ErrorResponse "用户ID格式错误"
// @Failure 404 {object} models.ErrorResponse "用户不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/users/{id} [delete]
func (uc *UserController) DeleteUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.Error(c, http.StatusBadRequest, "用户ID格式错误", "ID必须是数字")
		return
	}

	// 调用服务层
	err = uc.userService.DeleteUser(uint(id))
	if err != nil {
		if err.Error() == "user not found" {
			response.Error(c, http.StatusNotFound, "用户不存在", "")
			return
		}
		response.Error(c, http.StatusInternalServerError, "删除用户失败", err.Error())
		return
	}

	response.Success(c, nil, "用户删除成功")
}
