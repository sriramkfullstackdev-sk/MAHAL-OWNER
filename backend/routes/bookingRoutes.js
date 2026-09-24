const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const {
    getDashboardStats,
    getRecentRequests,
    getBookings,
    getOwnerBookingDetails,
    acceptOwnerBooking,
    rejectOwnerBooking,
    updateBookingStatus,
    getVisitingRequests,
    scanQrPass
} = require("../controllers/bookingController");

router.get("/dashboard/stats", authMiddleware, getDashboardStats);
router.get("/dashboard/requests", authMiddleware, getRecentRequests);
router.get("/requests", authMiddleware, getBookings);
router.get("/details/:bookingId", authMiddleware, getOwnerBookingDetails);
router.post("/accept", authMiddleware, acceptOwnerBooking);
router.post("/reject", authMiddleware, rejectOwnerBooking);
router.get("/", authMiddleware, getBookings);
router.post("/:booking_id/status", authMiddleware, updateBookingStatus);

// Visiting & QR Scan routes for Owner
router.get("/visiting/requests", authMiddleware, getVisitingRequests);
router.post("/qr/scan", authMiddleware, scanQrPass);

module.exports = router;
