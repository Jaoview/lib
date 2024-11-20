const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const con = require('./db'); // Import your database config
const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));


const JWT_KEY = 'm0bile2Simple';


// ================= Middleware ================
function verifyUser(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (token == undefined || token == null) {
        // no token
        console.log('No token')
        return res.status(400).send('No token');
    }


    // token found
    if (req.headers.authorization) {
        const tokenString = token.split(' ');
        if (tokenString[0] == 'Bearer') {
            token = tokenString[1];
        }
    }
    jwt.verify(token, JWT_KEY, (err, decoded) => {
        if (err) {
            console.log('Incorrect token');
            return res.status(401).send('Incorrect token');
        }

        else if (decoded.user_role != 'user') {
            console.log('Forbidden to access the data')
            res.status(403).send('Forbidden to access the data');
        }
        else {
            req.decoded = decoded;
            next();
            console.log('Token found')
        }
    });
}


// Register Route
app.post('/register', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: 'Email and password are required' });
    }

    try {
        const [existingUser] = await con.promise().query('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUser.length > 0) {
            return res.status(409).json({ message: 'Email already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const result = await con.promise().query(
            'INSERT INTO users (email, password, role) VALUES (?, ?, ?)',
            [email, hashedPassword, 'user']
        );


        res.status(201).json({ message: 'User created successfully', userId: result[0].insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server error' });
    }
});

// Login Route
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const [results] = await con.promise().query('SELECT * FROM users WHERE email = ?', [email]);
        if (results.length !== 1) {
            return res.status(401).json({ message: 'Incorrect email' });
        }

        const user = results[0];
        const same = await bcrypt.compare(password, user.password);

        if (same) {

            const payload = { "user_id": user.user_id, "user_role": user.role };
            const token = jwt.sign(payload, JWT_KEY, { expiresIn: '1d' });
            console.log(token)
            return res.json({ message: 'Login successful', token: token, user_id: user.user_id, user_role: user.role });

        } else {
            res.status(400).json({ message: 'Wrong password' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Authentication server error' });
    }
});

app.get('/rooms', verifyUser, async (req, res) => {
    try {
        const [results] = await con.promise().query('SELECT roomName, timeslots FROM room');
        const formattedResults = results.map((room) => ({
            roomName: room.roomName,
            timeslots: JSON.parse(room.timeslots), 
        }));

        res.json(formattedResults); 
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// Booking a Room Slot Route
app.post('/book', verifyUser, async (req, res) => {
    const userId = req.decoded.user_id;
    const { roomId, date, bookingTime } = req.body;

    try {
        // Check if the user already has a pending booking
        const [existingBooking] = await con.promise().query(
            'SELECT * FROM request WHERE user_id = ? AND status = "pending"',
            [userId]
        );

        if (existingBooking.length > 0) {
            return res.status(400).json({ message: 'You already have a pending booking.' });
        }

        // Insert the new booking with status "Pending"
        const [result] = await con.promise().query(
            'INSERT INTO request (user_id, room_id, date, booking_time, status) VALUES (?, ?, ?, ?, ?)',
            [userId, roomId, date, bookingTime, 'pending']
        );

        res.status(201).json({ message: 'Booking successful', bookingId: result.insertId });
    } catch (err) {
        console.error('Error request slot:', err);
        res.status(500).json({ message: 'Database error' });
    }
});

// User History Route
app.get('/userHistory', verifyUser, async (req, res) => {
    const userId = req.decoded.user_id;

    const query = `
        SELECT 
            r.room_name,
            b.date,
            b.booking_time,
            b.status
        FROM 
            booking b
        INNER JOIN 
            room r ON b.room_id = r.room_id
        WHERE 
            b.user_id = ? AND 
            b.status != 'pending';
    `;

    try {
        const [results] = await con.promise().query(query, [userId]);
        res.json(results);
    } catch (err) {
        res.status(500).json({ error: 'Database error' });
    }
});

// User Pending Request Route
app.get('/userRequest', verifyUser, async (req, res) => {
    const userId = req.decoded.user_id;

    const query = `
        SELECT 
            r.room_name,
            b.booking_time,
            b.status
        FROM 
            booking b
        INNER JOIN 
            room r ON b.room_id = r.room_id
        WHERE 
            b.user_id = ? AND 
            b.status = 'pending';
    `;

    try {
        const [results] = await con.promise().query(query, [userId]);
        res.json(results);
    } catch (err) {
        res.status(500).json({ error: 'Database error' });
    }
});


// //admin
// app.get('/adminHistory', (req, res) => {
//     console.log("api admin history")
//     const query = `
// SELECT 
//     r.room_name, 
//     b.date, 
//     b.booking_time, 
//     u.nickname AS user_nickname,
//     a.nickname AS approver_nickname,
//     b.status
// FROM 
//     booking b
// JOIN 
//     room r ON b.room_id = r.room_id
// JOIN 
//     user u ON b.user_id = u.user_id
// LEFT JOIN 
//     user a ON b.approver_id = a.user_id
// WHERE 
//    b.status <> 'pending';
// `;

//     con.query(query, (err, results) => {
//         if (err) {
//             res.status(500).json({ error: 'Database error' });
//         } else {
//             res.json(results);
//         }
//     });
// });

// //approver
// app.get('/approverHistory/:userId', (req, res) => {
//     const userId = req.params.userId;
//     console.log("api approver history")

//     const query = `
//   SELECT 
//     r.room_name, 
//     b.date, 
//     b.booking_time, 
//     u.nickname,
//     b.status
// FROM 
//     booking b
// JOIN 
//     room r ON b.room_id = r.room_id
// JOIN 
//     user u ON b.user_id = u.user_id
// WHERE 
//     b.approver_id = ?
//     AND b.status <> 'pending';

// `;

//     con.query(query, [userId], (err, results) => {
//         if (err) {
//             res.status(500).json({ error: 'Database error' });
//         } else {
//             res.json(results);
//         }
//     });
// });


const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
