const { sql, connectDB } = require("./config/db");

async function migrate() {
    try {
        console.log("Starting DB migration for Owner Verification & Booking Confirmation Workflow...");
        await connectDB();

        const queries = [
            // 1. Add columns to BOOKINGS table
            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'owner_decision')
             BEGIN
                 ALTER TABLE BOOKINGS ADD owner_decision VARCHAR(50) NULL;
                 PRINT 'owner_decision added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'user_decision')
             BEGIN
                 ALTER TABLE BOOKINGS ADD user_decision VARCHAR(50) NULL;
                 PRINT 'user_decision added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'confirmation_time')
             BEGIN
                 ALTER TABLE BOOKINGS ADD confirmation_time DATETIME NULL;
                 PRINT 'confirmation_time added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'qr_status')
             BEGIN
                 ALTER TABLE BOOKINGS ADD qr_status VARCHAR(50) NULL;
                 PRINT 'qr_status added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'approved_time')
             BEGIN
                 ALTER TABLE BOOKINGS ADD approved_time DATETIME NULL;
                 PRINT 'approved_time added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'rejected_time')
             BEGIN
                 ALTER TABLE BOOKINGS ADD rejected_time DATETIME NULL;
                 PRINT 'rejected_time added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'rejection_reason')
             BEGIN
                 ALTER TABLE BOOKINGS ADD rejection_reason VARCHAR(500) NULL;
                 PRINT 'rejection_reason added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'updated_at')
             BEGIN
                 ALTER TABLE BOOKINGS ADD updated_at DATETIME DEFAULT GETDATE();
                 PRINT 'updated_at added to BOOKINGS';
             END`,

            // 2. Add columns to VISITING_REQUESTS table
            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'VISITING_REQUESTS' AND COLUMN_NAME = 'qr_status')
             BEGIN
                 ALTER TABLE VISITING_REQUESTS ADD qr_status VARCHAR(50) DEFAULT 'Generated';
                 PRINT 'qr_status added to VISITING_REQUESTS';
             END`,

            // 3. Ensure NOTIFICATIONS table exists
            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'NOTIFICATIONS')
             BEGIN
                 CREATE TABLE NOTIFICATIONS (
                     notification_id INT IDENTITY(1,1) PRIMARY KEY,
                     user_id VARCHAR(255) NOT NULL,
                     title VARCHAR(300) NOT NULL,
                     body VARCHAR(1000) NOT NULL,
                     type VARCHAR(100) DEFAULT 'booking',
                     is_read BIT DEFAULT 0,
                     created_at DATETIME DEFAULT GETDATE()
                 );
                 PRINT 'NOTIFICATIONS table created';
             END`
        ];

        for (const q of queries) {
            await sql.query(q);
        }

        console.log("Migration completed successfully!");
        process.exit(0);
    } catch (err) {
        console.error("Migration failed:", err);
        process.exit(1);
    }
}

migrate();
