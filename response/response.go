package response

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

// BaseResponse 基础响应结构
type BaseResponse struct {
	Code    int         `json:"code"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

// PaginationResponse 分页响应结构
type PaginationResponse struct {
	Code       int         `json:"code"`
	Message    string      `json:"message"`
	Data       interface{} `json:"data"`
	Pagination interface{} `json:"pagination"`
}

// Success 成功响应
func Success(c *gin.Context, data interface{}, message string) {
	c.JSON(http.StatusOK, BaseResponse{
		Code:    200,
		Message: message,
		Data:    data,
	})
}

// Created 创建成功响应
func Created(c *gin.Context, data interface{}, message string) {
	c.JSON(http.StatusCreated, BaseResponse{
		Code:    201,
		Message: message,
		Data:    data,
	})
}

// SuccessWithPagination 带分页的成功响应
func SuccessWithPagination(c *gin.Context, data interface{}, pagination interface{}, message string) {
	c.JSON(http.StatusOK, PaginationResponse{
		Code:       200,
		Message:    message,
		Data:       data,
		Pagination: pagination,
	})
}

// Error 错误响应
func Error(c *gin.Context, httpCode int, message string, errorDetail string) {
	c.JSON(httpCode, BaseResponse{
		Code:    httpCode,
		Message: message,
		Error:   errorDetail,
	})
}

// BadRequest 400错误
func BadRequest(c *gin.Context, message string, errorDetail string) {
	Error(c, http.StatusBadRequest, message, errorDetail)
}

// Unauthorized 401错误
func Unauthorized(c *gin.Context, message string) {
	Error(c, http.StatusUnauthorized, message, "")
}

// Forbidden 403错误
func Forbidden(c *gin.Context, message string) {
	Error(c, http.StatusForbidden, message, "")
}

// NotFound 404错误
func NotFound(c *gin.Context, message string) {
	Error(c, http.StatusNotFound, message, "")
}

// InternalServerError 500错误
func InternalServerError(c *gin.Context, message string, errorDetail string) {
	Error(c, http.StatusInternalServerError, message, errorDetail)
}
