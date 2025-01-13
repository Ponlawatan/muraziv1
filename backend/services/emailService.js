const nodemailer = require('nodemailer');
const dotenv = require('dotenv');

dotenv.config();

// สร้าง transporter สำหรับส่งอีเมล
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.EMAIL_USER,  // อีเมลของผู้ส่ง
        pass: process.env.EMAIL_PASS,  // รหัสผ่านของอีเมล
    }
});

// ฟังก์ชันสำหรับส่งอีเมลยืนยัน
exports.sendVerificationEmail = async (user, res) => {
    const verificationToken = crypto.randomBytes(20).toString('hex');
    user.verificationToken = verificationToken;
    await user.save();

    const verificationUrl = `${process.env.BASE_URL}/api/auth/verify/${verificationToken}`;

    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: user.email,
        subject: 'Please verify your email address',
        html: `
            <h3>Welcome ${user.username}!</h3>
            <p>Click the link below to verify your email:</p>
            <a href="${verificationUrl}">Verify Email</a>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        res.status(201).json({ msg: "User registered successfully. Please check your email to verify your account." });
    } catch (err) {
        console.error("Error sending email:", err);
        res.status(500).json({ msg: "Failed to send verification email." });
    }
};
