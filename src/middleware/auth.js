const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    
    if (!token) {
        return res.status(403).json({ message: 'No token provided' });
    }

    if (token.startsWith('Bearer ')) {
        token = token.slice(7, token.length);
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Invalid token' });
    }
};

const isAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Requires admin role' });
    }
    next();
};

const isApprover = (req, res, next) => {
    if (req.user.role !== 'approver') {
        return res.status(403).json({ message: 'Requires approver role' });
    }
    next();
};

module.exports = { verifyToken, isAdmin, isApprover }; 