const jwt = require('jsonwebtoken');
const BlacklistedToken = require('../models/BlacklistedToken');

const verifyToken = async (req, res, next) => {
    try {
        let token = req.headers['authorization'] || req.headers['x-access-token'];
        
        if (!token) {
            return res.status(403).json({ message: 'No token provided' });
        }

        if (token.startsWith('Bearer ')) {
            token = token.slice(7, token.length);
        }

        // Check if token is blacklisted
        const blacklistedToken = await BlacklistedToken.findOne({ token });
        if (blacklistedToken) {
            return res.status(401).json({ message: 'Token has been invalidated' });
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        req.token = token; // Store token for potential logout
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Invalid token' });
    }
};

module.exports = { verifyToken }; 