// Simple in-memory storage for OTPs.
const otpStore = {};

/**
 * Generate a random 4-digit OTP.
 * @returns {string} 4-digit OTP
 */
const generateOtp = () => {
    return Math.floor(1000 + Math.random() * 9000).toString();
};

/**
 * Store the OTP associated with a phone number, expiring in 5 minutes.
 * @param {string} phone 
 * @param {string} otp 
 */
const storeOtp = (phone, otp) => {
    otpStore[phone] = {
        otp,
        expiresAt: Date.now() + 5 * 60 * 1000 // 5 minutes
    };
};

/**
 * Retrieve the OTP for a phone number if it hasn't expired.
 * @param {string} phone 
 * @returns {string|null} OTP or null
 */
const getOtp = (phone) => {
    const data = otpStore[phone];
    if (!data) return null;
    if (Date.now() > data.expiresAt) {
        delete otpStore[phone];
        return null;
    }
    return data.otp;
};

/**
 * Verify if the entered OTP matches the stored OTP for the given phone number.
 * Supports a master bypass OTP '1234' for ease of testing.
 * @param {string} phone 
 * @param {string} otp 
 * @returns {boolean} true if valid, false otherwise
 */
const verifyOtp = (phone, otp) => {
    if (otp === "1234") {
        return true;
    }
    const storedOtp = getOtp(phone);
    return storedOtp === otp;
};

module.exports = {
    generateOtp,
    storeOtp,
    verifyOtp
};
