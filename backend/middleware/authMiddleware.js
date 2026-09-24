const jwt = require("jsonwebtoken");

/**
 * Authentication middleware to verify JWT.
 * Expects header: Authorization: Bearer <token>
 */
const authMiddleware = (req, res, next) => {
    const authHeader = req.headers["authorization"] || req.headers["Authorization"];
    
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ 
            success: false, 
            message: "Access denied. No token provided." 
        });
    }

    const token = authHeader.split(" ")[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.owner = decoded; // decoded payload has: { mahalowner_id, mbl_no }
        next();
    } catch (err) {
        return res.status(401).json({ 
            success: false, 
            message: "Invalid or expired token." 
        });
    }
};

module.exports = authMiddleware;
