package controllers

import (
	"gin-project/models"
	"gin-project/response"
	"gin-project/services"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

// ProductController 产品控制器
type ProductController struct {
	productService services.ProductService
}

// NewProductController 创建产品控制器实例
func NewProductController(productService services.ProductService) *ProductController {
	return &ProductController{
		productService: productService,
	}
}

// CreateProduct 创建产品
// @Summary 创建新产品
// @Description 创建一个新的产品
// @Tags 产品管理
// @Accept json
// @Produce json
// @Param product body models.CreateProductRequest true "产品信息"
// @Success 201 {object} models.SingleProductResponse "创建成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/products [post]
func (ctrl *ProductController) CreateProduct(c *gin.Context) {
	var req models.CreateProductRequest

	// 绑定请求参数
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	// 调用业务逻辑
	product, err := ctrl.productService.CreateProduct(&req)
	if err != nil {
		response.InternalServerError(c, "创建产品失败", err.Error())
		return
	}

	// 返回成功响应
	response.Created(c, product, "产品创建成功")
}

// GetProducts 获取产品列表
// @Summary 获取产品列表
// @Description 分页获取产品列表，支持页码和每页条数参数
// @Tags 产品管理
// @Accept json
// @Produce json
// @Param page query int false "页码" default(1) minimum(1)
// @Param page_size query int false "每页条数" default(10) minimum(1) maximum(100)
// @Success 200 {object} models.ProductListResponse "获取成功"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/products [get]
func (ctrl *ProductController) GetProducts(c *gin.Context) {
	// 获取分页参数
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))

	// 调用业务逻辑
	products, pagination, err := ctrl.productService.GetProducts(page, pageSize)
	if err != nil {
		response.InternalServerError(c, "获取产品列表失败", err.Error())
		return
	}

	// 返回成功响应
	c.JSON(http.StatusOK, gin.H{
		"code":       200,
		"message":    "产品列表获取成功",
		"data":       products,
		"pagination": pagination,
	})
}

// GetProductByID 根据ID获取产品
// @Summary 根据ID获取产品信息
// @Description 通过产品ID获取产品详细信息
// @Tags 产品管理
// @Accept json
// @Produce json
// @Param id path int true "产品ID" minimum(1)
// @Success 200 {object} models.SingleProductResponse "获取成功"
// @Failure 400 {object} models.ErrorResponse "产品ID格式错误"
// @Failure 404 {object} models.ErrorResponse "产品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/products/{id} [get]
func (ctrl *ProductController) GetProductByID(c *gin.Context) {
	// 获取路径参数
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "产品ID格式错误", "ID必须是正整数")
		return
	}

	// 调用业务逻辑
	product, err := ctrl.productService.GetProductByID(uint(id))
	if err != nil {
		if err.Error() == "产品不存在" {
			response.NotFound(c, err.Error())
			return
		}
		response.InternalServerError(c, "获取产品信息失败", err.Error())
		return
	}

	// 返回成功响应
	response.Success(c, product, "产品信息获取成功")
}

// UpdateProduct 更新产品信息
// @Summary 更新产品信息
// @Description 根据产品ID更新产品信息，支持部分字段更新
// @Tags 产品管理
// @Accept json
// @Produce json
// @Param id path int true "产品ID" minimum(1)
// @Param product body models.UpdateProductRequest true "更新的产品信息"
// @Success 200 {object} models.SingleProductResponse "更新成功"
// @Failure 400 {object} models.ErrorResponse "请求参数错误"
// @Failure 404 {object} models.ErrorResponse "产品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/products/{id} [put]
func (ctrl *ProductController) UpdateProduct(c *gin.Context) {
	// 获取路径参数
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "产品ID格式错误", "ID必须是正整数")
		return
	}

	// 绑定请求参数
	var req models.UpdateProductRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "请求参数格式错误", err.Error())
		return
	}

	// 调用业务逻辑
	product, err := ctrl.productService.UpdateProduct(uint(id), &req)
	if err != nil {
		if err.Error() == "产品不存在" {
			response.NotFound(c, err.Error())
			return
		}
		response.BadRequest(c, "更新产品失败", err.Error())
		return
	}

	// 返回成功响应
	response.Success(c, product, "产品信息更新成功")
}

// DeleteProduct 删除产品
// @Summary 删除产品
// @Description 根据产品ID删除产品（软删除）
// @Tags 产品管理
// @Accept json
// @Produce json
// @Param id path int true "产品ID" minimum(1)
// @Success 200 {object} models.APIResponse "删除成功"
// @Failure 400 {object} models.ErrorResponse "产品ID格式错误"
// @Failure 404 {object} models.ErrorResponse "产品不存在"
// @Failure 500 {object} models.ErrorResponse "服务器内部错误"
// @Router /api/v1/products/{id} [delete]
func (ctrl *ProductController) DeleteProduct(c *gin.Context) {
	// 获取路径参数
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.BadRequest(c, "产品ID格式错误", "ID必须是正整数")
		return
	}

	// 调用业务逻辑
	err = ctrl.productService.DeleteProduct(uint(id))
	if err != nil {
		if err.Error() == "产品不存在" {
			response.NotFound(c, err.Error())
			return
		}
		response.InternalServerError(c, "删除产品失败", err.Error())
		return
	}

	// 返回成功响应
	response.Success(c, nil, "产品删除成功")
}
