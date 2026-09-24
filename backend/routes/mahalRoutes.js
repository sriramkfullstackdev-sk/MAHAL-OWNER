const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");
const {
    saveDetails,
    saveAddress,
    uploadImage,
    streamImage,
    saveDefaultTimings,
    getDefaultTimings
} = require("../controllers/mahalController");

const uploadFields = [
    { name: 'image_0', maxCount: 1 },
    { name: 'image_1', maxCount: 1 },
    { name: 'image_2', maxCount: 1 },
    { name: 'image_3', maxCount: 1 },
    { name: 'image_4', maxCount: 1 },
    { name: 'image_5', maxCount: 1 },
];

router.post("/details", authMiddleware, saveDetails);
router.post("/address", authMiddleware, saveAddress);
router.post("/image", authMiddleware, upload.fields(uploadFields), uploadImage);
router.post("/default-timings", authMiddleware, saveDefaultTimings);
router.get("/default-timings", authMiddleware, getDefaultTimings);
router.get("/:mahal_id/default-timings", getDefaultTimings);
router.get("/:mahal_id/image", streamImage);

module.exports = router;
