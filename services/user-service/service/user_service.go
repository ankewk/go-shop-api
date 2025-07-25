package service

import (
	"errors"
	"gin-project/services/user-service/repository"
	"gin-project/shared/models"

	"gorm.io/gorm"
)

// UserService 用户业务逻辑接口
type UserService interface {
	CreateUser(req *models.CreateUserRequest) (*models.User, error)
	GetUserByID(id uint) (*models.User, error)
	GetUserByEmail(email string) (*models.User, error)
	GetUsers(page, pageSize int) ([]models.User, *models.PaginationInfo, error)
	UpdateUser(id uint, req *models.UpdateUserRequest) (*models.User, error)
	DeleteUser(id uint) error
}

// userService 用户业务逻辑实现
type userService struct {
	userRepo repository.UserRepository
}

// NewUserService 创建用户业务逻辑实例
func NewUserService(userRepo repository.UserRepository) UserService {
	return &userService{
		userRepo: userRepo,
	}
}

// CreateUser 创建用户
func (s *userService) CreateUser(req *models.CreateUserRequest) (*models.User, error) {
	// 检查邮箱是否已存在
	if existingUser, _ := s.userRepo.GetByEmail(req.Email); existingUser != nil {
		return nil, errors.New("邮箱已被注册")
	}

	// 业务验证
	if req.Name == "" {
		return nil, errors.New("用户姓名不能为空")
	}
	if req.Email == "" {
		return nil, errors.New("邮箱地址不能为空")
	}

	// 创建用户模型
	user := &models.User{
		Name:   req.Name,
		Email:  req.Email,
		Phone:  req.Phone,
		Status: 1, // 默认状态为正常
	}

	// 保存到数据库
	if err := s.userRepo.Create(user); err != nil {
		return nil, err
	}

	return user, nil
}

// GetUserByID 根据ID获取用户
func (s *userService) GetUserByID(id uint) (*models.User, error) {
	if id == 0 {
		return nil, errors.New("用户ID不能为空")
	}

	user, err := s.userRepo.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}

	return user, nil
}

// GetUserByEmail 根据邮箱获取用户
func (s *userService) GetUserByEmail(email string) (*models.User, error) {
	if email == "" {
		return nil, errors.New("邮箱地址不能为空")
	}

	user, err := s.userRepo.GetByEmail(email)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}

	return user, nil
}

// GetUsers 获取用户列表
func (s *userService) GetUsers(page, pageSize int) ([]models.User, *models.PaginationInfo, error) {
	// 参数验证
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 10
	}

	// 获取数据
	users, total, err := s.userRepo.GetAll(page, pageSize)
	if err != nil {
		return nil, nil, err
	}

	// 构建分页信息
	pagination := &models.PaginationInfo{
		Page:     page,
		PageSize: pageSize,
		Total:    total,
	}

	return users, pagination, nil
}

// UpdateUser 更新用户
func (s *userService) UpdateUser(id uint, req *models.UpdateUserRequest) (*models.User, error) {
	// 检查用户是否存在
	user, err := s.userRepo.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("用户不存在")
		}
		return nil, err
	}

	// 检查邮箱是否被其他用户使用
	if req.Email != nil && *req.Email != user.Email {
		if existingUser, _ := s.userRepo.GetByEmail(*req.Email); existingUser != nil && existingUser.ID != id {
			return nil, errors.New("邮箱已被其他用户注册")
		}
	}

	// 更新字段（只更新非空字段）
	if req.Name != nil {
		if *req.Name == "" {
			return nil, errors.New("用户姓名不能为空")
		}
		user.Name = *req.Name
	}
	if req.Email != nil {
		if *req.Email == "" {
			return nil, errors.New("邮箱地址不能为空")
		}
		user.Email = *req.Email
	}
	if req.Phone != nil {
		user.Phone = *req.Phone
	}
	if req.Avatar != nil {
		user.Avatar = *req.Avatar
	}
	if req.Status != nil {
		if *req.Status != 0 && *req.Status != 1 {
			return nil, errors.New("状态值只能是0或1")
		}
		user.Status = *req.Status
	}

	// 保存更新
	if err := s.userRepo.Update(user); err != nil {
		return nil, err
	}

	return user, nil
}

// DeleteUser 删除用户
func (s *userService) DeleteUser(id uint) error {
	// 检查用户是否存在
	_, err := s.userRepo.GetByID(id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("用户不存在")
		}
		return err
	}

	// 执行删除
	return s.userRepo.Delete(id)
}
