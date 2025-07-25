package models

import "time"

// OrderStatus 订单状态类型
type OrderStatus string

const (
	OrderStatusPending   OrderStatus = "pending"   // 待支付
	OrderStatusPaid      OrderStatus = "paid"      // 已支付
	OrderStatusShipped   OrderStatus = "shipped"   // 已发货
	OrderStatusDelivered OrderStatus = "delivered" // 已送达
	OrderStatusCancelled OrderStatus = "cancelled" // 已取消
	OrderStatusRefunded  OrderStatus = "refunded"  // 已退款
)

// Order 订单模型
// @Description 订单信息模型
type Order struct {
	ID            uint        `json:"id" gorm:"primaryKey" example:"1"`                             // 订单ID
	OrderNo       string      `json:"order_no" gorm:"uniqueIndex;size:32" example:"ORD20240101001"` // 订单号
	UserID        uint        `json:"user_id" gorm:"not null;index" example:"1"`                    // 用户ID
	User          *User       `json:"user,omitempty" gorm:"foreignKey:UserID"`                      // 用户信息
	Items         []OrderItem `json:"items" gorm:"foreignKey:OrderID"`                              // 订单项目
	TotalAmount   float64     `json:"total_amount" gorm:"not null" example:"15999.95"`              // 总金额
	Status        OrderStatus `json:"status" gorm:"default:pending" example:"pending"`              // 订单状态
	PaymentMethod string      `json:"payment_method" gorm:"size:50" example:"alipay"`               // 支付方式
	ShippingAddr  string      `json:"shipping_address" gorm:"type:text" example:"北京市朝阳区XXX街道"`      // 收货地址
	ContactPhone  string      `json:"contact_phone" gorm:"size:20" example:"13888888888"`           // 联系电话
	ContactName   string      `json:"contact_name" gorm:"size:100" example:"张三"`                    // 联系人
	Remark        string      `json:"remark" gorm:"type:text" example:"请尽快发货"`                      // 订单备注
	PaidAt        *time.Time  `json:"paid_at,omitempty"`                                            // 支付时间
	ShippedAt     *time.Time  `json:"shipped_at,omitempty"`                                         // 发货时间
	DeliveredAt   *time.Time  `json:"delivered_at,omitempty"`                                       // 签收时间
	CreatedAt     time.Time   `json:"created_at" example:"2024-01-01T12:00:00Z"`                    // 创建时间
	UpdatedAt     time.Time   `json:"updated_at" example:"2024-01-01T12:00:00Z"`                    // 更新时间
}

// OrderItem 订单项模型
// @Description 订单商品项模型
type OrderItem struct {
	ID        uint      `json:"id" gorm:"primaryKey" example:"1"`              // 项目ID
	OrderID   uint      `json:"order_id" gorm:"not null;index" example:"1"`    // 订单ID
	ProductID uint      `json:"product_id" gorm:"not null;index" example:"1"`  // 商品ID
	Product   *Product  `json:"product,omitempty" gorm:"foreignKey:ProductID"` // 商品信息
	Quantity  int       `json:"quantity" gorm:"not null" example:"2"`          // 数量
	Price     float64   `json:"price" gorm:"not null" example:"8999.99"`       // 单价（下单时的价格）
	Total     float64   `json:"total" gorm:"not null" example:"17999.98"`      // 小计
	CreatedAt time.Time `json:"created_at" example:"2024-01-01T12:00:00Z"`     // 创建时间
	UpdatedAt time.Time `json:"updated_at" example:"2024-01-01T12:00:00Z"`     // 更新时间
}

// CreateOrderRequest 创建订单的请求参数
// @Description 创建订单的请求参数
type CreateOrderRequest struct {
	UserID          uint   `json:"user_id" validate:"required,min=1" example:"1"`              // 用户ID（必填）
	PaymentMethod   string `json:"payment_method" example:"alipay"`                            // 支付方式（可选）
	ShippingAddress string `json:"shipping_address" validate:"required" example:"北京市朝阳区XXX街道"` // 收货地址（必填）
	ContactPhone    string `json:"contact_phone" validate:"required" example:"13888888888"`    // 联系电话（必填）
	ContactName     string `json:"contact_name" validate:"required" example:"张三"`              // 联系人（必填）
	Remark          string `json:"remark" example:"请尽快发货"`                                     // 订单备注（可选）
}

// UpdateOrderStatusRequest 更新订单状态的请求参数
// @Description 更新订单状态的请求参数
type UpdateOrderStatusRequest struct {
	Status OrderStatus `json:"status" validate:"required" example:"paid"` // 订单状态（必填）
	Remark string      `json:"remark" example:"支付成功"`                     // 备注（可选）
}

// OrderListResponse 订单列表响应
// @Description 订单列表响应
type OrderListResponse struct {
	Code       int             `json:"code" example:"200"`
	Data       []Order         `json:"data"`
	Message    string          `json:"message" example:"订单列表获取成功"`
	Pagination *PaginationInfo `json:"pagination"`
}

// SingleOrderResponse 单个订单响应
// @Description 单个订单响应
type SingleOrderResponse struct {
	Code    int    `json:"code" example:"200"`
	Data    Order  `json:"data"`
	Message string `json:"message" example:"订单信息获取成功"`
}

// OrderSummary 订单统计
// @Description 订单统计信息
type OrderSummary struct {
	TotalOrders   int     `json:"total_orders" example:"156"`        // 总订单数
	PendingOrders int     `json:"pending_orders" example:"12"`       // 待支付订单
	PaidOrders    int     `json:"paid_orders" example:"98"`          // 已支付订单
	ShippedOrders int     `json:"shipped_orders" example:"32"`       // 已发货订单
	TotalAmount   float64 `json:"total_amount" example:"1234567.89"` // 总交易额
	TodayOrders   int     `json:"today_orders" example:"8"`          // 今日订单
	TodayAmount   float64 `json:"today_amount" example:"25999.95"`   // 今日交易额
}

// OrderSummaryResponse 订单统计响应
// @Description 订单统计响应
type OrderSummaryResponse struct {
	Code    int          `json:"code" example:"200"`
	Data    OrderSummary `json:"data"`
	Message string       `json:"message" example:"订单统计获取成功"`
}
