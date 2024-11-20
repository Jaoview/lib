const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');
const Room = require('../models/Room');
const { verifyToken } = require('../middleware/auth');

// Create a new booking
router.post('/', verifyToken, async (req, res) => {
    try {
        const { roomId, date, bookingTime } = req.body;
        
        // Check if the timeslot is available
        const existingBooking = await Booking.findOne({
            roomId,
            date: new Date(date),
            bookingTime,
            status: { $in: ['pending', 'approved'] }
        });

        if (existingBooking) {
            return res.status(400).json({ message: 'This timeslot is already booked' });
        }

        // Create new booking
        const booking = new Booking({
            userId: req.user.userId,
            roomId,
            date: new Date(date),
            bookingTime,
            status: 'pending'
        });

        await booking.save();
        res.status(201).json(booking);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all bookings (for admin view)
router.get('/all', verifyToken, async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate('roomId', 'roomName')
            .populate('userId', 'email nickname')
            .sort({ date: -1 });

        const formattedBookings = bookings.map(booking => ({
            id: booking._id,
            roomName: booking.roomId.roomName,
            userEmail: booking.userId.email,
            userNickname: booking.userId.nickname,
            date: booking.date,
            bookingTime: booking.bookingTime,
            status: booking.status,
            createdAt: booking.createdAt
        }));

        res.json(formattedBookings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get user's booking history
router.get('/history', verifyToken, async (req, res) => {
    try {
        const bookings = await Booking.find({ 
            userId: req.user.userId,
            status: { $in: ['approved', 'rejected', 'completed'] }
        })
        .populate('roomId', 'roomName capacity')
        .sort({ date: -1 });

        const formattedBookings = bookings.map(booking => ({
            id: booking._id,
            roomName: booking.roomId.roomName,
            date: booking.date,
            bookingTime: booking.bookingTime,
            status: booking.status,
            createdAt: booking.createdAt
        }));

        res.json(formattedBookings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get user's pending bookings
router.get('/pending', verifyToken, async (req, res) => {
    try {
        const bookings = await Booking.find({ 
            userId: req.user.userId,
            status: 'pending'
        })
        .populate('roomId', 'roomName capacity')
        .sort({ date: 1 });

        const formattedBookings = bookings.map(booking => ({
            id: booking._id,
            roomName: booking.roomId.roomName,
            date: booking.date,
            bookingTime: booking.bookingTime,
            createdAt: booking.createdAt
        }));

        res.json(formattedBookings);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Update booking status (accepting both PATCH and PUT)
router.route('/:bookingId/status')
    .patch(verifyToken, updateBookingStatus)
    .put(verifyToken, updateBookingStatus);

// Separate the handler function
async function updateBookingStatus(req, res) {
    try {
        const { status } = req.body;
        const booking = await Booking.findById(req.params.bookingId)
            .populate('roomId', 'roomName')
            .populate('userId', 'email nickname');

        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }

        // Validate status
        const validStatuses = ['pending', 'approved', 'rejected', 'completed'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ 
                message: 'Invalid status. Must be one of: pending, approved, rejected, completed'
            });
        }

        booking.status = status;
        await booking.save();

        res.json({ 
            message: 'Booking status updated successfully', 
            booking: {
                id: booking._id,
                roomName: booking.roomId.roomName,
                userEmail: booking.userId.email,
                userNickname: booking.userId.nickname,
                date: booking.date,
                bookingTime: booking.bookingTime,
                status: booking.status,
                createdAt: booking.createdAt
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

// Cancel booking
router.delete('/:bookingId', verifyToken, async (req, res) => {
    try {
        const booking = await Booking.findById(req.params.bookingId);

        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }

        if (booking.status !== 'pending') {
            return res.status(400).json({ message: 'Cannot cancel non-pending booking' });
        }

        await booking.deleteOne();
        res.json({ message: 'Booking cancelled successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Dashboard Statistics
router.get('/dashboard', verifyToken, async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const [
            totalBookings,
            pendingBookings,
            approvedBookings,
            rejectedBookings,
            todayBookings,
            upcomingBookings,
            recentBookings
        ] = await Promise.all([
            Booking.countDocuments(),
            Booking.find({ status: 'pending' })
                .populate('roomId', 'roomName')
                .populate('userId', 'email nickname')
                .sort({ date: 1 })
                .limit(5),
            Booking.find({ 
                status: 'approved',
                date: { $gte: today }
            })
            .populate('roomId', 'roomName')
            .populate('userId', 'email nickname')
            .sort({ date: 1 })
            .limit(5),
            Booking.find({ status: 'rejected' })
                .populate('roomId', 'roomName')
                .populate('userId', 'email nickname')
                .sort({ date: -1 })
                .limit(5),
            Booking.find({
                date: {
                    $gte: today,
                    $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
                }
            })
            .populate('roomId', 'roomName')
            .populate('userId', 'email nickname'),
            Booking.find({
                date: { $gt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
            })
            .populate('roomId', 'roomName')
            .populate('userId', 'email nickname')
            .sort({ date: 1 })
            .limit(5),
            Booking.find({
                date: { $lt: today }
            })
            .populate('roomId', 'roomName')
            .populate('userId', 'email nickname')
            .sort({ date: -1 })
            .limit(5)
        ]);

        const formatBookings = (bookings) => bookings.map(booking => ({
            id: booking._id,
            roomName: booking.roomId.roomName,
            userEmail: booking.userId.email,
            userNickname: booking.userId.nickname,
            date: booking.date,
            bookingTime: booking.bookingTime,
            status: booking.status,
            createdAt: booking.createdAt
        }));

        res.json({
            statistics: {
                totalBookings,
                pendingCount: pendingBookings.length,
                approvedCount: approvedBookings.length,
                rejectedCount: rejectedBookings.length,
                todayCount: todayBookings.length
            },
            bookings: {
                pending: formatBookings(pendingBookings),
                approved: formatBookings(approvedBookings),
                rejected: formatBookings(rejectedBookings),
                today: formatBookings(todayBookings),
                upcoming: formatBookings(upcomingBookings),
                recent: formatBookings(recentBookings)
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router; 