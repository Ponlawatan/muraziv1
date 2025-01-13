const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const User = require('../models/User');

// ฟังก์ชันสร้าง token แบบสุ่ม
function generateToken() {
    return crypto.randomBytes(16).toString('hex'); // สร้าง token ความยาว 32 ตัวอักษร
}

// Function สำหรับตรวจสอบรูปแบบรหัสผ่าน
function validatePassword(password) {
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\W).{8,}$/;
    return passwordRegex.test(password);
}

// Register Function
exports.register = async (req, res) => {
    const { username, email, password } = req.body;

    try {
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({ msg: "Email already exists" });
        }

        if (!validatePassword(password)) {
            return res.status(400).json({ 
                msg: "Password must be at least 8 characters long, include uppercase, lowercase, and a special character."
            });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = new User({
            username,
            email,
            password: hashedPassword
        });

        await newUser.save();
        res.status(201).json({ msg: "User registered successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: "Server error" });
    }
};

// Login Function
exports.login = async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ msg: "Invalid credentials" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: "Invalid credentials" });
        }

        const token = generateToken();
        user.tokens = user.tokens.concat({ token });
        await user.save();

        res.json({ token });
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: "Server error" });
    }
};

// Logout Function
exports.logout = async (req, res) => {
    const { token } = req.body;

    try {
        const user = await User.findOne({ "tokens.token": token });
        if (!user) {
            return res.status(400).json({ msg: "Invalid token or already logged out" });
        }

        user.tokens = user.tokens.filter(t => t.token !== token);
        await user.save();

        res.json({ msg: "Logged out successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).json({ msg: "Server error" });
    }
};
