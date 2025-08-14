package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Order struct {
	ID          uint    `json:"id" gorm:"primaryKey"`
	UserID      uint    `json:"user_id" gorm:"index"`
	OrderNumber string  `json:"order_number" gorm:"unique"`
	TotalAmount float64 `json:"total_amount"`
	Status      string  `json:"status"`
	Items       []OrderItem `json:"items" gorm:"foreignKey:OrderID"`
}

type OrderItem struct {
	ID        uint    `json:"id" gorm:"primaryKey"`
	OrderID   uint    `json:"order_id"`
	ProductID uint    `json:"product_id"`
	Quantity  int     `json:"quantity"`
	Price     float64 `json:"price"`
	Name      string  `json:"name"`
}

var db *gorm.DB

func initDB() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=postgres-order user=order_user password=order_password dbname=order_db port=5432 sslmode=disable"
	}

	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	// 自动迁移
	err = db.AutoMigrate(&Order{}, &OrderItem{})
	if err != nil {
		log.Fatal("数据库迁移失败: ", err)
	}
}

func main() {
	initDB()

	r := gin.Default()
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Origin, Content-Type, Authorization")
		
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		
		c.Next()
	})

	// 订单路由
	orders := r.Group("/api/orders")
	{
		orders.GET("/user/:userId", getUserOrders)
		orders.GET("/:id", getOrder)
		orders.POST("/create", createOrder)
		orders.PUT("/:id/status", updateOrderStatus)
		orders.DELETE("/:id", cancelOrder)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8084"
	}

	log.Printf("订单服务启动在端口: %s", port)
	r.Run(":" + port)
}

func getUserOrders(c *gin.Context) {
	userId := c.Param("userId")
	
	var orders []Order
	result := db.Preload("Items").Where("user_id = ?", userId).Order("created_at DESC").Find(&orders)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{
		"data": orders,
		"total": len(orders),
	})
}

func getOrder(c *gin.Context) {
	id := c.Param("id")
	
	var order Order
	result := db.Preload("Items").First(&order, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "订单不存在"})
		return
	}

	c.JSON(200, order)
}

func createOrder(c *gin.Context) {
	var newOrder struct {
		UserID  uint        `json:"user_id"`
		Items   []OrderItem `json:"items"`
		Address string      `json:"address"`
	}

	if err := c.ShouldBindJSON(&newOrder); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	// 计算总金额
	totalAmount := 0.0
	for _, item := range newOrder.Items {
		totalAmount += item.Price * float64(item.Quantity)
	}

	// 创建订单
	order := Order{
		UserID:      newOrder.UserID,
		OrderNumber: generateOrderNumber(),
		TotalAmount: totalAmount,
		Status:      "pending",
		Items:       newOrder.Items,
	}

	result := db.Create(&order)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(201, order)
}

func updateOrderStatus(c *gin.Context) {
	id := c.Param("id")
	var updateData struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	var order Order
	result := db.First(&order, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "订单不存在"})
		return
	}

	order.Status = updateData.Status
	db.Save(&order)
	c.JSON(200, order)
}

func cancelOrder(c *gin.Context) {
	id := c.Param("id")
	
	var order Order
	result := db.First(&order, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "订单不存在"})
		return
	}

	order.Status = "cancelled"
	db.Save(&order)
	c.JSON(200, gin.H{"message": "订单已取消"})
}

func generateOrderNumber() string {
	import "time"
	return "ORD" + time.Now().Format("20060102150405")
}