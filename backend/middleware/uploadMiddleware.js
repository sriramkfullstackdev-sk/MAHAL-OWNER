const multer = require("multer");

// Configure multer memory storage
const storage = multer.memoryStorage();

const path = require("path");

// Accept only image formats (evaluate mimetype or file extension)
const fileFilter = (req, file, cb) => {
    const isImageMimetype = file.mimetype.startsWith("image/");
    const ext = path.extname(file.originalname).toLowerCase();
    const isImageExtension = [".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp"].includes(ext);

    if (isImageMimetype || isImageExtension) {
        cb(null, true);
    } else {
        cb(new Error("Only image files are allowed!"), false);
    }
};

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // Limit to 10MB
    },
    fileFilter: fileFilter
});

module.exports = upload;
