const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { getProfile, updateProfile, getBankAccount, saveBankAccount } = require("../controllers/ownerController");
const {
    getBookings,
    getOwnerBookingDetails,
    scanQrPass,
    acceptOwnerBooking,
    rejectOwnerBooking
} = require("../controllers/bookingController");

router.get("/profile", authMiddleware, getProfile);
router.post("/profile", authMiddleware, updateProfile);
router.get("/bank-account", authMiddleware, getBankAccount);
router.post("/bank-account", authMiddleware, saveBankAccount);

// Exact prompt requested endpoints under /owner
router.get("/booking-requests", authMiddleware, getBookings);
router.get("/booking-details/:booking_id", authMiddleware, getOwnerBookingDetails);
router.get("/booking-details/:bookingId", authMiddleware, getOwnerBookingDetails);

// Exact prompt requested endpoints for scan, accept, reject
router.post("/scan-qr", authMiddleware, scanQrPass);
router.post("/accept", authMiddleware, acceptOwnerBooking);
router.post("/reject", authMiddleware, rejectOwnerBooking);

// Backwards compatibility aliases
router.post("/booking/accept", authMiddleware, acceptOwnerBooking);
router.post("/booking/reject", authMiddleware, rejectOwnerBooking);
router.post("/qr/scan", authMiddleware, scanQrPass);

module.exports = router;
