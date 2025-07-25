package models

import "time"

// User 用户信息模型
// @Description 用户信息模型
type User struct {
	ID        uint      `json:"id" gorm:"primaryKey" example:"1"`                                                               // 用户ID
	Name      string    `json:"name" gorm:"not null;size:100" validate:"required,min=1,max=100" example:"张三"`                   // 用户姓名
	Email     string    `json:"email" gorm:"not null;unique;size:100" validate:"required,email" example:"zhangsan@example.com"` // 邮箱地址
	Phone     string    `json:"phone" gorm:"size:20" example:"13888888888"`                                                     // 手机号码
	Avatar    string    `json:"avatar" gorm:"size:255" example:"https://example.com/avatar.jpg"`                                // 头像URL
	Status    int       `json:"status" gorm:"default:1" example:"1"`                                                            // 用户状态：1正常，0禁用
	CreatedAt time.Time `json:"created_at" example:"2024-01-01T12:00:00Z"`                                                      // 创建时间
	UpdatedAt time.Time `json:"updated_at" example:"2024-01-01T12:00:00Z"`                                                      // 更新时间
}

// CreateUserRequest 创建用户的请求参数
// @Description 创建用户的请求参数
type CreateUserRequest struct {
	Name  string `json:"name" validate:"required,min=1,max=100" example:"张三"`            // 用户姓名（必填，1-100字符）
	Email string `json:"email" validate:"required,email" example:"zhangsan@example.com"` // 邮箱地址（必填，格式验证）
	Phone string `json:"phone" validate:"max=20" example:"13888888888"`                  // 手机号码（可选，最多20字符）
}

// UpdateUserRequest 更新用户的请求参数
// @Description 更新用户的请求参数
type UpdateUserRequest struct {
	Name   *string `json:"name,omitempty" validate:"omitempty,min=1,max=100" example:"李四"`        // 用户姓名（可选）
	Email  *string `json:"email,omitempty" validate:"omitempty,email" example:"lisi@example.com"` // 邮箱地址（可选）
	Phone  *string `json:"phone,omitempty" validate:"omitempty,max=20" example:"13999999999"`     // 手机号码（可选）
	Avatar *string `json:"avatar,omitempty" example:"https://example.com/new-avatar.jpg"`         // 头像URL（可选）
	Status *int    `json:"status,omitempty" validate:"omitempty,oneof=0 1" example:"1"`           // 状态（可选）
}

// UserListResponse 用户列表响应
// @Description 用户列表响应
type UserListResponse struct {
	Code       int             `json:"code" example:"200"`
	Data       []User          `json:"data"`
	Message    string          `json:"message" example:"用户列表获取成功"`
	Pagination *PaginationInfo `json:"pagination"`
}

// SingleUserResponse 单个用户响应
// @Description 单个用户响应
type SingleUserResponse struct {
	Code    int    `json:"code" example:"200"`
	Data    User   `json:"data"`
	Message string `json:"message" example:"用户信息获取成功"`
}
