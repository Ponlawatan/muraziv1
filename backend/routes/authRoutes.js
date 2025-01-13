const express = require('express');
const authController = require('../controllers/authController');

const router = express.Router();

// Route สำหรับ Register
router.post('/register', authController.register);

// Route สำหรับ Login
router.post('/login', authController.login);

// Route สำหรับ Logout
router.post('/logout', authController.logout);


module.exports = router;
