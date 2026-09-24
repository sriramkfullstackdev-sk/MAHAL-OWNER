const MahalOwner = require("../models/MahalOwner");
const Mahal = require("../models/Mahal");

/**
 * Get Owner Profile & Mahal Details
 * GET /api/owner/profile
 */
const getProfile = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;

        const owner = await MahalOwner.findById(mahalowner_id);
        if (!owner) {
            return res.status(404).json({ 
                success: false, 
                message: "Owner profile not found." 
            });
        }

        const profile = {
            mahalowner_id: owner._id,
            owner_name: owner.owner_name,
            owner_of_mahal: owner.owner_of_mahal,
            address: owner.address,
            mbl_no: owner.mbl_no,
            mahal_landline_num: owner.mahal_landline_num,
            city: owner.city
        };

        const mahalDoc = await Mahal.findOne({ mahalowner_id });
        const mahal = mahalDoc ? {
            mahal_id: mahalDoc._id,
            mahal_name: mahalDoc.mahal_name,
            mahal_price: mahalDoc.full_day_price, // Assuming mahal_price Maps to full_day_price
            mahal_seating_capcity: mahalDoc.seat_capacity,
            mahal_facility: mahalDoc.features ? mahalDoc.features.join(", ") : null,
            mahal_describtion: null, // Was describtion, not in new schema, ignore for now
            mahal_address: mahalDoc.street_address,
            mahal_manager_name: null,
            manager_mbl_no: mahalDoc.contact_no,
            mahal_landline_num: mahalDoc.contact_no_2,
            city: mahalDoc.city
        } : null;

        return res.status(200).json({
            success: true,
            profile,
            mahal
        });
    } catch (err) {
        console.error("Error in getProfile:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

/**
 * Update Owner Profile Details
 * POST /api/owner/profile
 */
const updateProfile = async (req, res) => {
    try {
        const { mahalowner_id } = req.owner;
        const { owner_name, address, city, mahal_landline_num, owner_of_mahal } = req.body;

        await MahalOwner.findByIdAndUpdate(mahalowner_id, {
            owner_name,
            address,
            city,
            mahal_landline_num,
            owner_of_mahal
        });

        return res.status(200).json({
            success: true,
            message: "Profile updated successfully."
        });
    } catch (err) {
        console.error("Error in updateProfile:", err);
        return res.status(500).json({ 
            success: false, 
            message: "Internal server error." 
        });
    }
};

const getBankAccount = async (req, res) => {
    try {
        const owner = await MahalOwner.findById(req.owner.mahalowner_id);
        
        let account = null;
        if (owner && owner.bank_account_holder_name) {
            account = {
                account_holder_name: owner.bank_account_holder_name,
                account_number: owner.bank_account_number,
                bank_name: owner.bank_name,
                ifsc_code: owner.bank_ifsc_code,
                branch_name: owner.bank_branch_name
            };
        }

        return res.status(200).json({
            success: true,
            account: account
        });
    } catch (err) {
        console.error("Error in getBankAccount:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

const saveBankAccount = async (req, res) => {
    try {
        const { account_holder_name, account_number, bank_name, ifsc_code, branch_name } = req.body;
        if (![account_holder_name, account_number, bank_name, ifsc_code, branch_name].every(Boolean)) {
            return res.status(400).json({ success: false, message: "All bank account details are required." });
        }

        await MahalOwner.findByIdAndUpdate(req.owner.mahalowner_id, {
            bank_account_holder_name: account_holder_name.trim(),
            bank_account_number: account_number.trim(),
            bank_name: bank_name.trim(),
            bank_ifsc_code: ifsc_code.trim().toUpperCase(),
            bank_branch_name: branch_name.trim()
        });

        return res.status(200).json({ success: true, message: "Bank account details saved successfully." });
    } catch (err) {
        console.error("Error in saveBankAccount:", err);
        return res.status(500).json({ success: false, message: "Internal server error." });
    }
};

module.exports = {
    getProfile,
    updateProfile,
    getBankAccount,
    saveBankAccount
};
