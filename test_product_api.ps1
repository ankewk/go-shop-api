# PowerShell脚本 - 测试产品API

Write-Host "========== 产品API测试脚本 ==========" -ForegroundColor Cyan

$baseUrl = "http://localhost:8080/api/v1"

# 测试服务器状态
Write-Host "`n1. 测试服务器状态..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/" -Method Get -TimeoutSec 5
    Write-Host "✓ 服务器正在运行" -ForegroundColor Green
} catch {
    Write-Host "✗ 服务器未运行，请先启动服务器" -ForegroundColor Red
    exit 1
}

# 2. 创建产品
Write-Host "`n2. 创建新产品..." -ForegroundColor Yellow
$createData = @{
    name = "iPhone 15"
    description = "最新款iPhone手机"
    price = 8999.99
    stock = 100
    category = "电子产品"
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "$baseUrl/products" -Method Post -Body $createData -ContentType "application/json"
    Write-Host "✓ 产品创建成功" -ForegroundColor Green
    Write-Host "产品ID: $($createResponse.data.id)" -ForegroundColor Cyan
    $productId = $createResponse.data.id
} catch {
    Write-Host "✗ 创建产品失败: $($_.Exception.Message)" -ForegroundColor Red
    $productId = 1  # 使用默认ID继续测试
}

# 3. 获取产品列表
Write-Host "`n3. 获取产品列表..." -ForegroundColor Yellow
try {
    $listResponse = Invoke-RestMethod -Uri "$baseUrl/products?page=1`&page_size=5" -Method Get
    Write-Host "✓ 产品列表获取成功" -ForegroundColor Green
    Write-Host "总数: $($listResponse.pagination.total)" -ForegroundColor Cyan
    Write-Host "当前页: $($listResponse.pagination.page)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ 获取产品列表失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. 获取单个产品
Write-Host "`n4. 获取产品详情..." -ForegroundColor Yellow
try {
    $getResponse = Invoke-RestMethod -Uri "$baseUrl/products/$productId" -Method Get
    Write-Host "✓ 产品详情获取成功" -ForegroundColor Green
    Write-Host "产品名称: $($getResponse.data.name)" -ForegroundColor Cyan
    Write-Host "产品价格: $($getResponse.data.price)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ 获取产品详情失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. 更新产品
Write-Host "`n5. 更新产品信息..." -ForegroundColor Yellow
$updateData = @{
    name = "iPhone 15 Pro"
    price = 9999.99
    stock = 50
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri "$baseUrl/products/$productId" -Method Put -Body $updateData -ContentType "application/json"
    Write-Host "✓ 产品更新成功" -ForegroundColor Green
    Write-Host "新名称: $($updateResponse.data.name)" -ForegroundColor Cyan
    Write-Host "新价格: $($updateResponse.data.price)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ 更新产品失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. 创建第二个产品用于演示
Write-Host "`n6. 创建第二个产品..." -ForegroundColor Yellow
$createData2 = @{
    name = "MacBook Pro"
    description = "高性能笔记本电脑"
    price = 15999.99
    stock = 30
    category = "电子产品"
} | ConvertTo-Json

try {
    $createResponse2 = Invoke-RestMethod -Uri "$baseUrl/products" -Method Post -Body $createData2 -ContentType "application/json"
    Write-Host "✓ 第二个产品创建成功" -ForegroundColor Green
    $productId2 = $createResponse2.data.id
} catch {
    Write-Host "✗ 创建第二个产品失败: $($_.Exception.Message)" -ForegroundColor Red
    $productId2 = 2
}

# 7. 再次获取产品列表查看变化
Write-Host "`n7. 再次获取产品列表..." -ForegroundColor Yellow
try {
    $listResponse2 = Invoke-RestMethod -Uri "$baseUrl/products" -Method Get
    Write-Host "✓ 产品列表获取成功" -ForegroundColor Green
    Write-Host "产品总数: $($listResponse2.pagination.total)" -ForegroundColor Cyan
    foreach($product in $listResponse2.data) {
        Write-Host "- ID: $($product.id), 名称: $($product.name), 价格: $($product.price)" -ForegroundColor White
    }
} catch {
    Write-Host "✗ 获取产品列表失败: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. 删除产品
Write-Host "`n8. 删除第二个产品..." -ForegroundColor Yellow
try {
    $deleteResponse = Invoke-RestMethod -Uri "$baseUrl/products/$productId2" -Method Delete
    Write-Host "✓ 产品删除成功" -ForegroundColor Green
} catch {
    Write-Host "✗ 删除产品失败: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n========== 测试完成 ==========" -ForegroundColor Cyan
Write-Host "🔗 Swagger文档地址: http://localhost:8080/swagger/index.html" -ForegroundColor Green
Write-Host "📚 可以在Swagger文档中查看完整的API说明和测试接口" -ForegroundColor Yellow 