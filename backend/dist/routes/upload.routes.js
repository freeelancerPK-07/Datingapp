"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadRouter = void 0;
const express_1 = require("express");
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
exports.uploadRouter = (0, express_1.Router)();
const uploadsDir = path_1.default.join(process.cwd(), 'uploads');
if (!fs_1.default.existsSync(uploadsDir)) {
    fs_1.default.mkdirSync(uploadsDir, { recursive: true });
}
/**
 * POST /api/v1/upload/image
 * Uploads an image (base64 string or data URL) and saves it to /uploads directory.
 * Returns both relative URL and absolute LAN URL.
 */
exports.uploadRouter.post('/image', async (req, res) => {
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
        }
        else if (filename && filename.includes('.')) {
            ext = filename.split('.').pop() || 'jpg';
        }
        const buffer = Buffer.from(base64String, 'base64');
        const safeName = `img_${Date.now()}_${Math.random().toString(36).substring(2, 8)}.${ext}`;
        const targetPath = path_1.default.join(uploadsDir, safeName);
        await fs_1.default.promises.writeFile(targetPath, buffer);
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
    }
    catch (error) {
        console.error('[UPLOAD ERROR]:', error);
        return res.status(500).json({ success: false, error: error.message });
    }
});
