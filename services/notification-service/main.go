package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Notification struct {
	ID      uint   `json:"id" gorm:"primaryKey"`
	UserID  uint   `json:"user_id" gorm:"index"`
	Title   string `json:"title"`
	Message string `json:"message"`
	Type    string `json:"type"`
	IsRead  bool   `json:"is_read"`
}

var db *gorm.DB

func initDB() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=postgres-notification user=notification_user password=notification_password dbname=notification_db port=5432 sslmode=disable"
	}

	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	// 自动迁移
	err = db.AutoMigrate(&Notification{})
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

	// 通知路由
	notifications := r.Group("/api/notifications")
	{
		notifications.GET("/user/:userId", getUserNotifications)
		notifications.GET("/:id", getNotification)
		notifications.POST("/send", sendNotification)
		notifications.PUT("/:id/read", markAsRead)
		notifications.PUT("/user/:userId/read-all", markAllAsRead)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8087"
	}

	log.Printf("通知服务启动在端口: %s", port)
	r.Run(":" + port)
}

func getUserNotifications(c *gin.Context) {
	userId := c.Param("userId")
	
	var notifications []Notification
	result := db.Where("user_id = ?", userId).Order("created_at DESC").Find(&notifications)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{
		"data": notifications,
		"total": len(notifications),
	})
}

func getNotification(c *gin.Context) {
	id := c.Param("id")
	
	var notification Notification
	result := db.First(&notification, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "通知不存在"})
		return
	}

	c.JSON(200, notification)
}

func sendNotification(c *gin.Context) {
	var notification Notification
	if err := c.ShouldBindJSON(&notification); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	notification.IsRead = false
	result := db.Create(&notification)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(201, notification)
}

func markAsRead(c *gin.Context) {
	id := c.Param("id")
	
	var notification Notification
	result := db.First(&notification, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "通知不存在"})
		return
	}

	notification.IsRead = true
	db.Save(&notification)
	c.JSON(200, gin.H{"message": "通知已标记为已读"})
}

func markAllAsRead(c *gin.Context) {
	userId := c.Param("userId")
	
	result := db.Model(&Notification{}).Where("user_id = ?", userId).Update("is_read", true)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "所有通知已标记为已读"})
}