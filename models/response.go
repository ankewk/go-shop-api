package models

// APIResponse 通用API响应结构
// @Description 通用API响应格式
type APIResponse struct {
	Code    int         `json:"code" example:"200"`         // 响应状态码
	Message string      `json:"message" example:"操作成功"`     // 响应消息
	Data    interface{} `json:"data,omitempty"`             // 响应数据
	Error   string      `json:"error,omitempty" example:""` // 错误信息
}

// PaginationResponse 分页响应结构
// @Description 分页响应格式
type PaginationResponse struct {
	Code       int            `json:"code" example:"200"`     // 响应状态码
	Message    string         `json:"message" example:"获取成功"` // 响应消息
	Data       interface{}    `json:"data"`                   // 响应数据
	Pagination PaginationInfo `json:"pagination"`             // 分页信息
}

// PaginationInfo 分页信息
// @Description 分页信息
type PaginationInfo struct {
	Page     int   `json:"page" example:"1"`       // 当前页码
	PageSize int   `json:"page_size" example:"10"` // 每页条数
	Total    int64 `json:"total" example:"100"`    // 总记录数
}

// UserListResponse 用户列表响应
// @Description 用户列表响应
type UserListResponse struct {
	Code       int            `json:"code" example:"200"`
	Message    string         `json:"message" example:"用户列表获取成功"`
	Data       []User         `json:"data"`
	Pagination PaginationInfo `json:"pagination"`
}

// SingleUserResponse 单个用户响应
// @Description 单个用户响应
type SingleUserResponse struct {
	Code    int    `json:"code" example:"200"`
	Message string `json:"message" example:"用户信息获取成功"`
	Data    User   `json:"data"`
}

// HealthResponse 健康检查响应
// @Description 健康检查响应
type HealthResponse struct {
	Code    int                    `json:"code" example:"200"`
	Message string                 `json:"message" example:"健康检查通过"`
	Data    map[string]interface{} `json:"data"`
}

// ErrorResponse 错误响应
// @Description 错误响应格式
type ErrorResponse struct {
	Code    int    `json:"code" example:"400"`
	Message string `json:"message" example:"请求参数错误"`
	Error   string `json:"error" example:"name字段不能为空"`
}
