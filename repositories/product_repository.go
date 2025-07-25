package repositories

import (
	"gin-project/models"

	"gorm.io/gorm"
)

// ProductRepository 产品数据访问接口
type ProductRepository interface {
	Create(product *models.Product) error
	GetByID(id uint) (*models.Product, error)
	GetAll(page, pageSize int) ([]models.Product, int64, error)
	Update(product *models.Product) error
	Delete(id uint) error
}

// productRepository 产品数据访问实现
type productRepository struct {
	db *gorm.DB
}

// NewProductRepository 创建产品数据访问实例
func NewProductRepository(db *gorm.DB) ProductRepository {
	return &productRepository{db: db}
}

// Create 创建产品
func (r *productRepository) Create(product *models.Product) error {
	return r.db.Create(product).Error
}

// GetByID 根据ID获取产品
func (r *productRepository) GetByID(id uint) (*models.Product, error) {
	var product models.Product
	err := r.db.First(&product, id).Error
	if err != nil {
		return nil, err
	}
	return &product, nil
}

// GetAll 获取产品列表（分页）
func (r *productRepository) GetAll(page, pageSize int) ([]models.Product, int64, error) {
	var products []models.Product
	var total int64

	// 计算总数
	if err := r.db.Model(&models.Product{}).Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 分页查询
	offset := (page - 1) * pageSize
	err := r.db.Offset(offset).Limit(pageSize).Find(&products).Error
	return products, total, err
}

// Update 更新产品
func (r *productRepository) Update(product *models.Product) error {
	return r.db.Save(product).Error
}

// Delete 删除产品（软删除）
func (r *productRepository) Delete(id uint) error {
	return r.db.Delete(&models.Product{}, id).Error
}
