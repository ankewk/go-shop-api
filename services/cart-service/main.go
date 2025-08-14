package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Cart struct {
	ID        uint    `json:"id" gorm:"primaryKey"`
	UserID    uint    `json:"user_id" gorm:"index"`
	ProductID uint    `json:"product_id"`
	Quantity  int     `json:"quantity"`
	Price     float64 `json:"price"`
}

var db *gorm.DB

func initDB() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=postgres-cart user=cart_user password=cart_password dbname=cart_db port=5432 sslmode=disable"
	}

	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	// 自动迁移
	err = db.AutoMigrate(&Cart{})
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

	// 购物车路由
	cart := r.Group("/api/cart")
	{
		cart.GET("/user/:userId", getUserCart)
		cart.POST("/add", addToCart)
		cart.PUT("/update/:id", updateCartItem)
		cart.DELETE("/remove/:id", removeFromCart)
		cart.DELETE("/clear/:userId", clearCart)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8085"
	}

	log.Printf("购物车服务启动在端口: %s", port)
	r.Run(":" + port)
}

func getUserCart(c *gin.Context) {
	userId := c.Param("userId")
	
	var carts []Cart
	result := db.Where("user_id = ?", userId).Find(&carts)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{
		"data": carts,
		"total": len(carts),
	})
}

func addToCart(c *gin.Context) {
	var cart Cart
	if err := c.ShouldBindJSON(&cart); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	// 检查是否已存在
	var existingCart Cart
	result := db.Where("user_id = ? AND product_id = ?", cart.UserID, cart.ProductID).First(&existingCart)
	if result.Error == nil {
		// 已存在，更新数量
		existingCart.Quantity += cart.Quantity
		db.Save(&existingCart)
		c.JSON(200, existingCart)
		return
	}

	// 创建新购物车项
	result = db.Create(&cart)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(201, cart)
}

func updateCartItem(c *gin.Context) {
	id := c.Param("id")
	var updateData struct {
		Quantity int `json:"quantity"`
	}

	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	var cart Cart
	result := db.First(&cart, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "购物车项不存在"})
		return
	}

	cart.Quantity = updateData.Quantity
	db.Save(&cart)
	c.JSON(200, cart)
}

func removeFromCart(c *gin.Context) {
	id := c.Param("id")
	
	result := db.Delete(&Cart{}, id)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "已从购物车移除"})
}

func clearCart(c *gin.Context) {
	userId := c.Param("userId")
	
	result := db.Where("user_id = ?", userId).Delete(&Cart{})
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "购物车已清空"})
}