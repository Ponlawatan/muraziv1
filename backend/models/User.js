const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// สร้าง Schema สำหรับผู้ใช้
const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    isVerified: {
        type: Boolean,
        default: false // ฟิลด์นี้จะเก็บสถานะการยืนยัน
    },
    verificationToken: {
        type: String
    }
});

// สร้าง Model จาก Schema
module.exports = mongoose.model('User', userSchema);
