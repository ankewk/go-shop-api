package repositories

import (
	"gin-project/models"

	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

// NewUserRepository 创建用户仓储
func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{
		db: db,
	}
}

// FindAll 获取所有用户（分页）
func (ur *UserRepository) FindAll(offset, limit int) ([]models.User, error) {
	var users []models.User
	err := ur.db.Offset(offset).Limit(limit).Find(&users).Error
	return users, err
}

// FindByID 根据ID查找用户
func (ur *UserRepository) FindByID(id uint) (*models.User, error) {
	var user models.User
	err := ur.db.First(&user, id).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

// FindByEmail 根据邮箱查找用户
func (ur *UserRepository) FindByEmail(email string) (*models.User, error) {
	var user models.User
	err := ur.db.Where("email = ?", email).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &user, nil
}

// Create 创建用户
func (ur *UserRepository) Create(user *models.User) error {
	return ur.db.Create(user).Error
}

// Update 更新用户
func (ur *UserRepository) Update(id uint, updates map[string]interface{}) error {
	return ur.db.Model(&models.User{}).Where("id = ?", id).Updates(updates).Error
}

// Delete 删除用户（软删除）
func (ur *UserRepository) Delete(id uint) error {
	return ur.db.Delete(&models.User{}, id).Error
}

// Count 获取用户总数
func (ur *UserRepository) Count() (int64, error) {
	var count int64
	err := ur.db.Model(&models.User{}).Count(&count).Error
	return count, err
}

// Exists 检查用户是否存在
func (ur *UserRepository) Exists(id uint) (bool, error) {
	var count int64
	err := ur.db.Model(&models.User{}).Where("id = ?", id).Count(&count).Error
	return count > 0, err
}
