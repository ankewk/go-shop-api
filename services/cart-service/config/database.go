package config

import (
	"fmt"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var CartDB *gorm.DB

func InitCartDB() error {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("CART_DB_HOST"),
		os.Getenv("CART_DB_PORT"),
		os.Getenv("CART_DB_USER"),
		os.Getenv("CART_DB_PASSWORD"),
		os.Getenv("CART_DB_NAME"),
	)

	var err error
	CartDB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("failed to connect to cart database: %w", err)
	}

	sqlDB, err := CartDB.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	return nil
}

func GetCartDB() *gorm.DB {
	return CartDB
}