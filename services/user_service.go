package services

import (
	"errors"

	"gin-project/models"
	"gin-project/repositories"
)

type UserService struct {
	userRepo *repositories.UserRepository
}

// NewUserService 创建用户服务
func NewUserService(userRepo *repositories.UserRepository) *UserService {
	return &UserService{
		userRepo: userRepo,
	}
}

// GetUsers 获取用户列表
func (us *UserService) GetUsers(page, pageSize int) ([]models.User, int64, error) {
	// 计算偏移量
	offset := (page - 1) * pageSize

	// 调用仓储层获取数据
	users, err := us.userRepo.FindAll(offset, pageSize)
	if err != nil {
		return nil, 0, err
	}

	// 获取总数
	total, err := us.userRepo.Count()
	if err != nil {
		return nil, 0, err
	}

	return users, total, nil
}

// CreateUser 创建用户
func (us *UserService) CreateUser(req *models.CreateUserRequest) (*models.User, error) {
	// 检查邮箱是否已存在
	existingUser, _ := us.userRepo.FindByEmail(req.Email)
	if existingUser != nil {
		return nil, errors.New("邮箱已被注册")
	}

	// 创建用户对象
	user := &models.User{
		Name:   req.Name,
		Email:  req.Email,
		Phone:  req.Phone,
		Status: 1, // 默认状态为激活
	}

	// 调用仓储层保存
	err := us.userRepo.Create(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}

// GetUserByID 根据ID获取用户
func (us *UserService) GetUserByID(id uint) (*models.User, error) {
	user, err := us.userRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	if user == nil {
		return nil, errors.New("user not found")
	}

	return user, nil
}

// UpdateUser 更新用户
func (us *UserService) UpdateUser(id uint, req *models.UpdateUserRequest) (*models.User, error) {
	// 检查用户是否存在
	user, err := us.userRepo.FindByID(id)
	if err != nil {
		return nil, err
	}

	if user == nil {
		return nil, errors.New("user not found")
	}

	// 如果要更新邮箱，检查新邮箱是否已被其他用户使用
	if req.Email != nil && *req.Email != user.Email {
		existingUser, _ := us.userRepo.FindByEmail(*req.Email)
		if existingUser != nil && existingUser.ID != id {
			return nil, errors.New("邮箱已被其他用户使用")
		}
	}

	// 构建更新数据
	updates := make(map[string]interface{})
	if req.Name != nil {
		updates["name"] = *req.Name
	}
	if req.Email != nil {
		updates["email"] = *req.Email
	}
	if req.Phone != nil {
		updates["phone"] = *req.Phone
	}

	// 调用仓储层更新
	err = us.userRepo.Update(id, updates)
	if err != nil {
		return nil, err
	}

	// 返回更新后的用户信息
	return us.userRepo.FindByID(id)
}

// DeleteUser 删除用户（软删除）
func (us *UserService) DeleteUser(id uint) error {
	// 检查用户是否存在
	user, err := us.userRepo.FindByID(id)
	if err != nil {
		return err
	}

	if user == nil {
		return errors.New("user not found")
	}

	// 调用仓储层删除
	return us.userRepo.Delete(id)
}
