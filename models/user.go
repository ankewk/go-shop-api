package models

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
// @Description 用户信息模型
type User struct {
	ID        uint           `json:"id" gorm:"primaryKey" example:"1"`                                                                   // 用户ID
	Name      string         `json:"name" gorm:"not null;size:100" binding:"required" example:"张三"`                                      // 用户姓名
	Email     string         `json:"email" gorm:"not null;uniqueIndex;size:255" binding:"required,email" example:"zhangsan@example.com"` // 邮箱地址
	Phone     string         `json:"phone" gorm:"size:20" example:"13888888888"`                                                         // 手机号码
	Avatar    string         `json:"avatar" gorm:"size:500" example:"https://example.com/avatar.jpg"`                                    // 头像URL
	Status    int            `json:"status" gorm:"default:1;comment:用户状态 1:正常 0:禁用" example:"1"`                                         // 用户状态：1正常，0禁用
	CreatedAt time.Time      `json:"created_at" example:"2024-01-01T12:00:00Z"`                                                          // 创建时间
	UpdatedAt time.Time      `json:"updated_at" example:"2024-01-01T12:00:00Z"`                                                          // 更新时间
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`                                                                                     // 删除时间（软删除）
}

// TableName 指定表名
func (User) TableName() string {
	return "users"
}

// CreateUserRequest 创建用户请求结构体
// @Description 创建用户的请求参数
type CreateUserRequest struct {
	Name  string `json:"name" binding:"required,min=1,max=100" example:"张三"`            // 用户姓名（必填，1-100字符）
	Email string `json:"email" binding:"required,email" example:"zhangsan@example.com"` // 邮箱地址（必填，格式验证）
	Phone string `json:"phone" binding:"max=20" example:"13888888888"`                  // 手机号码（可选，最多20字符）
}

// UpdateUserRequest 更新用户请求结构体
// @Description 更新用户的请求参数
type UpdateUserRequest struct {
	Name  *string `json:"name" binding:"omitempty,min=1,max=100" example:"李四"`        // 用户姓名（可选）
	Email *string `json:"email" binding:"omitempty,email" example:"lisi@example.com"` // 邮箱地址（可选）
	Phone *string `json:"phone" binding:"omitempty,max=20" example:"13999999999"`     // 手机号码（可选）
}

// UserResponse 用户响应结构体
// @Description 用户信息响应
type UserResponse struct {
	ID        uint      `json:"id" example:"1"`                                  // 用户ID
	Name      string    `json:"name" example:"张三"`                               // 用户姓名
	Email     string    `json:"email" example:"zhangsan@example.com"`            // 邮箱地址
	Phone     string    `json:"phone" example:"13888888888"`                     // 手机号码
	Avatar    string    `json:"avatar" example:"https://example.com/avatar.jpg"` // 头像URL
	Status    int       `json:"status" example:"1"`                              // 用户状态
	CreatedAt time.Time `json:"created_at" example:"2024-01-01T12:00:00Z"`       // 创建时间
	UpdatedAt time.Time `json:"updated_at" example:"2024-01-01T12:00:00Z"`       // 更新时间
}
