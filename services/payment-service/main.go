package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Payment struct {
	ID          uint    `json:"id" gorm:"primaryKey"`
	OrderID     uint    `json:"order_id" gorm:"index"`
	UserID      uint    `json:"user_id"`
	Amount      float64 `json:"amount"`
	Status      string  `json:"status"`
	PaymentMethod string `json:"payment_method"`
	TransactionID string `json:"transaction_id"`
}

var db *gorm.DB

func initDB() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=postgres-payment user=payment_user password=payment_password dbname=payment_db port=5432 sslmode=disable"
	}

	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	// 自动迁移
	err = db.AutoMigrate(&Payment{})
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

	// 支付路由
	payments := r.Group("/api/payments")
	{
		payments.GET("/user/:userId", getUserPayments)
		payments.GET("/:id", getPayment)
		payments.POST("/create", createPayment)
		payments.PUT("/:id/status", updatePaymentStatus)
		payments.POST("/:id/refund", refundPayment)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8086"
	}

	log.Printf("支付服务启动在端口: %s", port)
	r.Run(":" + port)
}

func getUserPayments(c *gin.Context) {
	userId := c.Param("userId")
	
	var payments []Payment
	result := db.Where("user_id = ?", userId).Order("created_at DESC").Find(&payments)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{
		"data": payments,
		"total": len(payments),
	})
}

func getPayment(c *gin.Context) {
	id := c.Param("id")
	
	var payment Payment
	result := db.First(&payment, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "支付记录不存在"})
		return
	}

	c.JSON(200, payment)
}

func createPayment(c *gin.Context) {
	var payment Payment
	if err := c.ShouldBindJSON(&payment); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	payment.Status = "pending"
	payment.TransactionID = generateTransactionID()

	result := db.Create(&payment)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(201, payment)
}

func updatePaymentStatus(c *gin.Context) {
	id := c.Param("id")
	var updateData struct {
		Status string `json:"status"`
	}

	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	var payment Payment
	result := db.First(&payment, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "支付记录不存在"})
		return
	}

	payment.Status = updateData.Status
	db.Save(&payment)
	c.JSON(200, payment)
}

func refundPayment(c *gin.Context) {
	id := c.Param("id")
	
	var payment Payment
	result := db.First(&payment, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "支付记录不存在"})
		return
	}

	payment.Status = "refunded"
	db.Save(&payment)
	c.JSON(200, gin.H{"message": "退款处理中"})
}

func generateTransactionID() string {
	import "time"
	return "TXN" + time.Now().Format("20060102150405")
}