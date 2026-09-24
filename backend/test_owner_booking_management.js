const sql = require("mssql");
require("dotenv").config();

const dbConfig = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: process.env.DB_SERVER,
    database: process.env.DB_DATABASE,
    options: {
        trustServerCertificate: true,
    },
};

const BASE_URL = "http://localhost:3000";

async function runTests() {
    let token = "";
    let mahalowner_id = "";
    let mahal_id = "";
    let test_user_id = "";
    let test_booking_id1 = "";
    let test_booking_id2 = "";

    try {
        console.log("=================================================");
        console.log("TESTING OWNER BOOKING REQUEST MANAGEMENT SYSTEM");
        console.log("=================================================\n");

        // 1. Authenticate Owner
        console.log("1. Authenticating test owner...");
        const verifyOtpRes = await fetch(`${BASE_URL}/api/auth/verify-otp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ phone_number: "9876543210", otp: "1234" })
        });
        const verifyOtpData = await verifyOtpRes.json();
        if (!verifyOtpData.success || !verifyOtpData.token) {
            throw new Error("Owner authentication failed.");
        }
        token = verifyOtpData.token;
        mahalowner_id = verifyOtpData.owner.mahalowner_id;
        console.log("Authenticated MahalOwner ID:", mahalowner_id);

        // Ensure Mahal exists
        await sql.connect(dbConfig);
        let mahalRes = await sql.query(`SELECT TOP 1 mahal_id FROM MAHAL WHERE mahalowner_id = '${mahalowner_id}'`);
        if (mahalRes.recordset.length === 0) {
            console.log("Creating test Mahal for owner...");
            const insertMahalRes = await sql.query(`
                INSERT INTO MAHAL (mahal_name, owner_of_mahal, mahal_price, city, mahalowner_id)
                OUTPUT INSERTED.mahal_id
                VALUES ('Test Royal Palace', 'Test Owner', '50000', 'Chennai', '${mahalowner_id}')
            `);
            mahal_id = insertMahalRes.recordset[0].mahal_id;
        } else {
            mahal_id = mahalRes.recordset[0].mahal_id;
        }
        console.log("Target Mahal ID:", mahal_id);

        // Ensure test user exists
        let userRes = await sql.query(`SELECT TOP 1 user_id FROM USERS`);
        if (userRes.recordset.length === 0) {
            const newUserRes = await sql.query(`
                INSERT INTO USERS (name, mbl_no, email) OUTPUT INSERTED.user_id VALUES ('Jagath Ratchagan', '9876500000', 'jagath@example.com')
            `);
            test_user_id = newUserRes.recordset[0].user_id;
        } else {
            test_user_id = userRes.recordset[0].user_id;
        }

        // 2. Inject Pending Test Bookings
        console.log("\n2. Injecting test pending bookings into DB...");
        const b1Res = await sql.query(`
            INSERT INTO BOOKINGS (mahal_id, user_id, user_name, mbl_no, booking_date, event_name, event_time, end_time, booking_type, total_amt, initial_amt, booking_status)
            OUTPUT INSERTED.booking_id
            VALUES ('${mahal_id}', '${test_user_id}', 'Jagath Ratchagan', '9876500000', '2026-07-22', 'Wedding Reception', '09:00 AM', '02:00 PM', 'Morning', '60000', '20000', 'Pending')
        `);
        test_booking_id1 = b1Res.recordset[0].booking_id;

        const b2Res = await sql.query(`
            INSERT INTO BOOKINGS (mahal_id, user_id, user_name, mbl_no, booking_date, event_name, event_time, end_time, booking_type, total_amt, initial_amt, booking_status)
            OUTPUT INSERTED.booking_id
            VALUES ('${mahal_id}', '${test_user_id}', 'Anand Kumar', '9876511111', '2026-08-10', 'Birthday Gala', '06:00 PM', '11:00 PM', 'Evening', '40000', '15000', 'Pending')
        `);
        test_booking_id2 = b2Res.recordset[0].booking_id;

        console.log(`Injected Bookings: ${test_booking_id1}, ${test_booking_id2}`);

        // Helper function for fetch + json check
        const testFetch = async (url, options = {}) => {
            const res = await fetch(url, options);
            const text = await res.text();
            console.log(`[FETCH] ${url} -> Status: ${res.status}`);
            try {
                return JSON.parse(text);
            } catch (e) {
                console.error(`Response Body (Not JSON): ${text.substring(0, 300)}`);
                throw e;
            }
        };

        // 3. Test GET /api/owner/booking-requests AND GET /owner/booking-requests
        console.log("\n3. Testing GET /api/owner/booking-requests...");
        const reqListData = await testFetch(`${BASE_URL}/api/owner/booking-requests`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        console.log("Booking Requests List Count:", reqListData.requests ? reqListData.requests.length : 0);
        if (!reqListData.success || !reqListData.requests || reqListData.requests.length === 0) {
            throw new Error("GET /api/owner/booking-requests failed.");
        }
        console.log("Sample top item:", reqListData.requests[0].user_name, reqListData.requests[0].event_name);
        console.log("OK");

        // 4. Test GET /api/owner/booking-details/:bookingId
        console.log(`\n4. Testing GET /api/owner/booking-details/${test_booking_id1}...`);
        const reqDetailsData = await testFetch(`${BASE_URL}/api/owner/booking-details/${test_booking_id1}`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        console.log("Booking Details Response:", JSON.stringify(reqDetailsData, null, 2));
        if (!reqDetailsData.success || !reqDetailsData.booking) {
            throw new Error("GET /api/owner/booking-details failed.");
        }
        console.log("OK");

        // 5. Test POST /api/owner/booking/accept
        console.log(`\n5. Testing POST /api/owner/booking/accept for ${test_booking_id1}...`);
        const acceptData = await testFetch(`${BASE_URL}/api/owner/booking/accept`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({ booking_id: test_booking_id1 })
        });
        console.log("Accept Response:", acceptData);
        if (!acceptData.success || acceptData.booking_status !== "Confirmed") {
            throw new Error("POST /api/owner/booking/accept failed.");
        }
        console.log("OK");

        // 6. Test POST /api/owner/booking/reject
        console.log(`\n6. Testing POST /api/owner/booking/reject for ${test_booking_id2}...`);
        const rejectData = await testFetch(`${BASE_URL}/api/owner/booking/reject`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({
                booking_id: test_booking_id2,
                rejection_reason: "Mahal under maintenance on specified date."
            })
        });
        console.log("Reject Response:", rejectData);
        if (!rejectData.success || rejectData.booking_status !== "Rejected") {
            throw new Error("POST /api/owner/booking/reject failed.");
        }
        console.log("OK");

        // 7. Test POST /notification/send
        console.log("\n7. Testing POST /notification/send...");
        const notifData = await testFetch(`${BASE_URL}/notification/send`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({
                user_id: test_user_id,
                title: "Test System Notification",
                body: "This is a test notification payload."
            })
        });
        console.log("Notification Response:", notifData);
        if (!notifData.success) {
            throw new Error("POST /notification/send failed.");
        }
        console.log("OK");

        // Cleanup test entries
        console.log("\n8. Cleaning up test entries...");
        await sql.query(`DELETE FROM NOTIFICATIONS WHERE user_id = '${test_user_id}'`);
        await sql.query(`DELETE FROM BOOKINGS WHERE booking_id IN ('${test_booking_id1}', '${test_booking_id2}')`);
        console.log("Cleanup done.");

        console.log("=================================================");
        console.log("ALL BACKEND OWNER BOOKING SYSTEM TESTS PASSED!");
        console.log("=================================================");
    } catch (err) {
        console.error("Test error:", err);
    } finally {
        await sql.close();
    }
}

runTests();
