const { sql, connectDB } = require("./config/db");

async function migrate() {
    try {
        console.log("Starting DB migration for Owner Booking Request Management...");
        await connectDB();

        const queries = [
            // 1. Add columns to BOOKINGS table
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

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'guest_count')
             BEGIN
                 ALTER TABLE BOOKINGS ADD guest_count VARCHAR(100) NULL;
                 PRINT 'guest_count added to BOOKINGS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'updated_at')
             BEGIN
                 ALTER TABLE BOOKINGS ADD updated_at DATETIME DEFAULT GETDATE();
                 PRINT 'updated_at added to BOOKINGS';
             END`,

            // 2. Add columns to USERS table
            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'USERS' AND COLUMN_NAME = 'email')
             BEGIN
                 ALTER TABLE USERS ADD email VARCHAR(300) NULL;
                 PRINT 'email added to USERS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'USERS' AND COLUMN_NAME = 'fcm_token')
             BEGIN
                 ALTER TABLE USERS ADD fcm_token VARCHAR(500) NULL;
                 PRINT 'fcm_token added to USERS';
             END`,

            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'MAHALOWNER' AND COLUMN_NAME = 'fcm_token')
             BEGIN
                 ALTER TABLE MAHALOWNER ADD fcm_token VARCHAR(500) NULL;
                 PRINT 'fcm_token added to MAHALOWNER';
             END`,

            // 3. Add column to PAYMENTS table
            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PAYMENTS' AND COLUMN_NAME = 'created_at')
             BEGIN
                 ALTER TABLE PAYMENTS ADD created_at DATETIME DEFAULT GETDATE();
                 PRINT 'created_at added to PAYMENTS';
             END`,

            // 4. Create NOTIFICATIONS table
            `IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'NOTIFICATIONS')
             BEGIN
                 CREATE TABLE NOTIFICATIONS (
                     notification_id INT IDENTITY(1,1) PRIMARY KEY,
                     user_id VARCHAR(10) NOT NULL,
                     title VARCHAR(300) NOT NULL,
                     body VARCHAR(1000) NOT NULL,
                     type VARCHAR(100) DEFAULT 'booking',
                     is_read BIT DEFAULT 0,
                     created_at DATETIME DEFAULT GETDATE(),
                     CONSTRAINT FK_Notifications_Users FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE
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
