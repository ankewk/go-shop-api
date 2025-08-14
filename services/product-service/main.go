package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Product struct {
	ID          uint    `json:"id" gorm:"primaryKey"`
	Name        string  `json:"name" gorm:"index"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Stock       int     `json:"stock"`
	Category    string  `json:"category"`
	ImageURL    string  `json:"image_url"`
	Status      int     `json:"status"`
}

var db *gorm.DB

func initDB() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		dsn = "host=postgres-product user=product_user password=product_password dbname=product_db port=5432 sslmode=disable"
	}

	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("数据库连接失败: ", err)
	}

	// 自动迁移
	err = db.AutoMigrate(&Product{})
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{
		"data": products,
		"total": total,
		"page": page,
		"pageSize": pageSize,
	})
}

func getProduct(c *gin.Context) {
	id := c.Param("id")
	
	var product Product
	result := db.First(&product, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "商品不存在"})
		return
	}

	c.JSON(200, product)
}

func createProduct(c *gin.Context) {
	var product Product
	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	result := db.Create(&product)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(201, product)
}

func updateProduct(c *gin.Context) {
	id := c.Param("id")
	var product Product
	
	result := db.First(&product, id)
	if result.Error != nil {
		c.JSON(404, gin.H{"error": "商品不存在"})
		return
	}

	if err := c.ShouldBindJSON(&product); err != nil {
		c.JSON(400, gin.H{"error": err.Error()})
		return
	}

	db.Save(&product)
	c.JSON(200, product)
}

func deleteProduct(c *gin.Context) {
	id := c.Param("id")
	
	result := db.Delete(&Product{}, id)
	if result.Error != nil {
		c.JSON(500, gin.H{"error": result.Error.Error()})
		return
	}

	c.JSON(200, gin.H{"message": "商品已删除"})
}