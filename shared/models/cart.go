package models

import "time"

// Cart 购物车模型
// @Description 购物车信息模型
type Cart struct {
	ID        uint       `json:"id" gorm:"primaryKey" example:"1"`          // 购物车ID
	UserID    uint       `json:"user_id" gorm:"not null;index" example:"1"` // 用户ID
	Items     []CartItem `json:"items" gorm:"foreignKey:CartID"`            // 购物车项目
	Total     float64    `json:"total" gorm:"-"`                            // 总金额（计算字段）
	ItemCount int        `json:"item_count" gorm:"-"`                       // 商品总数（计算字段）
	CreatedAt time.Time  `json:"created_at" example:"2024-01-01T12:00:00Z"` // 创建时间
	UpdatedAt time.Time  `json:"updated_at" example:"2024-01-01T12:00:00Z"` // 更新时间
}

// CartItem 购物车项模型
// @Description 购物车商品项模型
type CartItem struct {
	ID        uint      `json:"id" gorm:"primaryKey" example:"1"`               // 项目ID
	CartID    uint      `json:"cart_id" gorm:"not null;index" example:"1"`      // 购物车ID
	ProductID uint      `json:"product_id" gorm:"not null;index" example:"1"`   // 商品ID
	Product   *Product  `json:"product,omitempty" gorm:"foreignKey:ProductID"`  // 商品信息
	Quantity  int       `json:"quantity" gorm:"not null;default:1" example:"2"` // 数量
	Price     float64   `json:"price" gorm:"not null" example:"8999.99"`        // 单价（下单时的价格）
	Total     float64   `json:"total" gorm:"-"`                                 // 小计（计算字段）
	CreatedAt time.Time `json:"created_at" example:"2024-01-01T12:00:00Z"`      // 创建时间
	UpdatedAt time.Time `json:"updated_at" example:"2024-01-01T12:00:00Z"`      // 更新时间
}

// AddToCartRequest 添加商品到购物车的请求参数
// @Description 添加商品到购物车的请求参数
type AddToCartRequest struct {
	ProductID uint `json:"product_id" validate:"required,min=1" example:"1"` // 商品ID（必填）
	Quantity  int  `json:"quantity" validate:"required,min=1" example:"2"`   // 数量（必填，最少1个）
}

// UpdateCartItemRequest 更新购物车商品的请求参数
// @Description 更新购物车商品的请求参数
type UpdateCartItemRequest struct {
	Quantity int `json:"quantity" validate:"required,min=0" example:"3"` // 数量（必填，0表示删除）
}

// CartResponse 购物车响应
// @Description 购物车响应
type CartResponse struct {
	Code    int    `json:"code" example:"200"`
	Data    Cart   `json:"data"`
	Message string `json:"message" example:"购物车获取成功"`
}

// CartSummary 购物车摘要
// @Description 购物车摘要信息
type CartSummary struct {
	ItemCount   int     `json:"item_count" example:"5"`          // 商品总数
	TotalAmount float64 `json:"total_amount" example:"15999.95"` // 总金额
	UniqueItems int     `json:"unique_items" example:"3"`        // 不同商品种类数
}

// CartSummaryResponse 购物车摘要响应
// @Description 购物车摘要响应
type CartSummaryResponse struct {
	Code    int         `json:"code" example:"200"`
	Data    CartSummary `json:"data"`
	Message string      `json:"message" example:"购物车摘要获取成功"`
}
