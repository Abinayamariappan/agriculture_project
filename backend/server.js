require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const otpStore = {}; // Store OTPs temporarily

// ✅ Send OTP (Simulating OTP sending)
app.post('/send-otp', (req, res) => {
    const { phone } = req.body;
    const otp = Math.floor(100000 + Math.random() * 900000); // Generate 6-digit OTP
    otpStore[phone] = otp;

    console.log(`OTP for ${phone}: ${otp}`); // Log OTP for testing
    res.json({ success: true, message: `OTP sent to ${phone}` });
});

// ✅ Verify OTP
app.post('/verify-otp', (req, res) => {
    const { phone, otp } = req.body;

    if (otpStore[phone] && otpStore[phone] == otp) {
        delete otpStore[phone]; // Remove OTP after successful verification
        res.json({ success: true, message: "OTP verified successfully!" });
    } else {
        res.json({ success: false, message: "Invalid OTP!" });
    }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});
