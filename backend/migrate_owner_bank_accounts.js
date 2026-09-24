const { sql, connectDB } = require("./config/db");

async function migrate() {
    try {
        await connectDB();
        await sql.query(`
            IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'OWNER_BANK_ACCOUNTS')
            BEGIN
                CREATE TABLE OWNER_BANK_ACCOUNTS (
                    bank_account_id INT IDENTITY(1,1) PRIMARY KEY,
                    mahalowner_id VARCHAR(255) NOT NULL UNIQUE,
                    account_holder_name VARCHAR(150) NOT NULL,
                    account_number VARCHAR(50) NOT NULL,
                    bank_name VARCHAR(150) NOT NULL,
                    ifsc_code VARCHAR(20) NOT NULL,
                    branch_name VARCHAR(150) NOT NULL,
                    created_at DATETIME NOT NULL DEFAULT GETDATE(),
                    updated_at DATETIME NOT NULL DEFAULT GETDATE()
                );
            END
        `);
        console.log("OWNER_BANK_ACCOUNTS migration completed successfully.");
        process.exit(0);
    } catch (error) {
        console.error("OWNER_BANK_ACCOUNTS migration failed:", error);
        process.exit(1);
    }
}

migrate();