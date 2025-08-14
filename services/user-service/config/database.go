package config

import (
	"fmt"
	"os"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var UserDB *gorm.DB

func InitUserDB() error {
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("USER_DB_HOST"),
		os.Getenv("USER_DB_PORT"),
		os.Getenv("USER_DB_USER"),
		os.Getenv("USER_DB_PASSWORD"),
		os.Getenv("USER_DB_NAME"),
	)

	var err error
	UserDB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("failed to connect to user database: %w", err)
	}

	sqlDB, err := UserDB.DB()
	if err != nil {
		return fmt.Errorf("failed to get sql.DB: %w", err)
	}

	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)
	sqlDB.SetConnMaxLifetime(time.Hour)

	return nil
}

func GetUserDB() *gorm.DB {
	return UserDB
}