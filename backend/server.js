const express = require("express");
const cors = require("cors");
require("dotenv").config();

const { connectDB } = require("./config/db");
const logger = require("./utils/logger");

const authRoutes = require("./routes/authRoutes");
const ownerRoutes = require("./routes/ownerRoutes");
const mahalRoutes = require("./routes/mahalRoutes");
const bookingRoutes = require("./routes/bookingRoutes");
const notificationRoutes = require("./routes/notificationRoutes");

const app = express();

app.use(cors());
app.use(express.json());
app.use(logger);

// Mount Routes
app.use("/api/auth", authRoutes);
app.use("/api/owner", ownerRoutes);
app.use("/owner", ownerRoutes); // Support prefix without /api
app.use("/api/mahal", mahalRoutes);
app.use("/api/bookings", bookingRoutes);
app.use("/api/notification", notificationRoutes);
app.use("/notification", notificationRoutes); // Support exact prompt requirement /notification/send

// Health check endpoint
app.get("/api/health", (req, res) => {
    res.status(200).json({ status: "OK", timestamp: new Date() });
});

// Global Error Handler Middleware
app.use((err, req, res, next) => {
    console.error("Unhandled express error:", err);
    res.status(500).json({
        success: false,
        message: err.message || "Internal server error."
    });
});

// Prevent Node process from crashing on uncaught exceptions or unhandled promise rejections
process.on("uncaughtException", (err) => {
    console.error("Uncaught Exception caught:", err.message);
});

process.on("unhandledRejection", (reason, promise) => {
    console.error("Unhandled Rejection at:", promise, "reason:", reason);
});

const PORT = process.env.PORT || 3000;

const startServer = async () => {
    try {
        await connectDB();
        const server = app.listen(PORT, "0.0.0.0", () => {
            console.log(`Server Running on Port ${PORT} (0.0.0.0)`);
        });

        server.on("error", (err) => {
            if (err.code === "EADDRINUSE") {
                console.error(`ERROR: Port ${PORT} is already in use by another process!`);
                console.error(`Please kill the process using port ${PORT} or check running background tasks.`);
            } else {
                console.error("Server error:", err);
            }
        });
    } catch (err) {
        console.error("Failed to start server:", err);
    }
};

startServer();