Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Bitmap]::FromFile("C:\Users\sreej\.gemini\antigravity-ide\brain\b87043af-75fc-42a6-bc3e-22ecfa7a11bb\.user_uploaded\media_1789976088595.png")

Write-Host "Top-left (0,0):" $img.GetPixel(0,0)
Write-Host "Top-right (1023,0):" $img.GetPixel(1023,0)
Write-Host "Bottom-left (0,1023):" $img.GetPixel(0,1023)
Write-Host "Bottom-right (1023,1023):" $img.GetPixel(1023,1023)
Write-Host "Center (512,512):" $img.GetPixel(512,512)

# Check edges
for ($i = 0; $i -lt 10; $i++) {
    Write-Host "Pixel ($i, $i):" $img.GetPixel($i, $i)
}
$img.Dispose()
