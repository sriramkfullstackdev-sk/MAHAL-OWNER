const admin = require("firebase-admin");
const fs = require("fs");
const path = require("path");
const User = require("../models/User");
const MahalOwner = require("../models/MahalOwner");
const Notification = require("../models/Notification");

const initializeFirebase = () => {
    if (admin.apps.length > 0) return;

    const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS ||
        path.join(__dirname, "serviceAccountKey.json");

    if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: serviceAccount.project_id
        });
        return;
    }

    admin.initializeApp({
        credential: admin.credential.applicationDefault()
    });
};

const findDeviceToken = async (user_id) => {
    // Check User first
    const user = await User.findById(user_id);
    if (user && user.fcm_token) {
        return {
            token: user.fcm_token,
            name: user.name,
            phone: user.mbl_no,
            table: 'User'
        };
    }

    // Check Owner
    const owner = await MahalOwner.findById(user_id);
    if (owner && owner.fcm_token) {
        return {
            token: owner.fcm_token,
            name: owner.owner_name,
            phone: owner.mbl_no,
            table: 'MahalOwner'
        };
    }

    return {
        token: null,
        name: null,
        phone: null,
        table: null
    };
};

const saveFcmToken = async ({ mahalowner_id, fcm_token }) => {
    try {
        if (!mahalowner_id || !fcm_token) {
            throw new Error("mahalowner_id and fcm_token are required.");
        }

        await MahalOwner.findByIdAndUpdate(mahalowner_id, { fcm_token });

        return {
            success: true,
            message: "FCM token saved successfully."
        };
    } catch (err) {
        console.error("Error in saveFcmToken service:", err);
        return {
            success: false,
            error: err.message
        };
    }
};

/**
 * Send Push Notification & Save Notification Record to Database
 */
const sendPushNotification = async ({ user_id, title, body, type = 'booking' }) => {
    try {
        if (!user_id || !title || !body) {
            throw new Error("user_id, title, and body are required for notification.");
        }

        const notification = new Notification({
            user_id,
            title,
            body,
            type
        });
        await notification.save();

        const device = await findDeviceToken(user_id);

        console.log(`[NOTIFICATION SENT] To ${device.table || 'User'}: ${device.name || user_id} (${device.phone || 'No Phone'})`);
        console.log(`Title: ${title}`);
        console.log(`Body: ${body}`);

        let firebaseMessage = null;
        if (device.token) {
            console.log(`Push Dispatching to FCM Token: ${device.token}`);
            initializeFirebase();
            firebaseMessage = await admin.messaging().send({
                token: device.token,
                notification: {
                    title,
                    body
                },
                data: {
                    type,
                    user_id: String(user_id),
                    title,
                    body
                }
            });
        }

        return {
            success: true,
            notification: notification,
            fcm_sent: Boolean(device.token),
            firebase_message_id: firebaseMessage || null
        };
    } catch (err) {
        console.error("Error in sendPushNotification service:", err);
        return {
            success: false,
            error: err.message
        };
    }
};

module.exports = {
    sendPushNotification,
    saveFcmToken
};
