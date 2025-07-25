# PowerShell脚本 - 测试API并插入测试数据

Write-Host "正在测试API并插入测试数据..." -ForegroundColor Green

# 测试用户数据
$users = @(
    @{
        name = "张三"
        email = "zhangsan@example.com"
        phone = "13888888888"
    },
    @{
        name = "李四"
        email = "lisi@example.com"
        phone = "13999999999"
    },
    @{
        name = "王五"
        email = "wangwu@example.com"
        phone = "13777777777"
    }
)

# 健康检查
Write-Host "1. 检查API健康状态..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/health" -Method Get
    Write-Host "✓ API健康检查通过" -ForegroundColor Green
    Write-Host "数据库状态: $($health.database)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ API健康检查失败，请确保服务器正在运行" -ForegroundColor Red
    exit 1
}

# 插入测试用户
Write-Host "`n2. 插入测试用户..." -ForegroundColor Yellow
foreach ($user in $users) {
    try {
        $json = $user | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/users" -Method Post -Body $json -ContentType "application/json"
        Write-Host "✓ 创建用户: $($user.name) (ID: $($response.data.id))" -ForegroundColor Green
    } catch {
        if ($_.Exception.Response.StatusCode -eq 500) {
            Write-Host "! 用户 $($user.name) 可能已存在" -ForegroundColor Yellow
        } else {
            Write-Host "✗ 创建用户 $($user.name) 失败: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# 获取所有用户
Write-Host "`n3. 获取所有用户..." -ForegroundColor Yellow
try {
    $users_response = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/users" -Method Get
    Write-Host "✓ 当前数据库中的用户:" -ForegroundColor Green
    foreach ($user in $users_response.data) {
        Write-Host "  - ID: $($user.id), 姓名: $($user.name), 邮箱: $($user.email), 电话: $($user.phone)" -ForegroundColor Cyan
    }
    Write-Host "总计: $($users_response.pagination.total) 个用户" -ForegroundColor Magenta
} catch {
    Write-Host "✗ 获取用户列表失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n数据库初始化完成！" -ForegroundColor Green 