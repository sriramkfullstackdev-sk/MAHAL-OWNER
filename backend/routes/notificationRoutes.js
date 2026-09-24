const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { sendNotificationApi, saveFcmTokenApi } = require("../controllers/notificationController");

router.post("/send", authMiddleware, sendNotificationApi);
router.post("/save-token", authMiddleware, saveFcmTokenApi);

module.exports = router;
