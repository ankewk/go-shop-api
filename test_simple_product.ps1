# 简化的产品API测试脚本

Write-Host "========== 产品API测试 ==========" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080/api/v1"

# 1. 测试服务器状态
Write-Host "1. 测试服务器状态..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/" -Method Get -TimeoutSec 5
    Write-Host "服务器正在运行" -ForegroundColor Green
} catch {
    Write-Host "服务器未运行" -ForegroundColor Red
    exit 1
}

# 2. 创建产品
Write-Host "2. 创建新产品..." -ForegroundColor Yellow
$createData = '{"name":"iPhone 15","description":"最新款iPhone手机","price":8999.99,"stock":100,"category":"电子产品"}'

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/products" -Method Post -Body $createData -ContentType "application/json"
    Write-Host "产品创建成功，ID: $($createResponse.data.id)" -ForegroundColor Green
    $productId = $createResponse.data.id
} catch {
    Write-Host "创建产品失败: $($_.Exception.Message)" -ForegroundColor Red
    $productId = 1
}

# 3. 获取产品列表
Write-Host "3. 获取产品列表..." -ForegroundColor Yellow
try {
    $listResponse = Invoke-RestMethod -Uri "$baseUrl/products" -Method Get
    Write-Host "产品列表获取成功，总数: $($listResponse.pagination.total)" -ForegroundColor Green
} catch {
    Write-Host "获取产品列表失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. 获取单个产品
Write-Host "4. 获取产品详情..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-RestMethod -Uri "$baseUrl/products/$productId" -Method Get
    Write-Host "产品详情: $($getResponse.data.name), 价格: $($getResponse.data.price)" -ForegroundColor Green
} catch {
    Write-Host "获取产品详情失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. 更新产品
Write-Host "5. 更新产品..." -ForegroundColor Yellow
$updateData = '{"name":"iPhone 15 Pro","price":9999.99}'

try {
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/products/$productId" -Method Put -Body $updateData -ContentType "application/json"
    Write-Host "产品更新成功: $($updateResponse.data.name)" -ForegroundColor Green
} catch {
    Write-Host "更新产品失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "========== 测试完成 ==========" -ForegroundColor Cyan
Write-Host "Swagger文档: http://localhost:8080/swagger/index.html" -ForegroundColor Yellow 