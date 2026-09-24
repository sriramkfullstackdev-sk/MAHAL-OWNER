const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
    mahal_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Mahal', required: true },
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    user_name: { type: String, required: true },
    mbl_no: { type: String, required: true },
    booking_date: { type: Date, required: true },
    end_date: { type: Date },
    event_name: { type: String },
    booking_type: { type: String },
    event_time: { type: String },
    start_time: { type: String },
    end_time: { type: String },
    guest_count: { type: String },
    total_amt: { type: Number },
    initial_amt: { type: Number },
    booking_status: { type: String, default: 'Pending' },
    owner_decision: { type: String, default: 'Pending' },
    user_decision: { type: String, default: 'Pending' },
    payment_status: { type: String, default: 'Pending' },
    payment_method: { type: String },
    payment_id: { type: String },
    payment_date: { type: Date },
    created_at: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Booking', bookingSchema);
