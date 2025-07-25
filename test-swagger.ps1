# PowerShell脚本 - 测试Swagger访问

Write-Host "正在测试服务器状态..." -ForegroundColor Yellow

# 测试根路径
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/" -Method Get -TimeoutSec 5
    Write-Host "✓ 服务器正在运行" -ForegroundColor Green
    Write-Host "服务器信息: $($response.data.message)" -ForegroundColor Cyan
    
    if ($response.data.swagger_url) {
        Write-Host "✓ Swagger地址: http://localhost:8080$($response.data.swagger_url)" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ 服务器未运行或无法访问" -ForegroundColor Red
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    
    Write-Host "`n请先启动服务器:" -ForegroundColor Yellow
    Write-Host "1. 运行 start.bat" -ForegroundColor White
    Write-Host "2. 或手动执行: go mod tidy && go run main.go" -ForegroundColor White
    exit 1
}

# 测试Swagger端点
Write-Host "`n正在测试Swagger端点..." -ForegroundColor Yellow

try {
    $swaggerResponse = Invoke-WebRequest -Uri "http://localhost:8080/swagger/index.html" -Method Get -TimeoutSec 5 -UseBasicParsing
    
    if ($swaggerResponse.StatusCode -eq 200) {
        Write-Host "✓ Swagger文档可正常访问" -ForegroundColor Green
        Write-Host "📚 Swagger地址: http://localhost:8080/swagger/index.html" -ForegroundColor Cyan
        
        # 尝试打开浏览器
        try {
            Start-Process "http://localhost:8080/swagger/index.html"
            Write-Host "✓ 已在默认浏览器中打开Swagger文档" -ForegroundColor Green
        } catch {
            Write-Host "! 无法自动打开浏览器，请手动访问上述地址" -ForegroundColor Yellow
        }
    } else {
        Write-Host "✗ Swagger端点返回状态码: $($swaggerResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Swagger端点无法访问" -ForegroundColor Red
    Write-Host "错误: $($_.Exception.Message)" -ForegroundColor Red
    
    Write-Host "`n可能的解决方案:" -ForegroundColor Yellow
    Write-Host "1. 检查服务器是否正确启动" -ForegroundColor White
    Write-Host "2. 检查8080端口是否被占用" -ForegroundColor White
    Write-Host "3. 确保所有依赖已正确安装" -ForegroundColor White
}

Write-Host "`n测试完成！" -ForegroundColor Green 