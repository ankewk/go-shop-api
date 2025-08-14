package models

import (
	"time"

	"gorm.io/gorm"
)

// Order 订单模型（分表版本）
type Order struct {
	ID           uint            `gorm:"primaryKey" json:"id"`
	UserID       uint            `gorm:"index" json:"user_id"`
	OrderNumber  string          `gorm:"uniqueIndex;size:50" json:"order_number"`
	Status       string          `gorm:"size:20;default:'pending'" json:"status"`
	TotalAmount  float64         `gorm:"type:decimal(10,2)" json:"total_amount"`
	ShippingAddress JSON         `gorm:"type:jsonb" json:"shipping_address"`
	BillingAddress  JSON         `gorm:"type:jsonb" json:"billing_address"`
	CreatedAt    time.Time       `json:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at"`
	DeletedAt    gorm.DeletedAt  `gorm:"index" json:"-"`
	
	// 关联
	Items []OrderItem `gorm:"foreignKey:OrderID" json:"items,omitempty"`
	StatusHistory []OrderStatusHistory `gorm:"foreignKey:OrderID" json:"status_history,omitempty"`
}

// OrderItem 订单项模型（分表版本）
type OrderItem struct {
	ID         uint    `gorm:"primaryKey" json:"id"`
	OrderID    uint    `gorm:"index" json:"order_id"`
	ProductID  uint    `gorm:"index" json:"product_id"`
	Quantity   int     `gorm:"not null" json:"quantity"`
	Price      float64 `gorm:"type:decimal(10,2)" json:"price"`
	CreatedAt  time.Time `json:"created_at"`
}

// OrderStatusHistory 订单状态历史模型（分表版本）
type OrderStatusHistory struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	OrderID   uint      `gorm:"index" json:"order_id"`
	Status    string    `gorm:"size:20" json:"status"`
	Note      string    `gorm:"type:text" json:"note"`
	CreatedAt time.Time `json:"created_at"`
}

// TableName 动态表名（由分表中间件处理）
func (Order) TableName() string {
	return "orders"
}

func (OrderItem) TableName() string {
	return "order_items"
}

func (OrderStatusHistory) TableName() string {
	return "order_status_history"
}

// OrderQueryParams 订单查询参数
type OrderQueryParams struct {
	UserID    *uint   `json:"user_id"`
	Status    *string `json:"status"`
	StartDate *time.Time `json:"start_date"`
	EndDate   *time.Time `json:"end_date"`
	Page      int     `json:"page"`
	Limit     int     `json:"limit"`
}

// OrderStatistics 订单统计
type OrderStatistics struct {
	TotalOrders    int64   `json:"total_orders"`
	TotalAmount    float64 `json:"total_amount"`
	PendingOrders  int64   `json:"pending_orders"`
	CompletedOrders int64   `json:"completed_orders"`
}