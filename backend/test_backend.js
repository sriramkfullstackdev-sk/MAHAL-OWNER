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
    let test_booking_id = "";

    try {
        console.log("=========================================");
        console.log("STARTING MAHAL SPOT OWNER BACKEND INTEGRATION TESTS");
        console.log("=========================================\n");

        // 1. Test POST /api/auth/send-otp
        console.log("1. Testing Send OTP...");
        const sendOtpRes = await fetch(`${BASE_URL}/api/auth/send-otp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ phone_number: "9876543210" })
        });
        const sendOtpData = await sendOtpRes.json();
        console.log("Send OTP Response:", sendOtpData);
        if (!sendOtpData.success || !sendOtpData.otp) {
            throw new Error("Send OTP failed.");
        }
        console.log("OK\n");

        // 2. Test POST /api/auth/verify-otp
        console.log("2. Testing Verify OTP (using bypass code 1234)...");
        const verifyOtpRes = await fetch(`${BASE_URL}/api/auth/verify-otp`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                phone_number: "9876543210",
                otp: "1234"
            })
        });
        const verifyOtpData = await verifyOtpRes.json();
        console.log("Verify OTP Response:", verifyOtpData);
        if (!verifyOtpData.success || !verifyOtpData.token) {
            throw new Error("Verify OTP failed.");
        }
        token = verifyOtpData.token;
        mahalowner_id = verifyOtpData.owner.mahalowner_id;
        console.log("Token received:", token.substring(0, 20) + "...");
        console.log("MahalOwner ID:", mahalowner_id);
        console.log("OK\n");

        // 3. Test POST /api/owner/profile
        console.log("3. Testing Save Owner Profile...");
        const saveProfileRes = await fetch(`${BASE_URL}/api/owner/profile`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({
                owner_name: "Test Owner Name",
                address: "123 Test Street",
                city: "Chennai",
                mahal_landline_num: "044-1234567",
                owner_of_mahal: "Venkateshwara Mahal"
            })
        });
        const saveProfileData = await saveProfileRes.json();
        console.log("Save Profile Response:", saveProfileData);
        if (!saveProfileData.success) {
            throw new Error("Save Profile failed.");
        }
        console.log("OK\n");

        // 4. Test GET /api/owner/profile (Profile retrieved, Mahal should be null initially)
        console.log("4. Testing Get Profile (before Mahal registration)...");
        const getProfileRes = await fetch(`${BASE_URL}/api/owner/profile`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        const getProfileData = await getProfileRes.json();
        console.log("Get Profile Response (Mahal should be null):", getProfileData);
        if (!getProfileData.success || getProfileData.mahal !== null) {
            throw new Error("Get Profile (initial) failed.");
        }
        console.log("OK\n");

        // 5. Test POST /api/mahal/details
        console.log("5. Testing Save Mahal Specifications...");
        const saveDetailsRes = await fetch(`${BASE_URL}/api/mahal/details`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({
                mahal_name: "Venkateshwara Mahal",
                mahal_price: "45000",
                mahal_seating_capcity: "600",
                mahal_facility: "AC",
                mahal_describtion: "A beautiful air-conditioned marriage hall.",
                mahal_manager_name: "Rajesh Kumar",
                manager_mbl_no: "9999988888",
                mahal_landline_num: "044-7654321"
            })
        });
        const saveDetailsData = await saveDetailsRes.json();
        console.log("Save Mahal Details Response:", saveDetailsData);
        if (!saveDetailsData.success) {
            throw new Error("Save Mahal Details failed.");
        }
        console.log("OK\n");

        // 6. Test POST /api/mahal/address
        console.log("6. Testing Save Mahal Address...");
        const saveAddressRes = await fetch(`${BASE_URL}/api/mahal/address`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({
                mahal_address: "Door 45, Grand Trunk Road, Chromepet",
                city: "Chennai"
            })
        });
        const saveAddressData = await saveAddressRes.json();
        console.log("Save Mahal Address Response:", saveAddressData);
        if (!saveAddressData.success) {
            throw new Error("Save Mahal Address failed.");
        }
        console.log("OK\n");

        // 7. Test GET /api/owner/profile (Profile retrieved, Mahal should now be populated)
        console.log("7. Testing Get Profile (after Mahal registration)...");
        const getProfileRes2 = await fetch(`${BASE_URL}/api/owner/profile`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        const getProfileData2 = await getProfileRes2.json();
        console.log("Get Profile Response (Mahal details populated):", getProfileData2);
        if (!getProfileData2.success || getProfileData2.mahal === null) {
            throw new Error("Get Profile (populated) failed.");
        }
        mahal_id = getProfileData2.mahal.mahal_id;
        console.log("Retrieved Mahal ID:", mahal_id);
        console.log("OK\n");

        // 8. Test POST /api/mahal/image (Upload mock image file)
        console.log("8. Testing Upload Mahal Image...");
        const boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW";
        const fileContent = "Fake binary image data content for testing varbinary";
        const fileBuffer = Buffer.from(fileContent);
        const multipartBody = Buffer.concat([
            Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="image"; filename="test_hall.jpg"\r\nContent-Type: image/jpeg\r\n\r\n`),
            fileBuffer,
            Buffer.from(`\r\n--${boundary}--\r\n`)
        ]);

        const uploadRes = await fetch(`${BASE_URL}/api/mahal/image`, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${token}`,
                "Content-Type": `multipart/form-data; boundary=${boundary}`
            },
            body: multipartBody
        });
        const uploadData = await uploadRes.json();
        console.log("Upload Image Response:", uploadData);
        if (!uploadData.success) {
            throw new Error("Upload Image failed.");
        }
        console.log("OK\n");

        // 9. Test GET /api/mahal/:mahal_id/image (Stream image file and verify bytes)
        console.log("9. Testing Stream Mahal Image...");
        const streamImageRes = await fetch(`${BASE_URL}/api/mahal/${mahal_id}/image`);
        if (streamImageRes.status !== 200) {
            throw new Error(`Stream image HTTP status error: ${streamImageRes.status}`);
        }
        const contentType = streamImageRes.headers.get("content-type");
        console.log("Image Stream Content-Type:", contentType);
        const streamedBytes = Buffer.from(await streamImageRes.arrayBuffer());
        console.log("Uploaded bytes length:", fileBuffer.length);
        console.log("Streamed bytes length:", streamedBytes.length);
        if (streamedBytes.toString() !== fileContent) {
            throw new Error("Streamed image bytes do not match uploaded image bytes.");
        }
        console.log("OK\n");

        // 10. Inject mock test booking into DB to test stats and updates
        console.log("10. Connecting to DB directly to inject a mock booking...");
        await sql.connect(dbConfig);
        console.log("Database connected.");

        // Check/Create User in USERS table
        let userResult = await sql.query("SELECT TOP 1 user_id, name FROM USERS");
        if (userResult.recordset.length > 0) {
            test_user_id = userResult.recordset[0].user_id;
            console.log(`Found existing user: ${userResult.recordset[0].name} (ID: ${test_user_id})`);
        } else {
            console.log("No users found. Creating a test user...");
            let newUserRes = await sql.query(
                "INSERT INTO USERS (name, mbl_no, address) OUTPUT INSERTED.user_id VALUES ('Test Customer', '9123456789', '456 User St')"
            );
            test_user_id = newUserRes.recordset[0].user_id;
            console.log(`Test user created (ID: ${test_user_id})`);
        }

        // Insert mock Booking request
        console.log("Inserting mock booking request...");
        const insertBookingQuery = `
            INSERT INTO BOOKINGS (mahal_id, user_id, user_name, mbl_no, booking_date, event_name, event_time, total_amt, initial_amt, booking_status)
            OUTPUT INSERTED.booking_id
            VALUES ('${mahal_id}', '${test_user_id}', 'Test Customer', '9123456789', '2026-08-15', 'Wedding', 'Full Day', '45000', '15000', 'Pending')
        `;
        let newBookingRes = await sql.query(insertBookingQuery);
        test_booking_id = newBookingRes.recordset[0].booking_id;
        console.log(`Mock booking injected successfully (Booking ID: ${test_booking_id})`);
        console.log("OK\n");

        // 11. Test GET /api/bookings/dashboard/stats
        console.log("11. Testing Get Dashboard Stats...");
        const statsRes = await fetch(`${BASE_URL}/api/bookings/dashboard/stats`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        const statsData = await statsRes.json();
        console.log("Dashboard Stats Response:", statsData);
        if (!statsData.success || statsData.total !== 1 || statsData.pending !== 1) {
            throw new Error("Get Dashboard Stats failed or stats count mismatch.");
        }
        console.log("OK\n");

        // 12. Test GET /api/bookings/dashboard/requests
        console.log("12. Testing Get Recent Booking Requests...");
        const requestsRes = await fetch(`${BASE_URL}/api/bookings/dashboard/requests`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        const requestsData = await requestsRes.json();
        console.log("Recent Requests Response (Length):", requestsData.requests.length);
        if (!requestsData.success || requestsData.requests.length === 0) {
            throw new Error("Get Recent Requests failed.");
        }
        console.log("OK\n");

        // 13. Test GET /api/bookings
        console.log("13. Testing Get Booking List...");
        const bookingsRes = await fetch(`${BASE_URL}/api/bookings`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        const bookingsData = await bookingsRes.json();
        console.log("Bookings List Response (Length):", bookingsData.bookings.length);
        if (!bookingsData.success || bookingsData.bookings.length === 0) {
            throw new Error("Get Bookings failed.");
        }
        console.log("OK\n");

        // 14. Test POST /api/bookings/:booking_id/status (Approve/Confirm the request)
        console.log(`14. Testing Approve Booking Request (Booking ID: ${test_booking_id})...`);
        const statusUpdateRes = await fetch(`${BASE_URL}/api/bookings/${test_booking_id}/status`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({ status: "Confirmed" })
        });
        const statusUpdateData = await statusUpdateRes.json();
        console.log("Status Update Response:", statusUpdateData);
        if (!statusUpdateData.success) {
            throw new Error("Approve Booking failed.");
        }
        console.log("OK\n");

        // 15. Verify Stats updated
        console.log("15. Verifying updated stats (pending should be 0, confirmed should be 1)...");
        const statsRes2 = await fetch(`${BASE_URL}/api/bookings/dashboard/stats`, {
            headers: { "Authorization": `Bearer ${token}` }
        });
        const statsData2 = await statsRes2.json();
        console.log("Updated Stats Response:", statsData2);
        if (!statsData2.success || statsData2.confirmed !== 1 || statsData2.pending !== 0) {
            throw new Error("Stats verification failed.");
        }
        console.log("OK\n");

        // 16. Clean up database records
        console.log("16. Cleaning up database test records...");
        await sql.query(`DELETE FROM PAYMENTS WHERE booking_id = '${test_booking_id}'`);
        await sql.query(`DELETE FROM BOOKINGS WHERE booking_id = '${test_booking_id}'`);
        await sql.query(`DELETE FROM MAHAL WHERE mahal_id = '${mahal_id}'`);
        await sql.query(`DELETE FROM MAHALOWNER WHERE mahalowner_id = '${mahalowner_id}'`);
        console.log("Clean up finished.");
        console.log("OK\n");

        console.log("=========================================");
        console.log("ALL INTEGRATION TESTS PASSED SUCCESSFULLY!");
        console.log("=========================================");

    } catch (e) {
        console.error("\nTEST SUITE FAILED WITH ERROR:");
        console.error(e);
        
        console.log("\nCleanup notice: Database entries might need manual cleanup if they were not removed due to errors.");
    } finally {
        await sql.close();
    }
}

setTimeout(runTests, 1000);
