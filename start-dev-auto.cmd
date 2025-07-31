@echo off
chcp 65001 >nul 2>&1
echo =====================================
echo   🚀 Go Shop 开发环境 - 一键启动
echo =====================================
echo.

echo 🔍 这将自动修复网络问题并启动开发环境
echo.

echo 📋 第一步：修复Docker网络IP冲突
echo ----------------------------------------
echo 正在修复Docker网络问题...
call fix-network-ip-conflict.cmd

if %errorlevel% neq 0 (
    echo.
    echo ❌ 网络修复失败，尝试快速修复...
    echo.
    call quick-fix-docker.cmd
    if %errorlevel% neq 0 (
        echo.
        echo ❌ 自动修复失败，请手动解决网络问题
        echo.
        echo 💡 建议手动操作：
        echo   1. 重启Docker Desktop
        echo   2. 运行environment-launcher.cmd选择其他方案
        echo   3. 查看README-Docker网络问题解决.md
        goto END
    )
)

echo.
echo 📋 第二步：启动开发环境
echo ----------------------------------------
echo 网络修复成功，正在启动开发环境...
call scripts\start-dev.cmd

echo.
echo 📋 第三步：启动Go微服务
echo ----------------------------------------
echo 正在启动Go微服务...
call start-services-no-docker.cmd

:END
echo.
echo =====================================
echo   🎉 开发环境启动流程完成！
echo =====================================
echo.
echo 💡 如果遇到问题，可以手动尝试：
echo   - 环境管理器: environment-launcher.cmd
echo   - 非Docker启动: start-services-no-docker.cmd
echo   - 查看文档: README-Docker网络问题解决.md
echo.

pause 