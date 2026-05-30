# PowerShell Script - Push Code to GitHub
# 把这个文件放到 D:\code\claude_main 目录下，右键 "Run with PowerShell"

$ProjectDir = "D:\code\claude_main"
$ArchivePath = Join-Path $ProjectDir "gitrepo.tar.gz"
$GitDir = Join-Path $ProjectDir ".git"

Write-Host "=== 正在推送到 GitHub ===" -ForegroundColor Cyan

# 检查 git 是否安装
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Host "❌ 未找到 git 命令。请先安装 Git: https://git-scm.com/" -ForegroundColor Red
    exit 1
}

# 检查压缩包是否存在
if (-not (Test-Path $ArchivePath)) {
    Write-Host "❌ 找不到 $ArchivePath" -ForegroundColor Red
    exit 1
}

# 如果已有 .git 目录，先清理
if (Test-Path $GitDir) {
    Write-Host "📦 清理旧的 .git 目录..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $GitDir -ErrorAction SilentlyContinue
}

# 解压
Write-Host "📦 解压 .git 目录..." -ForegroundColor Yellow
if (Get-Command tar -ErrorAction SilentlyContinue) {
    cd $ProjectDir
    tar xzf $ArchivePath
} else {
    Write-Host "⚠️  tar 命令不可用，请用 7-Zip 或 WinRAR 手动解压 gitrepo.tar.gz" -ForegroundColor Red
    Write-Host "   解压后运行: git push -u origin main" -ForegroundColor Yellow
    exit 1
}

# 推送到 GitHub
Write-Host "🚀 正在推送到 GitHub..." -ForegroundColor Yellow
cd $ProjectDir
git push -u origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 推送成功！" -ForegroundColor Green

    # 清理
    Remove-Item -Force $ArchivePath -ErrorAction SilentlyContinue
    Write-Host "🧹 清理完成" -ForegroundColor Gray
} else {
    Write-Host "❌ 推送失败" -ForegroundColor Red
    Write-Host "可能的解决方案：" -ForegroundColor Yellow
    Write-Host "  1. 检查网络连接" -ForegroundColor Gray
    Write-Host "  2. 如果提示认证，用 GitHub Personal Access Token 登录" -ForegroundColor Gray
    Write-Host "     https://github.com/settings/tokens" -ForegroundColor Gray
    Write-Host "  3. 或者改用 SSH:" -ForegroundColor Gray
    Write-Host "     git remote set-url origin git@github.com:wthsama/cc_open.git" -ForegroundColor Gray
    Write-Host "     git push -u origin main" -ForegroundColor Gray
}
