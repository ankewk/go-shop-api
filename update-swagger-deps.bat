@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   更新微服务 Swagger 依赖
echo =====================================

echo.
echo 正在为所有微服务添加 Swagger 依赖...

echo 1. 更新用户服务依赖...
cd services\user-service
go mod tidy
go get github.com/swaggo/gin-swagger@latest
go get github.com/swaggo/files@latest  
go get github.com/swaggo/swag@latest
cd ..\..

echo 2. 更新产品服务依赖...
cd services\product-service
go mod init gin-project/services/product-service
go mod edit -require gin-project/shared@v0.0.0
go mod edit -replace gin-project/shared=../../shared
go mod tidy
go get github.com/swaggo/gin-swagger@latest
go get github.com/swaggo/files@latest
go get github.com/swaggo/swag@latest
cd ..\..

echo 3. 更新购物车服务依赖...
cd services\cart-service
go mod init gin-project/services/cart-service
go mod edit -require gin-project/shared@v0.0.0
go mod edit -replace gin-project/shared=../../shared
go mod tidy
go get github.com/swaggo/gin-swagger@latest
go get github.com/swaggo/files@latest
go get github.com/swaggo/swag@latest
cd ..\..

echo 4. 更新订单服务依赖...
cd services\order-service
go mod init gin-project/services/order-service
go mod edit -require gin-project/shared@v0.0.0
go mod edit -replace gin-project/shared=../../shared
go mod tidy
go get github.com/swaggo/gin-swagger@latest
go get github.com/swaggo/files@latest
go get github.com/swaggo/swag@latest
cd ..\..

echo 5. 更新API网关依赖...
cd services\api-gateway
go mod init gin-project/services/api-gateway
go mod edit -require gin-project/shared@v0.0.0
go mod edit -replace gin-project/shared=../../shared
go mod tidy
go get github.com/swaggo/gin-swagger@latest
go get github.com/swaggo/files@latest
go get github.com/swaggo/swag@latest
cd ..\..

echo.
echo =====================================
echo   Swagger 依赖更新完成！
echo =====================================
echo.
echo 📖 Swagger 文档访问地址：
echo   用户服务:    http://localhost:8081/swagger/index.html
echo   产品服务:    http://localhost:8082/swagger/index.html
echo   购物车服务:  http://localhost:8083/swagger/index.html
echo   订单服务:    http://localhost:8084/swagger/index.html
echo   API网关:     http://localhost:8080/swagger/index.html
echo.
pause 