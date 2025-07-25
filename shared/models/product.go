package models

import "time"

// Product 产品模型
// @Description 产品信息模型
type Product struct {
	ID          uint      `json:"id" gorm:"primaryKey" example:"1"`                                                    // 产品ID
	Name        string    `json:"name" gorm:"not null;size:100" validate:"required,min=1,max=100" example:"iPhone 15"` // 产品名称
	Description string    `json:"description" gorm:"type:text" example:"最新款iPhone手机"`                                  // 产品描述
	Price       float64   `json:"price" gorm:"not null" validate:"required,min=0" example:"8999.99"`                   // 产品价格
	Stock       int       `json:"stock" gorm:"not null;default:0" validate:"min=0" example:"100"`                      // 库存数量
	Category    string    `json:"category" gorm:"size:50" example:"电子产品"`                                              // 产品分类
	Status      int       `json:"status" gorm:"default:1" example:"1"`                                                 // 状态：1正常，0下架
	CreatedAt   time.Time `json:"created_at" example:"2024-01-01T12:00:00Z"`                                           // 创建时间
	UpdatedAt   time.Time `json:"updated_at" example:"2024-01-01T12:00:00Z"`                                           // 更新时间
}

// CreateProductRequest 创建产品的请求参数
// @Description 创建产品的请求参数
type CreateProductRequest struct {
	Name        string  `json:"name" validate:"required,min=1,max=100" example:"iPhone 15"` // 产品名称（必填）
	Description string  `json:"description" example:"最新款iPhone手机"`                          // 产品描述（可选）
	Price       float64 `json:"price" validate:"required,min=0" example:"8999.99"`          // 产品价格（必填）
	Stock       int     `json:"stock" validate:"min=0" example:"100"`                       // 库存数量（可选，默认0）
	Category    string  `json:"category" example:"电子产品"`                                    // 产品分类（可选）
}

// UpdateProductRequest 更新产品的请求参数
// @Description 更新产品的请求参数
type UpdateProductRequest struct {
	Name        *string  `json:"name,omitempty" validate:"omitempty,min=1,max=100" example:"iPhone 15 Pro"` // 产品名称（可选）
	Description *string  `json:"description,omitempty" example:"升级版iPhone手机"`                               // 产品描述（可选）
	Price       *float64 `json:"price,omitempty" validate:"omitempty,min=0" example:"9999.99"`              // 产品价格（可选）
	Stock       *int     `json:"stock,omitempty" validate:"omitempty,min=0" example:"50"`                   // 库存数量（可选）
	Category    *string  `json:"category,omitempty" example:"高端电子产品"`                                       // 产品分类（可选）
	Status      *int     `json:"status,omitempty" validate:"omitempty,oneof=0 1" example:"1"`               // 状态（可选）
}

// ProductListResponse 产品列表响应
// @Description 产品列表响应
type ProductListResponse struct {
	Code       int             `json:"code" example:"200"`
	Data       []Product       `json:"data"`
	Message    string          `json:"message" example:"产品列表获取成功"`
	Pagination *PaginationInfo `json:"pagination"`
}

// SingleProductResponse 单个产品响应
// @Description 单个产品响应
type SingleProductResponse struct {
	Code    int     `json:"code" example:"200"`
	Data    Product `json:"data"`
	Message string  `json:"message" example:"产品信息获取成功"`
}
