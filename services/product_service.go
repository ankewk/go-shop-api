package services

import (
	"errors"
	"gin-project/models"
	"gin-project/repositories"

	"gorm.io/gorm"
)

// ProductService 产品业务逻辑接口
type ProductService interface {
	CreateProduct(req *models.CreateProductRequest) (*models.Product, error)
	GetProductByID(id uint) (*models.Product, error)
	GetProducts(page, pageSize int) ([]models.Product, *models.PaginationInfo, error)
	UpdateProduct(id uint, req *models.UpdateProductRequest) (*models.Product, error)
	DeleteProduct(id uint) error
}

// productService 产品业务逻辑实现
type productService struct {
	productRepo repositories.ProductRepository
}

// NewProductService 创建产品业务逻辑实例
func NewProductService(productRepo repositories.ProductRepository) ProductService {
	return &productService{
		productRepo: productRepo,
	}
}

// CreateProduct 创建产品
func (s *productService) CreateProduct(req *models.CreateProductRequest) (*models.Product, error) {
	// 业务验证
	if req.Name == "" {
		return nil, errors.New("产品名称不能为空")
	}
	if req.Price < 0 {
		return nil, errors.New("产品价格不能为负数")
	}
	if req.Stock < 0 {
		return nil, errors.New("库存数量不能为负数")
	}

	// 创建产品模型
	product := &models.Product{
		Name:        req.Name,
		Description: req.Description,
		Price:       req.Price,
		Stock:       req.Stock,
		Category:    req.Category,
		Status:      1, // 默认状态为正常
	}

	// 保存到数据库
	if err := s.productRepo.Create(product); err != nil {
		return nil, err
	}

	return product, nil
}

// GetProductByID 根据ID获取产品
func (s *productService) GetProductByID(id uint) (*models.Product, error) {
	if id == 0 {
		return nil, errors.New("产品ID不能为空")
	}

	product, err := s.productRepo.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("产品不存在")
		}
		return nil, err
	}

	return product, nil
}

// GetProducts 获取产品列表
func (s *productService) GetProducts(page, pageSize int) ([]models.Product, *models.PaginationInfo, error) {
	// 参数验证
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 10
	}

	// 获取数据
	products, total, err := s.productRepo.GetAll(page, pageSize)
	if err != nil {
		return nil, nil, err
	}

	// 构建分页信息
	pagination := &models.PaginationInfo{
		Page:     page,
		PageSize: pageSize,
		Total:    total,
	}

	return products, pagination, nil
}

// UpdateProduct 更新产品
func (s *productService) UpdateProduct(id uint, req *models.UpdateProductRequest) (*models.Product, error) {
	// 检查产品是否存在
	product, err := s.productRepo.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("产品不存在")
		}
		return nil, err
	}

	// 更新字段（只更新非空字段）
	if req.Name != nil {
		if *req.Name == "" {
			return nil, errors.New("产品名称不能为空")
		}
		product.Name = *req.Name
	}
	if req.Description != nil {
		product.Description = *req.Description
	}
	if req.Price != nil {
		if *req.Price < 0 {
			return nil, errors.New("产品价格不能为负数")
		}
		product.Price = *req.Price
	}
	if req.Stock != nil {
		if *req.Stock < 0 {
			return nil, errors.New("库存数量不能为负数")
		}
		product.Stock = *req.Stock
	}
	if req.Category != nil {
		product.Category = *req.Category
	}
	if req.Status != nil {
		if *req.Status != 0 && *req.Status != 1 {
			return nil, errors.New("状态值只能是0或1")
		}
		product.Status = *req.Status
	}

	// 保存更新
	if err := s.productRepo.Update(product); err != nil {
		return nil, err
	}

	return product, nil
}

// DeleteProduct 删除产品
func (s *productService) DeleteProduct(id uint) error {
	// 检查产品是否存在
	_, err := s.productRepo.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("产品不存在")
		}
		return err
	}

	// 执行删除
	return s.productRepo.Delete(id)
}
