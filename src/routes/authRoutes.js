const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');

// Register
router.post('/register', async (req, res) => {
    try {
        const { email, password, nickname, role } = req.body;
        const hashedPassword = await bcrypt.hash(password, 10);
        
        const user = new User({
            email,
            password: hashedPassword,
            nickname,
            role: role || 'user'
        });
        
        await user.save();
        res.status(201).json({ message: 'User created successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Login
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        
        if (!user) {
            return res.status(401).json({ message: 'Authentication failed' });
        }
        
        const isValid = await bcrypt.compare(password, user.password);
        
        if (!isValid) {
            return res.status(401).json({ message: 'Authentication failed' });
        }
        
        const token = jwt.sign(
            { userId: user._id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );
        
        res.json({ 
            token, 
            userId: user._id, 
            role: user.role,
            email: user.email,
            nickname: user.nickname
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get current user info
router.get('/me', verifyToken, (req, res) => {
    res.json({
        userId: req.user.userId,
        role: req.user.role
    });
});

module.exports = router; 