const express = require("express");
const router = express.Router();
const { checkMobile, sendOtp, verifyOtp } = require("../controllers/authController");

router.post("/check-mobile", checkMobile);
router.post("/send-otp", sendOtp);
router.post("/verify-otp", verifyOtp);

module.exports = router;
