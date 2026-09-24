const Booking = require("../models/Booking");
const Mahal = require("../models/Mahal");
const VisitingRequest = require("../models/VisitingRequest");
const { sendPushNotification } = require("../services/notificationService");

const getDashboardStats = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;

        const mahals = await Mahal.find({ mahalowner_id });
        const mahalIds = mahals.map(m => m._id);

        const bookings = await Booking.find({ mahal_id: { $in: mahalIds } });

        const total = bookings.length;
        const confirmed = bookings.filter(b => b.booking_status === 'Confirmed').length;
        const pending = bookings.filter(b => ['Pending', 'Payment Completed', 'Visiting Time Selected', 'Visit Pending'].includes(b.booking_status)).length;
        const qr_verified = bookings.filter(b => b.booking_status === 'QR Verified').length;
        const waiting_user = bookings.filter(b => b.booking_status === 'Waiting For User Confirmation').length;
        const rejected = bookings.filter(b => b.booking_status === 'Rejected').length;
        const cancelled = bookings.filter(b => b.booking_status === 'Cancelled').length;

        return res.status(200).json({
            success: true,
            total, confirmed, pending, qr_verified, waiting_user, rejected, cancelled
        });
    } catch (err) {
        console.error("Error in getDashboardStats:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const getRecentRequests = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const mahals = await Mahal.find({ mahalowner_id });
        const mahalIds = mahals.map(m => m._id);

        const bookings = await Booking.find({ mahal_id: { $in: mahalIds } })
            .populate('mahal_id', 'mahal_name')
            .sort({ _id: -1 })
            .limit(5);

        const requests = [];
        for (const b of bookings) {
            const v = await VisitingRequest.findOne({ booking_id: b._id });
            requests.push({
                booking_id: b._id,
                mahal_id: b.mahal_id._id,
                user_id: b.user_id,
                user_name: b.user_name,
                mbl_no: b.mbl_no,
                booking_date: b.booking_date,
                end_date: b.end_date,
                event_name: b.event_name,
                booking_type: b.booking_type,
                event_time: b.event_time,
                end_time: b.end_time,
                guest_count: b.guest_count,
                total_amt: b.total_amt,
                initial_amt: b.initial_amt,
                booking_status: b.booking_status,
                owner_decision: b.owner_decision,
                user_decision: b.user_decision,
                visiting_date: v ? v.visiting_date : null,
                visiting_time: v ? v.visiting_time : null,
                visit_status: v ? v.visit_status : null,
                qr_token: v ? v.qr_token : null,
                qr_status: v ? v.qr_status : null,
                mahal_name: b.mahal_id.mahal_name
            });
        }

        return res.status(200).json({ success: true, requests });
    } catch (err) {
        console.error("Error in getRecentRequests:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const getBookings = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const mahals = await Mahal.find({ mahalowner_id });
        const mahalIds = mahals.map(m => m._id);

        const bookings = await Booking.find({ mahal_id: { $in: mahalIds } })
            .populate('mahal_id', 'mahal_name')
            .sort({ _id: -1 });

        const mapped = [];
        for (const b of bookings) {
            const v = await VisitingRequest.findOne({ booking_id: b._id });
            mapped.push({
                booking_id: b._id,
                mahal_id: b.mahal_id._id,
                user_id: b.user_id,
                user_name: b.user_name,
                mbl_no: b.mbl_no,
                booking_date: b.booking_date,
                end_date: b.end_date,
                event_name: b.event_name,
                booking_type: b.booking_type,
                event_time: b.event_time,
                end_time: b.end_time,
                guest_count: b.guest_count,
                total_amt: b.total_amt,
                initial_amt: b.initial_amt,
                booking_status: b.booking_status,
                owner_decision: b.owner_decision,
                user_decision: b.user_decision,
                visiting_date: v ? v.visiting_date : null,
                visiting_time: v ? v.visiting_time : null,
                visit_status: v ? v.visit_status : null,
                qr_token: v ? v.qr_token : null,
                qr_status: v ? v.qr_status : null,
                mahal_name: b.mahal_id.mahal_name
            });
        }

        return res.status(200).json({ success: true, bookings: mapped });
    } catch (err) {
        console.error("Error in getBookings:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const getBookingIdFromRequest = (req) => {
    return req.params?.booking_id || req.params?.bookingId || req.body?.booking_id || req.query?.booking_id || req.query?.bookingId;
};

const getOwnerBookingDetails = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const booking_id = getBookingIdFromRequest(req);

        if (!booking_id) {
            return res.status(400).json({ success: false, message: "Booking ID is required." });
        }

        const mahals = await Mahal.find({ mahalowner_id });
        const mahalIds = mahals.map(m => m._id);

        const booking = await Booking.findOne({ _id: booking_id, mahal_id: { $in: mahalIds } }).populate('mahal_id');
        if (!booking) {
            return res.status(404).json({ success: false, message: "Booking not found or not owned by you." });
        }

        const v = await VisitingRequest.findOne({ booking_id: booking._id });

        const details = {
            booking_id: booking._id,
            mahal_id: booking.mahal_id._id,
            user_id: booking.user_id,
            user_name: booking.user_name,
            mbl_no: booking.mbl_no,
            booking_date: booking.booking_date,
            end_date: booking.end_date,
            event_name: booking.event_name,
            booking_type: booking.booking_type,
            event_time: booking.event_time,
            end_time: booking.end_time,
            guest_count: booking.guest_count,
            total_amt: booking.total_amt,
            initial_amt: booking.initial_amt,
            booking_status: booking.booking_status,
            owner_decision: booking.owner_decision,
            user_decision: booking.user_decision,
            visiting_date: v ? v.visiting_date : null,
            visiting_time: v ? v.visiting_time : null,
            visit_status: v ? v.visit_status : null,
            qr_token: v ? v.qr_token : null,
            qr_status: v ? v.qr_status : null,
            mahal_name: booking.mahal_id.mahal_name,
            mahal_address: booking.mahal_id.street_address,
            city: booking.mahal_id.city
        };

        return res.status(200).json({ success: true, booking: details });
    } catch (err) {
        console.error("Error in getOwnerBookingDetails:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const scanQrPass = async (req, res) => {
    try {
        const { qr_token } = req.body;
        if (!qr_token) return res.status(400).json({ success: false, message: "QR Token is required." });

        const v = await VisitingRequest.findOne({ qr_token }).populate('booking_id');
        if (!v) {
            return res.status(404).json({ success: false, message: "Invalid or expired QR Token." });
        }

        if (v.qr_status === 'Used') {
            return res.status(400).json({ success: false, message: "This QR Pass has already been used." });
        }

        v.qr_status = 'Used';
        v.visit_status = 'Visited';
        await v.save();

        if (v.booking_id) {
            v.booking_id.booking_status = 'QR Verified';
            await v.booking_id.save();
            await sendPushNotification({
                user_id: v.booking_id.user_id,
                title: "QR Pass Verified",
                body: "Your visit to the Mahal has been verified. The owner will now confirm your booking.",
                type: "qr_verified"
            });
        }

        return res.status(200).json({ success: true, message: "QR Pass verified successfully." });
    } catch (err) {
        console.error("Error in scanQrPass:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const acceptOwnerBooking = async (req, res) => {
    try {
        const booking_id = getBookingIdFromRequest(req);
        if (!booking_id) {
            return res.status(400).json({ success: false, message: "Booking ID is required." });
        }

        const booking = await Booking.findById(booking_id);

        if (!booking) {
            return res.status(404).json({ success: false, message: "Booking not found." });
        }

        if (booking.booking_status === 'Cancelled' || booking.booking_status === 'Rejected') {
            return res.status(400).json({ success: false, message: "Cannot accept a cancelled or rejected booking." });
        }

        booking.owner_decision = 'Accepted';
        booking.booking_status = 'Waiting For User Confirmation';
        await booking.save();

        const v = await VisitingRequest.findOne({ booking_id: booking._id });
        if (v) {
            v.visit_status = 'Confirmed';
            await v.save();
        }

        await sendPushNotification({
            user_id: booking.user_id,
            title: "Booking Accepted!",
            body: "The Mahal Owner has accepted your booking request.",
            type: "owner_accepted"
        });

        return res.status(200).json({
            success: true,
            message: "Booking accepted successfully.",
            booking_id: booking._id,
            booking_status: booking.booking_status
        });
    } catch (err) {
        console.error("Error in acceptOwnerBooking:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const rejectOwnerBooking = async (req, res) => {
    try {
        const booking_id = getBookingIdFromRequest(req);
        if (!booking_id) {
            return res.status(400).json({ success: false, message: "Booking ID is required." });
        }

        const booking = await Booking.findById(booking_id);

        if (!booking) {
            return res.status(404).json({ success: false, message: "Booking not found." });
        }

        booking.owner_decision = 'Rejected';
        booking.booking_status = 'Rejected';
        await booking.save();

        await sendPushNotification({
            user_id: booking.user_id,
            title: "Booking Cancelled",
            body: "We are sorry, but your booking request was not accepted by the Mahal Owner.",
            type: "owner_rejected"
        });

        return res.status(200).json({
            success: true,
            message: "Booking rejected.",
            booking_id: booking._id,
            booking_status: booking.booking_status
        });
    } catch (err) {
        console.error("Error in rejectOwnerBooking:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const updateBookingStatus = async (req, res) => {
    try {
        const { status } = req.body;
        if (!status) {
            return res.status(400).json({ success: false, message: "Status is required." });
        }
        if (status === 'Confirmed' || status === 'Accepted') {
            return acceptOwnerBooking(req, res);
        } else if (status === 'Rejected') {
            return rejectOwnerBooking(req, res);
        }
        return res.status(400).json({ success: false, message: "Invalid status parameter." });
    } catch (err) {
        console.error("Error in updateBookingStatus:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const getVisitingRequests = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const mahals = await Mahal.find({ mahalowner_id });
        const mahalIds = mahals.map(m => m._id);

        const visits = await VisitingRequest.find({ mahal_id: { $in: mahalIds } })
            .populate('booking_id')
            .sort({ _id: -1 });

        const formatted = visits.map(v => ({
            visit_id: v._id,
            booking_id: v.booking_id ? v.booking_id._id : null,
            user_id: v.user_id,
            user_name: v.booking_id ? v.booking_id.user_name : null,
            mbl_no: v.booking_id ? v.booking_id.mbl_no : null,
            event_name: v.booking_id ? v.booking_id.event_name : null,
            visiting_date: v.visiting_date,
            visiting_time: v.visiting_time,
            visit_status: v.visit_status,
            qr_status: v.qr_status,
            qr_token: v.qr_token,
            expiry_time: null,
            booking_status: v.booking_id ? v.booking_id.booking_status : null
        }));

        return res.status(200).json({ success: true, visiting_requests: formatted });
    } catch (err) {
        console.error("Error in getVisitingRequests:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

module.exports = {
    getDashboardStats,
    getRecentRequests,
    getBookings,
    getOwnerBookingRequests: getBookings,
    getOwnerBookingDetails,
    scanQrPass,
    acceptOwnerBooking,
    rejectOwnerBooking,
    updateBookingStatus,
    getVisitingRequests
};
