package config

import (
	"fmt"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var OrderDB *gorm.DB

func InitOrderDB() error {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("ORDER_DB_HOST"),
		os.Getenv("ORDER_DB_PORT"),
		os.Getenv("ORDER_DB_USER"),
		os.Getenv("ORDER_DB_PASSWORD"),
		os.Getenv("ORDER_DB_NAME"),
	)

	var err error
	OrderDB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("failed to connect to order database: %w", err)
	}

	sqlDB, err := OrderDB.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	return nil
}

func GetOrderDB() *gorm.DB {
	return OrderDB
}