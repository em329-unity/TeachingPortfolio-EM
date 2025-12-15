<#
Initialize a git repo, make the initial commit, and optionally add/push to remote.
Usage:
  .\init-git-commit.ps1 -Remote "git@github.com:username/repo.git"
#>
param(
    [string]$Remote = ""
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: git not found in PATH. Install git and retry." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path .git)) {
    git init
    Write-Host "Initialized empty git repo." -ForegroundColor Green
} else {
    Write-Host "Git repo already initialized." -ForegroundColor Yellow
}

git add -A

# Commit only if there are staged changes
$changes = git status --porcelain
if ($changes) {
    git commit -m "Initial commit: Add Quarto site sources and render workflow"
} else {
    Write-Host "No changes to commit." -ForegroundColor Yellow
}

if ($Remote -ne "") {
    git remote add origin $Remote -ErrorAction SilentlyContinue
    git branch -M main
    Write-Host "Added remote origin and set branch to 'main'." -ForegroundColor Green
    Write-Host "To push to your remote, run: git push -u origin main" -ForegroundColor Green
} else {
    Write-Host "No remote specified." -ForegroundColor Yellow
    Write-Host "To add a remote and push, run:" -ForegroundColor Yellow
    Write-Host "  git remote add origin <your-repo-url>" -ForegroundColor Yellow
    Write-Host "  git push -u origin main" -ForegroundColor Yellow
}
