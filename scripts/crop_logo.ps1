$code = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class LogoProcessor
{
    public static void ProcessLogo(string inputPath, string outputDir)
    {
        using (Bitmap original = new Bitmap(inputPath))
        {
            int w = original.Width;
            int h = original.Height;
            
            // Find bounding box for pixels with Alpha > 30 and where it's not pure white/transparent
            int minX = w, maxX = 0, minY = h, maxY = 0;
            
            BitmapData srcData = original.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            int[] pixels = new int[w * h];
            Marshal.Copy(srcData.Scan0, pixels, 0, pixels.Length);
            original.UnlockBits(srcData);

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    int pixel = pixels[y * w + x];
                    int a = (pixel >> 24) & 0xFF;
                    int r = (pixel >> 16) & 0xFF;
                    int g = (pixel >> 8) & 0xFF;
                    int b = pixel & 0xFF;
                    
                    // If image is transparent PNG where content has Alpha > 20:
                    // OR if image has white background, check brightness
                    if (a > 30 && (r < 230 || g < 230 || b < 230))
                    {
                        if (x < minX) minX = x;
                        if (x > maxX) maxX = x;
                        if (y < minY) minY = y;
                        if (y > maxY) maxY = y;
                    }
                }
            }

            Console.WriteLine(string.Format("Detected logo bounds: X: {0} to {1}, Y: {2} to {3}", minX, maxX, minY, maxY));
            
            int pad = 24;
            minX = Math.Max(0, minX - pad);
            minY = Math.Max(0, minY - pad);
            maxX = Math.Min(w - 1, maxX + pad);
            maxY = Math.Min(h - 1, maxY + pad);

            int cropW = maxX - minX + 1;
            int cropH = maxY - minY + 1;
            Console.WriteLine(string.Format("Cropped Size: {0} x {1}", cropW, cropH));

            // Generate 3 clean high-res transparent versions:
            // 1. Dark version (#0F172A) for light backgrounds (e.g. Home screen)
            // 2. White version (#FFFFFF) for dark backgrounds (e.g. Splash & Login screen)
            // 3. Gold version (#E5B869)
            using (Bitmap bmpDark = new Bitmap(cropW, cropH, PixelFormat.Format32bppArgb))
            using (Bitmap bmpWhite = new Bitmap(cropW, cropH, PixelFormat.Format32bppArgb))
            using (Bitmap bmpGold = new Bitmap(cropW, cropH, PixelFormat.Format32bppArgb))
            {
                BitmapData darkData = bmpDark.LockBits(new Rectangle(0, 0, cropW, cropH), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                BitmapData whiteData = bmpWhite.LockBits(new Rectangle(0, 0, cropW, cropH), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                BitmapData goldData = bmpGold.LockBits(new Rectangle(0, 0, cropW, cropH), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

                int[] outDark = new int[cropW * cropH];
                int[] outWhite = new int[cropW * cropH];
                int[] outGold = new int[cropW * cropH];

                for (int y = 0; y < cropH; y++)
                {
                    int srcY = minY + y;
                    for (int x = 0; x < cropW; x++)
                    {
                        int srcX = minX + x;
                        int pixel = pixels[srcY * w + srcX];
                        int srcA = (pixel >> 24) & 0xFF;
                        int r = (pixel >> 16) & 0xFF;
                        int g = (pixel >> 8) & 0xFF;
                        int b = pixel & 0xFF;
                        
                        int outA = 0;
                        if (srcA > 20)
                        {
                            // calculate intensity
                            int darkness = 255 - ((r + g + b) / 3);
                            outA = Math.Min(255, (int)(srcA * (darkness / 255.0) * 1.15));
                        }

                        int idx = y * cropW + x;
                        if (outA > 8)
                        {
                            // Dark: #0F172A (15, 23, 42)
                            outDark[idx] = (outA << 24) | (15 << 16) | (23 << 8) | 42;
                            // White: #FFFFFF (255, 255, 255)
                            outWhite[idx] = (outA << 24) | (255 << 16) | (255 << 8) | 255;
                            // Gold: #E5B869 (229, 184, 105)
                            outGold[idx] = (outA << 24) | (229 << 16) | (184 << 8) | 105;
                        }
                        else
                        {
                            outDark[idx] = 0;
                            outWhite[idx] = 0;
                            outGold[idx] = 0;
                        }
                    }
                }

                Marshal.Copy(outDark, 0, darkData.Scan0, outDark.Length);
                Marshal.Copy(outWhite, 0, whiteData.Scan0, outWhite.Length);
                Marshal.Copy(outGold, 0, goldData.Scan0, outGold.Length);

                bmpDark.UnlockBits(darkData);
                bmpWhite.UnlockBits(whiteData);
                bmpGold.UnlockBits(goldData);

                bmpDark.Save(System.IO.Path.Combine(outputDir, "nakshathra_logo_dark.png"), ImageFormat.Png);
                bmpWhite.Save(System.IO.Path.Combine(outputDir, "nakshathra_logo_white.png"), ImageFormat.Png);
                bmpGold.Save(System.IO.Path.Combine(outputDir, "nakshathra_logo_gold.png"), ImageFormat.Png);
            }
            Console.WriteLine("All cropped logo variants generated successfully!");
        }
    }
}
"@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
[LogoProcessor]::ProcessLogo("C:\Users\sreej\.gemini\antigravity-ide\brain\b87043af-75fc-42a6-bc3e-22ecfa7a11bb\.user_uploaded\media_1789976088595.png", "d:\empire\nakshathra_scheme_app\assets\images")
