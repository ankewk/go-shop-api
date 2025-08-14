package config

import (
	"fmt"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var ProductDB *gorm.DB

func InitProductDB() error {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("PRODUCT_DB_HOST"),
		os.Getenv("PRODUCT_DB_PORT"),
		os.Getenv("PRODUCT_DB_USER"),
		os.Getenv("PRODUCT_DB_PASSWORD"),
		os.Getenv("PRODUCT_DB_NAME"),
	)

	var err error
	ProductDB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("failed to connect to product database: %w", err)
	}

	sqlDB, err := ProductDB.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	return nil
}

func GetProductDB() *gorm.DB {
	return ProductDB
}