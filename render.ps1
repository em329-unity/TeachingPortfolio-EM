# Render Quarto pages to specified outputs
# Usage: In PowerShell, run: .\render.ps1

# Ensure Pages directory exists
if (-not (Test-Path -Path "Pages")) {
    New-Item -ItemType Directory -Path "Pages" | Out-Null
}

# Check that 'quarto' is available
$quarto = Get-Command quarto -ErrorAction SilentlyContinue
if (-not $quarto) {
    Write-Host "ERROR: Quarto CLI not found. Please install Quarto (https://quarto.org/docs/get-started/)." -ForegroundColor Red
    exit 1
}

function Render-And-Move($inputPath, $targetPath) {
    Write-Host "Rendering $inputPath ..."
    quarto render $inputPath --to html

    # Quarto writes site output to _site at the project root by default; find generated HTML file
    $siteDir = Join-Path (Get-Location) "_site"
    if (-not (Test-Path $siteDir)) {
        Write-Host "ERROR: Expected _site folder not found after rendering $inputPath" -ForegroundColor Red
        return
    }

    # The generated HTML will typically be in _site relative to the source file
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
    $possibleFiles = Get-ChildItem -Path $siteDir -Filter "$baseName*.html" -Recurse -ErrorAction SilentlyContinue
    if (-not $possibleFiles) {
        Write-Host "ERROR: Could not find generated HTML for $inputPath in $siteDir" -ForegroundColor Red
        return
    }

    # Use the first match
    $generated = $possibleFiles[0].FullName
    $destDir = Split-Path $targetPath -Parent
    if ($destDir -and $destDir -ne '.') {
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
    }
    Move-Item -Path $generated -Destination $targetPath -Force
    Write-Host "Moved generated HTML to $targetPath" -ForegroundColor Green
}

# Render homepage to Pages/index.html
Render-And-Move "Quarto Files/index.qmd" "Pages/index.html"

# Ensure a root redirect exists that points to Pages/index.html
$redirect = @"
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="refresh" content="0; url=Pages/index.html">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Redirecting…</title>
        <link rel="canonical" href="Pages/index.html">
    </head>
    <body>
        <p>Redirecting to the site: <a href="Pages/index.html">Open site</a>.</p>
    </body>
</html>
"@

Set-Content -Path "index.html" -Value $redirect -Force
Write-Host "Created root redirect index.html -> Pages/index.html" -ForegroundColor Green

# Render other pages into Pages folder
Render-And-Move "Quarto Files/about-me.qmd" "Pages/about-me.html"
Render-And-Move "Quarto Files/teaching-philosophy.qmd" "Pages/teaching-philosophy.html"
Render-And-Move "Quarto Files/mock-assignment.qmd" "Pages/mock-assignment.html"
Render-And-Move "Quarto Files/mock-syllabus.qmd" "Pages/mock-syllabus.html"
Render-And-Move "Quarto Files/mock-lesson-plan.qmd" "Pages/mock-lesson-plan.html"
Render-And-Move "Quarto Files/resume.qmd" "Pages/resume.html"

Write-Host "Rendering finished." -ForegroundColor Green
