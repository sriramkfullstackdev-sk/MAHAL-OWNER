const Mahal = require("../models/Mahal");

/**
 * Save/Update Mahal Technical Specifications
 * POST /api/mahal/details
 */
const saveDetails = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const {
            mahal_name,
            mahal_price,
            mahal_seating_capcity,
            mahal_facility,
            mahal_describtion,
            mahal_manager_name,
            manager_mbl_no,
            mahal_landline_num
        } = req.body;

        if (!mahal_name) {
            return res.status(400).json({ 
                success: false, 
                message: "Mahal name is required." 
            });
        }

        let mahal = await Mahal.findOne({ mahalowner_id });
        if (mahal) {
            mahal.mahal_name = mahal_name;
            mahal.full_day_price = mahal_price || mahal.full_day_price;
            mahal.seat_capacity = mahal_seating_capcity || mahal.seat_capacity;
            if (mahal_facility) {
                mahal.features = mahal_facility.split(",").map(f => f.trim());
            }
            // mahal_describtion ignored as it's not in schema
            // mahal_manager_name ignored as it's not in schema
            mahal.contact_no = manager_mbl_no || mahal.contact_no;
            mahal.contact_no_2 = mahal_landline_num || mahal.contact_no_2;
            
            await mahal.save();
        } else {
            mahal = new Mahal({
                mahal_name,
                mahalowner_id,
                full_day_price: mahal_price,
                seat_capacity: mahal_seating_capcity,
                features: mahal_facility ? mahal_facility.split(",").map(f => f.trim()) : [],
                contact_no: manager_mbl_no,
                contact_no_2: mahal_landline_num
            });
            await mahal.save();
        }

        return res.status(200).json({
            success: true,
            message: "Mahal details saved successfully."
        });
    } catch (err) {
        console.error("Error in saveDetails:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

/**
 * Save/Update Mahal Address Information
 * POST /api/mahal/address
 */
const saveAddress = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const { mahal_address, city } = req.body;

        let mahal = await Mahal.findOne({ mahalowner_id });
        if (mahal) {
            mahal.street_address = mahal_address || mahal.street_address;
            mahal.city = city || mahal.city;
            await mahal.save();
        } else {
            mahal = new Mahal({
                mahal_name: "Unnamed Mahal",
                mahalowner_id,
                street_address: mahal_address,
                city: city
            });
            await mahal.save();
        }

        return res.status(200).json({
            success: true,
            message: "Mahal address saved successfully."
        });
    } catch (err) {
        console.error("Error in saveAddress:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

/**
 * Upload Mahal Image
 * POST /api/mahal/image
 */
const uploadImage = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;

        if (!req.files || Object.keys(req.files).length === 0) {
            return res.status(400).json({ 
                success: false, 
                message: "No image files provided." 
            });
        }

        let mahal = await Mahal.findOne({ mahalowner_id });
        if (!mahal) {
            mahal = new Mahal({
                mahal_name: "Unnamed Mahal",
                mahalowner_id
            });
        }

        let hasImages = false;
        for (let i = 0; i < 6; i++) {
            const fileArray = req.files[`image_${i}`];
            if (fileArray && fileArray.length > 0) {
                const colName = i === 0 ? "mahal_image" : `mahal_images_${i + 1}`;
                mahal[colName] = fileArray[0].buffer;
                hasImages = true;
            }
        }

        if (!hasImages) {
            return res.status(400).json({ success: false, message: "No valid images provided." });
        }

        await mahal.save();

        return res.status(200).json({
            success: true,
            message: "Mahal image uploaded successfully."
        });
    } catch (err) {
        console.error("Error in uploadImage:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

/**
 * Stream Mahal Image File
 * GET /api/mahal/:mahal_id/image
 */
const streamImage = async (req, res) => {
    try {
        const { mahal_id } = req.params;

        const mahal = await Mahal.findById(mahal_id);

        if (!mahal || !mahal.mahal_image) {
            return res.status(404).send("Image not found.");
        }

        res.set("Content-Type", "image/jpeg");
        return res.send(mahal.mahal_image);
    } catch (err) {
        console.error("Error in streamImage:", err);
        return res.status(500).send("Internal server error.");
    }
};

/**
 * Helper function to parse 12-hr/24-hr time string to minutes from midnight
 */
function parseTimeToMinutes(timeStr) {
    if (!timeStr) return null;
    timeStr = String(timeStr).trim().toUpperCase();
    timeStr = timeStr.replace('.', ':');
    
    let isPM = false;
    let isAM = false;
    if (timeStr.includes('PM')) {
        isPM = true;
        timeStr = timeStr.replace('PM', '').trim();
    } else if (timeStr.includes('AM')) {
        isAM = true;
        timeStr = timeStr.replace('AM', '').trim();
    }
    
    const parts = timeStr.split(':');
    let hours = parseInt(parts[0], 10);
    let minutes = parts[1] ? parseInt(parts[1], 10) : 0;
    
    if (isNaN(hours)) return null;
    if (isNaN(minutes)) minutes = 0;
    
    if (isPM && hours < 12) {
        hours += 12;
    } else if (isAM && hours === 12) {
        hours = 0;
    }
    return hours * 60 + minutes;
}

/**
 * Save/Update Default Booking Timings for Owner's Mahal
 * POST /api/mahal/default-timings
 */
const saveDefaultTimings = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const { timings } = req.body;

        const mahal = await Mahal.findOne({ mahalowner_id });

        if (!mahal) {
            return res.status(404).json({
                success: false,
                message: "Please save Mahal details first before configuring default timings."
            });
        }

        let timingList = [];
        if (Array.isArray(timings)) {
            timingList = timings;
        } else if (typeof timings === 'object' && timings !== null) {
            for (const [typeKey, timeVal] of Object.entries(timings)) {
                if (timeVal && timeVal.start_time && timeVal.end_time) {
                    timingList.push({
                        booking_type: typeKey,
                        start_time: timeVal.start_time,
                        end_time: timeVal.end_time
                    });
                }
            }
        } else {
            const types = ["Morning", "Afternoon", "Full Day", "Wedding"];
            types.forEach(type => {
                const keyPrefix = type.toLowerCase().replace(/ /g, '_');
                const start = req.body[`${keyPrefix}_start_time`] || req.body[`${keyPrefix}_start`];
                const end = req.body[`${keyPrefix}_end_time`] || req.body[`${keyPrefix}_end`];
                if (start && end) {
                    timingList.push({
                        booking_type: type,
                        start_time: start,
                        end_time: end
                    });
                }
            });
        }

        if (timingList.length === 0) {
            return res.status(400).json({
                success: false,
                message: "Please provide valid booking timings."
            });
        }

        const parsedMap = {};
        for (const item of timingList) {
            const { booking_type, start_time, end_time } = item;
            if (!booking_type || !start_time || !end_time) {
                return res.status(400).json({
                    success: false,
                    message: "Booking type, start time, and end time are required for all configured timings."
                });
            }

            const startMin = parseTimeToMinutes(start_time);
            const endMin = parseTimeToMinutes(end_time);

            if (startMin === null || endMin === null) {
                return res.status(400).json({
                    success: false,
                    message: `Invalid time format for ${booking_type}. Use format like '06:00 AM' or '12:00 PM'.`
                });
            }

            if (startMin === endMin) {
                return res.status(400).json({
                    success: false,
                    message: `Start time (${start_time}) and end time (${end_time}) cannot be identical for ${booking_type}.`
                });
            }

            const isOvernight = startMin > endMin;

            parsedMap[booking_type] = {
                booking_type,
                start_time,
                end_time,
                startMin,
                endMin,
                isOvernight
            };
        }

        if (parsedMap["Morning"] && parsedMap["Afternoon"]) {
            const m = parsedMap["Morning"];
            const a = parsedMap["Afternoon"];
            if (!m.isOvernight && !a.isOvernight && m.endMin > a.startMin) {
                return res.status(400).json({
                    success: false,
                    message: `Morning end time (${m.end_time}) overlaps with Afternoon start time (${a.start_time}).`
                });
            }
        }

        mahal.default_timings = Object.values(parsedMap).map(p => ({
            booking_type: p.booking_type,
            start_time: p.start_time,
            end_time: p.end_time
        }));

        await mahal.save();

        return res.status(200).json({
            success: true,
            message: "Default booking timings saved successfully."
        });
    } catch (err) {
        console.error("Error in saveDefaultTimings:", err);
        return res.status(500).json({
            success: false,
            message: "Internal server error."
        });
    }
};

/**
 * Get Default Booking Timings
 * GET /api/mahal/default-timings
 * GET /api/mahal/:mahal_id/default-timings
 */
const getDefaultTimings = async (req, res) => {
    try {
        let mahal_id = req.params.mahal_id;

        if (!mahal_id && req.owner) {
            const mahal = await Mahal.findOne({ mahalowner_id: req.owner.mahalowner_id });
            if (mahal) {
                mahal_id = mahal._id;
            }
        }

        if (!mahal_id) {
            return res.status(400).json({
                success: false,
                message: "Mahal ID is required."
            });
        }

        const mahal = await Mahal.findById(mahal_id);
        if (!mahal) {
            return res.status(404).json({ success: false, message: "Mahal not found." });
        }

        const timings = {};
        if (mahal.default_timings) {
            mahal.default_timings.forEach(row => {
                timings[row.booking_type] = {
                    start_time: row.start_time,
                    end_time: row.end_time
                };
            });
        }

        return res.status(200).json({
            success: true,
            mahal_id,
            timings
        });
    } catch (err) {
        console.error("Error in getDefaultTimings:", err);
        return res.status(500).json({
            success: false,
            message: "Internal server error."
        });
    }
};

module.exports = {
    saveDetails,
    saveAddress,
    uploadImage,
    streamImage,
    saveDefaultTimings,
    getDefaultTimings
};
