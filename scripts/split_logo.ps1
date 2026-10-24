$code = @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class LogoSplitter
{
    public static void SplitLogo(string inputPath, string outputDir)
    {
        using (Bitmap original = new Bitmap(inputPath))
        {
            int w = original.Width;
            int h = original.Height;
            
            BitmapData srcData = original.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            int[] pixels = new int[w * h];
            Marshal.Copy(srcData.Scan0, pixels, 0, pixels.Length);
            original.UnlockBits(srcData);

            // Row profile to find the gap between mark and text
            int[] rowPixelCount = new int[h];
            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    int pixel = pixels[y * w + x];
                    int a = (pixel >> 24) & 0xFF;
                    int r = (pixel >> 16) & 0xFF;
                    if (a > 30 && r < 230)
                    {
                        rowPixelCount[y]++;
                    }
                }
            }

            int markMinY = 0, markMaxY = 0, textMinY = 0, textMaxY = 0;
            bool inMark = false;
            int splitY = 0;

            for (int y = 0; y < h; y++)
            {
                if (rowPixelCount[y] > 0)
                {
                    if (!inMark && markMinY == 0)
                    {
                        markMinY = y;
                        inMark = true;
                    }
                }
                else
                {
                    if (inMark && markMaxY == 0)
                    {
                        markMaxY = y - 1;
                        splitY = y;
                        inMark = false;
                    }
                }
                if (markMaxY > 0 && rowPixelCount[y] > 0 && textMinY == 0)
                {
                    textMinY = y;
                }
                if (rowPixelCount[y] > 0)
                {
                    textMaxY = y;
                }
            }

            Console.WriteLine(string.Format("Mark Y: {0} to {1}, Text Y: {2} to {3}, Split Y: {4}", markMinY, markMaxY, textMinY, textMaxY, splitY));

            // Crop Mark bounds
            int markMinX = w, markMaxX = 0;
            for (int y = markMinY; y <= markMaxY; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    int pixel = pixels[y * w + x];
                    int a = (pixel >> 24) & 0xFF;
                    int r = (pixel >> 16) & 0xFF;
                    if (a > 30 && r < 230)
                    {
                        if (x < markMinX) markMinX = x;
                        if (x > markMaxX) markMaxX = x;
                    }
                }
            }

            int markPad = 12;
            markMinX = Math.Max(0, markMinX - markPad);
            markMinY = Math.Max(0, markMinY - markPad);
            markMaxX = Math.Min(w - 1, markMaxX + markPad);
            markMaxY = Math.Min(h - 1, markMaxY + markPad);

            int markW = markMaxX - markMinX + 1;
            int markH = markMaxY - markMinY + 1;

            using (Bitmap markDark = new Bitmap(markW, markH, PixelFormat.Format32bppArgb))
            using (Bitmap markWhite = new Bitmap(markW, markH, PixelFormat.Format32bppArgb))
            using (Bitmap markGold = new Bitmap(markW, markH, PixelFormat.Format32bppArgb))
            {
                BitmapData dData = markDark.LockBits(new Rectangle(0, 0, markW, markH), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                BitmapData wData = markWhite.LockBits(new Rectangle(0, 0, markW, markH), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                BitmapData gData = markGold.LockBits(new Rectangle(0, 0, markW, markH), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);

                int[] oD = new int[markW * markH];
                int[] oW = new int[markW * markH];
                int[] oG = new int[markW * markH];

                for (int y = 0; y < markH; y++)
                {
                    int sy = markMinY + y;
                    for (int x = 0; x < markW; x++)
                    {
                        int sx = markMinX + x;
                        int pixel = pixels[sy * w + sx];
                        int a = (pixel >> 24) & 0xFF;
                        int r = (pixel >> 16) & 0xFF;
                        int g = (pixel >> 8) & 0xFF;
                        int b = pixel & 0xFF;

                        int outA = 0;
                        if (a > 20)
                        {
                            int darkness = 255 - ((r + g + b) / 3);
                            outA = Math.Min(255, (int)(a * (darkness / 255.0) * 1.15));
                        }

                        int idx = y * markW + x;
                        if (outA > 8)
                        {
                            oD[idx] = (outA << 24) | (15 << 16) | (23 << 8) | 42;
                            oW[idx] = (outA << 24) | (255 << 16) | (255 << 8) | 255;
                            oG[idx] = (outA << 24) | (229 << 16) | (184 << 8) | 105;
                        }
                    }
                }

                Marshal.Copy(oD, 0, dData.Scan0, oD.Length);
                Marshal.Copy(oW, 0, wData.Scan0, oW.Length);
                Marshal.Copy(oG, 0, gData.Scan0, oG.Length);

                markDark.UnlockBits(dData);
                markWhite.UnlockBits(wData);
                markGold.UnlockBits(gData);

                markDark.Save(System.IO.Path.Combine(outputDir, "nakshathra_mark_dark.png"), ImageFormat.Png);
                markWhite.Save(System.IO.Path.Combine(outputDir, "nakshathra_mark_white.png"), ImageFormat.Png);
                markGold.Save(System.IO.Path.Combine(outputDir, "nakshathra_mark_gold.png"), ImageFormat.Png);
            }
            Console.WriteLine("Mark files created successfully!");
        }
    }
}
"@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing
[LogoSplitter]::SplitLogo("C:\Users\sreej\.gemini\antigravity-ide\brain\b87043af-75fc-42a6-bc3e-22ecfa7a11bb\.user_uploaded\media_1789976088595.png", "d:\empire\nakshathra_scheme_app\assets\images")
