import { Router } from 'express';
import fs from 'fs';
import path from 'path';

export const uploadRouter = Router();

const uploadsDir = path.join(process.cwd(), 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

/**
 * POST /api/v1/upload/image
 * Uploads an image (base64 string or data URL) and saves it to /uploads directory.
 * Returns both relative URL and absolute LAN URL.
 */
uploadRouter.post('/image', async (req, res) => {
  try {
    const { image, data, filename } = req.body;
    const rawImage = image || data;

    if (!rawImage || typeof rawImage !== 'string') {
      return res.status(400).json({ success: false, error: 'No image data provided' });
    }

    let ext = 'jpg';
    let base64String = rawImage;

    // Check if it's a Data URL (e.g. data:image/png;base64,...)
    const dataUrlMatch = rawImage.match(/^data:image\/([a-zA-Z0-9]+);base64,(.+)$/);
    if (dataUrlMatch) {
      ext = dataUrlMatch[1] === 'jpeg' ? 'jpg' : dataUrlMatch[1];
      base64String = dataUrlMatch[2];
    } else if (filename && filename.includes('.')) {
      ext = filename.split('.').pop() || 'jpg';
    }

    const buffer = Buffer.from(base64String, 'base64');
    const safeName = `img_${Date.now()}_${Math.random().toString(36).substring(2, 8)}.${ext}`;
    const targetPath = path.join(uploadsDir, safeName);

    await fs.promises.writeFile(targetPath, buffer);

    const relativeUrl = `/uploads/${safeName}`;
    const host = req.headers.host || '10.186.14.158:5000';
    const protocol = req.protocol || 'http';
    const fullUrl = `${protocol}://${host}${relativeUrl}`;

    console.log(`[UPLOAD] Image saved successfully: ${safeName} (${(buffer.length / 1024).toFixed(1)} KB)`);

    return res.json({
      success: true,
      url: fullUrl,
      relativeUrl,
      filename: safeName,
    });
  } catch (error: any) {
    console.error('[UPLOAD ERROR]:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
});
