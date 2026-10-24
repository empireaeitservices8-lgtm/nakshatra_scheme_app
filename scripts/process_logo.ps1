Add-Type -AssemblyName System.Drawing

$src = "C:\Users\sreej\.gemini\antigravity-ide\brain\b87043af-75fc-42a6-bc3e-22ecfa7a11bb\.user_uploaded\media_1789976088595.png"
$img = [System.Drawing.Bitmap]::FromFile($src)

Write-Host "Image dimensions: $($img.Width) x $($img.Height)"

# 1. Find bounding box of non-white pixels
$minX = $img.Width
$maxX = 0
$minY = $img.Height
$maxY = 0

for ($y = 0; $y -lt $img.Height; $y++) {
    for ($x = 0; $x -lt $img.Width; $x++) {
        $c = $img.GetPixel($x, $y)
        # Check if pixel is dark (not white/near-white)
        # In this image, background is white (255, 255, 255) and content is black/gray
        if ($c.R -lt 240 -or $c.G -lt 240 -or $c.B -lt 240) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Host "Content bounds: X: $minX to $maxX, Y: $minY to $maxY"

$padding = 20
$minX = [Math]::Max(0, $minX - $padding)
$minY = [Math]::Max(0, $minY - $padding)
$maxX = [Math]::Min($img.Width - 1, $maxX + $padding)
$maxY = [Math]::Min($img.Height - 1, $maxY + $padding)

$cropWidth = $maxX - $minX + 1
$cropHeight = $maxY - $minY + 1

Write-Host "Cropped dimensions: $cropWidth x $cropHeight"

# Create output directories if needed
$outDir = "d:\empire\nakshathra_scheme_app\assets\images"
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force
}

# Create cropped dark logo with transparent background
$croppedDark = New-Object System.Drawing.Bitmap($cropWidth, $cropHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
# Create cropped white logo with transparent background (for dark theme / splash / login)
$croppedWhite = New-Object System.Drawing.Bitmap($cropWidth, $cropHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
# Create cropped gold logo with transparent background
$croppedGold = New-Object System.Drawing.Bitmap($cropWidth, $cropHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

for ($y = 0; $y -lt $cropHeight; $y++) {
    for ($x = 0; $x -lt $cropWidth; $x++) {
        $origColor = $img.GetPixel($minX + $x, $minY + $y)
        # calculate darkness/alpha from grayscale brightness
        # Brightness: 255 = pure white -> alpha = 0
        # 0 = pure black -> alpha = 255
        $avg = ($origColor.R + $origColor.G + $origColor.B) / 3.0
        
        # Smooth alpha curve
        if ($avg -gt 245) {
            $alpha = 0
        } else {
            # Invert brightness to get opacity
            $alpha = [int][Math]::Min(255, [Math]::Max(0, (255 - $avg) * 1.08))
        }

        if ($alpha -gt 0) {
            # Dark version (Black/Dark Slate with anti-aliasing)
            $darkColor = [System.Drawing.Color]::FromArgb($alpha, 15, 23, 42)
            $croppedDark.SetPixel($x, $y, $darkColor)

            # White version (Clean White with anti-aliasing)
            $whiteColor = [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255)
            $croppedWhite.SetPixel($x, $y, $whiteColor)

            # Gold version (#E5B869 = 229, 184, 105)
            $goldColor = [System.Drawing.Color]::FromArgb($alpha, 229, 184, 105)
            $croppedGold.SetPixel($x, $y, $goldColor)
        } else {
            $transparent = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
            $croppedDark.SetPixel($x, $y, $transparent)
            $croppedWhite.SetPixel($x, $y, $transparent)
            $croppedGold.SetPixel($x, $y, $transparent)
        }
    }
}

$croppedDark.Save("$outDir\nakshathra_logo_dark.png", [System.Drawing.Imaging.ImageFormat]::Png)
$croppedWhite.Save("$outDir\nakshathra_logo_white.png", [System.Drawing.Imaging.ImageFormat]::Png)
$croppedGold.Save("$outDir\nakshathra_logo_gold.png", [System.Drawing.Imaging.ImageFormat]::Png)

# Also save original cropped
$rect = New-Object System.Drawing.Rectangle($minX, $minY, $cropWidth, $cropHeight)
$croppedOriginal = $img.Clone($rect, $img.PixelFormat)
$croppedOriginal.Save("$outDir\nakshathra_logo.png", [System.Drawing.Imaging.ImageFormat]::Png)

$img.Dispose()
$croppedDark.Dispose()
$croppedWhite.Dispose()
$croppedGold.Dispose()
$croppedOriginal.Dispose()

Write-Host "Successfully generated all logo assets in $outDir"
