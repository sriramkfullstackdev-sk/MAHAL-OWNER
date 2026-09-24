const { sql, connectDB } = require("./config/db");

async function migrate() {
    try {
        console.log("Starting DB migration...");
        await connectDB();

        // 1. Create DEFAULT_BOOKING_TIMINGS table if it doesn't exist
        const createTableQuery = `
            IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'DEFAULT_BOOKING_TIMINGS')
            BEGIN
                CREATE TABLE DEFAULT_BOOKING_TIMINGS (
                    timing_id INT IDENTITY(1,1) PRIMARY KEY,
                    mahal_id VARCHAR(300) NOT NULL,
                    booking_type VARCHAR(100) NOT NULL,
                    start_time VARCHAR(50) NOT NULL,
                    end_time VARCHAR(50) NOT NULL,
                    created_at DATETIME DEFAULT GETDATE(),
                    updated_at DATETIME DEFAULT GETDATE(),
                    CONSTRAINT UQ_Mahal_BookingType UNIQUE (mahal_id, booking_type),
                    CONSTRAINT FK_DefaultTimings_Mahal FOREIGN KEY (mahal_id) REFERENCES MAHAL(mahal_id) ON DELETE CASCADE
                );
                PRINT 'DEFAULT_BOOKING_TIMINGS table created.';
            END
            ELSE
            BEGIN
                PRINT 'DEFAULT_BOOKING_TIMINGS table already exists.';
            END
        `;
        await sql.query(createTableQuery);

        // 2. Add booking_type column to BOOKINGS table if it doesn't exist
        const addColumnQuery = `
            IF NOT EXISTS (
                SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
                WHERE TABLE_NAME = 'BOOKINGS' AND COLUMN_NAME = 'booking_type'
            )
            BEGIN
                ALTER TABLE BOOKINGS ADD booking_type VARCHAR(100) NULL;
                PRINT 'booking_type column added to BOOKINGS table.';
            END
            ELSE
            BEGIN
                PRINT 'booking_type column already exists in BOOKINGS table.';
            END
        `;
        await sql.query(addColumnQuery);

        console.log("Migration completed successfully!");
        process.exit(0);
    } catch (err) {
        console.error("Migration error:", err);
        process.exit(1);
    }
}

migrate();
