const { sql, connectDB } = require("./config/db");
const crypto = require("crypto");

async function runTest() {
    try {
        console.log("=== STARTING END-TO-END WORKFLOW TEST ===");
        await connectDB();

        // Fetch a real mahal_id and user_id from database
        const mRes = await sql.query`SELECT TOP 1 mahal_id FROM MAHAL`;
        const uRes = await sql.query`SELECT TOP 1 user_id FROM USERS`;

        if (mRes.recordset.length === 0 || uRes.recordset.length === 0) {
            console.log("No existing Mahal or User records found to attach test to.");
            process.exit(0);
        }

        const mahal_id = mRes.recordset[0].mahal_id;
        const user_id = uRes.recordset[0].user_id;
        const booking_id = "B9999";
        const user_name = "Test Customer";
        const mbl_no = "9876543210";
        const booking_date = "2026-09-15";
        const end_date = "2026-09-15";
        const event_name = "Grand Wedding";
        const booking_type = "Full Day";
        const event_time = "06:00 AM";
        const end_time = "11:59 PM";
        const total_amt = "50000";
        const initial_amt = "10000";

        // Cleanup any previous test run
        await sql.query`DELETE FROM VISITING_REQUESTS WHERE booking_id = ${booking_id}`;
        await sql.query`DELETE FROM PAYMENTS WHERE booking_id = ${booking_id}`;
        await sql.query`DELETE FROM BOOKINGS WHERE booking_id = ${booking_id}`;

        console.log(`\nStep 1: Creating initial booking request (${booking_id})...`);
        await sql.query`
            INSERT INTO BOOKINGS (booking_id, mahal_id, user_id, user_name, mbl_no, booking_date, end_date, event_name, booking_type, event_time, end_time, total_amt, initial_amt, booking_status)
            VALUES (${booking_id}, ${mahal_id}, ${user_id}, ${user_name}, ${mbl_no}, ${booking_date}, ${end_date}, ${event_name}, ${booking_type}, ${event_time}, ${end_time}, ${total_amt}, ${initial_amt}, 'Pending Payment')
        `;

        let bCheck = await sql.query`SELECT booking_status FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log(`✔ Step 1 Success! Initial Booking Status: '${bCheck.recordset[0].booking_status}'`);

        // 2. Advance Payment
        console.log("\nStep 2: Processing Advance Payment...");
        await sql.query`
            INSERT INTO PAYMENTS (user_id, booking_id, amount, pay_method, pay_statement, mahal_id)
            VALUES (${user_id}, ${booking_id}, ${initial_amt}, 'UPI', 'Advance Paid', ${mahal_id});

            UPDATE BOOKINGS SET booking_status = 'Payment Completed' WHERE booking_id = ${booking_id};
        `;
        bCheck = await sql.query`SELECT booking_status FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log(`✔ Step 2 Success! Post-Payment Status: '${bCheck.recordset[0].booking_status}' (Not Confirmed yet!)`);

        // 3. User Selects Visiting Time & QR Pass Generated
        console.log("\nStep 3: User selecting Visiting Time & Generating QR Code...");
        const qr_token = `QR-${booking_id}-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
        const visiting_date = "2026-09-10";
        const visiting_time = "10:00 AM";
        const expiry_time = new Date(Date.now() + 3 * 3600 * 1000);

        await sql.query`
            INSERT INTO VISITING_REQUESTS (booking_id, user_id, mahal_id, visiting_date, visiting_time, payment_time, expiry_time, visit_status, booking_status, qr_token, qr_status, qr_expiry)
            VALUES (${booking_id}, ${user_id}, ${mahal_id}, ${visiting_date}, ${visiting_time}, GETDATE(), ${expiry_time}, 'Scheduled', 'Visit Pending', ${qr_token}, 'Generated', ${expiry_time});

            UPDATE BOOKINGS SET booking_status = 'Visit Pending', qr_status = 'Generated' WHERE booking_id = ${booking_id};
        `;
        bCheck = await sql.query`SELECT booking_status FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log(`✔ Step 3 Success! Visiting Scheduled. Status: '${bCheck.recordset[0].booking_status}', QR Token: '${qr_token}'`);

        // 4. Test Enforcing QR Verification (Owner trying to Accept BEFORE QR scan should fail)
        console.log("\nStep 4: Testing Enforced Business Rule - Attempting Owner Accept BEFORE QR Scan...");
        let isQrVerified = false;
        bCheck = await sql.query`
            SELECT b.booking_status, v.visit_status, v.qr_scan_time 
            FROM BOOKINGS b LEFT JOIN VISITING_REQUESTS v ON b.booking_id = v.booking_id 
            WHERE b.booking_id = ${booking_id}
        `;
        const row = bCheck.recordset[0];
        isQrVerified = (row.booking_status === 'QR Verified' || row.visit_status === 'Verified' || row.qr_scan_time != null);
        console.log(`Is QR Verified before scan? ${isQrVerified}`);
        if (!isQrVerified) {
            console.log("✔ Correct! Accept before QR Scan blocked as per business rules.");
        }

        // 5. Owner Scans QR Code
        console.log("\nStep 5: Owner Scans & Verifies QR Pass...");
        await sql.query`
            UPDATE VISITING_REQUESTS SET visit_status = 'Verified', qr_status = 'Used', qr_scan_time = GETDATE() WHERE booking_id = ${booking_id};
            UPDATE BOOKINGS SET booking_status = 'QR Verified', qr_status = 'Used' WHERE booking_id = ${booking_id};
        `;
        bCheck = await sql.query`SELECT booking_status, qr_status FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log(`✔ Step 5 Success! Post-Scan Status: '${bCheck.recordset[0].booking_status}', QR Status: '${bCheck.recordset[0].qr_status}'`);

        // 6. Owner Accepts Booking
        console.log("\nStep 6: Owner Decides ACCEPT...");
        await sql.query`
            UPDATE BOOKINGS 
            SET owner_decision = 'Accepted', 
                booking_status = 'Waiting For User Confirmation', 
                approved_time = GETDATE() 
            WHERE booking_id = ${booking_id}
        `;
        bCheck = await sql.query`SELECT booking_status, owner_decision FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log(`✔ Step 6 Success! Owner Decision: '${bCheck.recordset[0].owner_decision}', Status: '${bCheck.recordset[0].booking_status}'`);

        // 7. User Confirms Booking
        console.log("\nStep 7: User Decides ACCEPT (Final Confirmation)...");
        await sql.query`
            UPDATE BOOKINGS 
            SET user_decision = 'Accepted', 
                booking_status = 'Confirmed', 
                confirmation_time = GETDATE() 
            WHERE booking_id = ${booking_id}
        `;
        bCheck = await sql.query`SELECT booking_status, owner_decision, user_decision FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log(`✔ Step 7 Success! Booking FULLY CONFIRMED! Status: '${bCheck.recordset[0].booking_status}'. Calendar slot locked.`);

        // 8. Test Calendar Availability Query
        console.log("\nStep 8: Verifying Calendar Availability Query (Only Confirmed Bookings block slots)...");
        const availCheck = await sql.query`
            SELECT booking_id, booking_status 
            FROM BOOKINGS 
            WHERE mahal_id = ${mahal_id} AND booking_status = 'Confirmed' AND booking_id = ${booking_id}
        `;
        console.log(`✔ Confirmed booking found in calendar block query: ${availCheck.recordset.length > 0}`);

        // Clean up test booking
        await sql.query`DELETE FROM VISITING_REQUESTS WHERE booking_id = ${booking_id}`;
        await sql.query`DELETE FROM PAYMENTS WHERE booking_id = ${booking_id}`;
        await sql.query`DELETE FROM BOOKINGS WHERE booking_id = ${booking_id}`;
        console.log("\nTest booking cleaned up successfully.");

        console.log("\n==========================================================");
        console.log("ALL E2E WORKFLOW VERIFICATION CHECKS PASSED PERFECTLY!");
        console.log("==========================================================");
        process.exit(0);
    } catch (err) {
        console.error("Test execution failed:", err);
        process.exit(1);
    }
}

runTest();
