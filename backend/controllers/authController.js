const MahalOwner = require("../models/MahalOwner");
const jwt = require("jsonwebtoken");
const otpHelper = require("../utils/otpHelper");

/**
 * Send OTP API
 * POST /api/auth/send-otp
 */
const checkMobile = async (req, res) => {
    try {
        const mobile = req.body.mobile || req.body.mobileNumber || req.body.phone_number || req.body.phoneNumber;

        if (!mobile) {
            return res.status(400).json({
                success: false,
                message: "Phone number is required."
            });
        }

        const owner = await MahalOwner.findOne({ mbl_no: mobile });
        const exists = !!owner;

        return res.status(200).json({
            success: true,
            exists,
            role: exists ? "OWNER" : null,
            ownerId: exists ? owner._id : null,
        });
    } catch (err) {
        console.error("Error in checkMobile:", err);
        return res.status(500).json({
            success: false,
            message: "Internal server error."
        });
    }
};

const sendOtp = async (req, res) => {
    try {
        const { phone_number } = req.body;

        if (!phone_number) {
            return res.status(400).json({ 
                success: false, 
                message: "Phone number is required." 
            });
        }

        const otp = otpHelper.generateOtp();
        otpHelper.storeOtp(phone_number, otp);

        console.log(`[OTP Service] Generated OTP for ${phone_number}: ${otp}`);

        return res.status(200).json({
            success: true,
            message: "OTP sent successfully.",
            otp: otp // Included for easy integration testing & automation
        });
    } catch (err) {
        console.error("Error in sendOtp:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

/**
 * Verify OTP API
 * POST /api/auth/verify-otp
 */
const verifyOtp = async (req, res) => {
    try {
        const { phone_number, otp } = req.body;

        if (!phone_number || !otp) {
            return res.status(400).json({ 
                success: false, 
                message: "Phone number and OTP are required." 
            });
        }

        const isValid = otpHelper.verifyOtp(phone_number, otp);
        if (!isValid) {
            return res.status(400).json({ 
                success: false, 
                message: "Invalid or expired OTP." 
            });
        }

        // Look up owner before creating a profile for a new owner.
        let owner = await MahalOwner.findOne({ mbl_no: phone_number });
        const isExistingOwner = Boolean(owner?.owner_name?.trim());

        if (!owner) {
            // New owner: Create skeleton owner row
            owner = new MahalOwner({ mbl_no: phone_number });
            await owner.save();
        }

        // Generate JWT
        const token = jwt.sign(
            { mahalowner_id: owner._id.toString(), mbl_no: phone_number },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
        );

        return res.status(200).json({
            success: true,
            message: "OTP verified successfully.",
            isExistingOwner,
            role: "OWNER",
            ownerId: owner._id,
            token,
            owner
        });
    } catch (err) {
        console.error("Error in verifyOtp:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

module.exports = {
    checkMobile,
    sendOtp,
    verifyOtp
};
