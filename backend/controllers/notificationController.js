const { sendPushNotification, saveFcmToken } = require("../services/notificationService");

/**
 * Controller for POST /notification/send
 */
const sendNotificationApi = async (req, res) => {
    try {
        const { user_id, title, body, type } = req.body;

        if (!user_id || !title || !body) {
            return res.status(400).json({
                success: false,
                message: "user_id, title, and body are required fields."
            });
        }

        const result = await sendPushNotification({ user_id, title, body, type });

        if (!result.success) {
            return res.status(500).json({
                success: false,
                message: result.error || "Failed to send notification."
            });
        }

        return res.status(200).json({
            success: true,
            message: "Notification sent successfully.",
            notification: result.notification,
            fcm_sent: result.fcm_sent,
            firebase_message_id: result.firebase_message_id
        });
    } catch (err) {
        console.error("Error in sendNotificationApi:", err);
        return res.status(500).json({
            success: false,
            message: "Internal server error."
        });
    }
};

const saveFcmTokenApi = async (req, res) => {
    try {
        const { fcm_token } = req.body;
        const mahalowner_id = req.owner?.mahalowner_id;

        if (!mahalowner_id) {
            return res.status(401).json({
                success: false,
                message: "Owner session is required."
            });
        }

        if (!fcm_token) {
            return res.status(400).json({
                success: false,
                message: "fcm_token is required."
            });
        }

        const result = await saveFcmToken({ mahalowner_id, fcm_token });

        if (!result.success) {
            return res.status(500).json({
                success: false,
                message: result.error || "Failed to save FCM token."
            });
        }

        return res.status(200).json({
            success: true,
            message: "FCM token saved successfully."
        });
    } catch (err) {
        console.error("Error in saveFcmTokenApi:", err);
        return res.status(500).json({
            success: false,
            message: "Internal server error."
        });
    }
};

module.exports = {
    sendNotificationApi,
    saveFcmTokenApi
};
