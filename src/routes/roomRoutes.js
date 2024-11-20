const express = require('express');
const router = express.Router();
const Room = require('../models/Room');
const { verifyToken } = require('../middleware/auth');
const Booking = require('../models/Booking');

// Mock-up room data
const mockRooms = [
    {
        roomName: "Meeting Room A",
        capacity: 10,
        timeslots: [
            "09:00-10:00",
            "10:00-11:00",
            "11:00-12:00",
            "13:00-14:00",
            "14:00-15:00",
            "15:00-16:00"
        ]
    },
    {
        roomName: "Conference Room B",
        capacity: 20,
        timeslots: [
            "09:00-10:00",
            "10:00-11:00",
            "11:00-12:00",
            "13:00-14:00",
            "14:00-15:00",
            "15:00-16:00"
        ]
    },
    {
        roomName: "Small Room C",
        capacity: 5,
        timeslots: [
            "09:00-10:00",
            "10:00-11:00",
            "11:00-12:00",
            "13:00-14:00",
            "14:00-15:00",
            "15:00-16:00"
        ]
    }
];

// Initialize mock rooms
router.post('/init-mock-rooms', verifyToken, async (req, res) => {
    try {
        // Clear existing rooms
        await Room.deleteMany({});

        // Insert mock rooms
        const rooms = await Room.insertMany(mockRooms);
        res.status(201).json({
            message: 'Mock rooms initialized successfully',
            rooms
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get all rooms with availability status
router.get('/', verifyToken, async (req, res) => {
    try {
        const rooms = await Room.find();
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Get all bookings for today
        const bookings = await Booking.find({
            date: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        });

        const roomsWithStatus = await Promise.all(rooms.map(async (room) => {
            const roomBookings = bookings.filter(b => b.roomId.toString() === room._id.toString());
            const bookedSlots = roomBookings.map(b => b.bookingTime);
            const availableSlots = room.timeslots.filter(slot => !bookedSlots.includes(slot));

            return {
                id: room._id,
                roomName: room.roomName,
                capacity: room.capacity,
                timeslots: room.timeslots.map(slot => ({
                    time: slot,
                    status: bookedSlots.includes(slot) ? 'booked' : 'available'
                })),
                availableSlots,
                totalSlots: room.timeslots.length,
                availableCount: availableSlots.length
            };
        }));

        res.json(roomsWithStatus);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Add new room
router.post('/', verifyToken, async (req, res) => {
    try {
        const { roomName, capacity, timeslots } = req.body;

        // Validate input
        if (!roomName || !capacity || !timeslots || !Array.isArray(timeslots)) {
            return res.status(400).json({ message: 'Invalid room data' });
        }

        // Check for duplicate room name
        const existingRoom = await Room.findOne({ roomName });
        if (existingRoom) {
            return res.status(409).json({ message: 'Room name already exists' });
        }

        const room = new Room({
            roomName,
            capacity,
            timeslots
        });

        await room.save();
        res.status(201).json(room);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get room availability with detailed status
router.get('/availability/:roomId', verifyToken, async (req, res) => {
    try {
        const { roomId } = req.params;
        const { date } = req.query;
        
        const room = await Room.findById(roomId);
        if (!room) {
            return res.status(404).json({ message: 'Room not found' });
        }

        // Get all bookings for this room on the specified date
        const bookings = await Booking.find({
            roomId,
            date: new Date(date)
        }).populate('userId', 'nickname');

        // Create detailed timeslot status
        const timeslotStatus = room.timeslots.map(slot => {
            const booking = bookings.find(b => b.bookingTime === slot);
            return {
                time: slot,
                status: booking ? booking.status : 'available',
                bookedBy: booking ? booking.userId.nickname : null
            };
        });

        res.json({
            roomName: room.roomName,
            capacity: room.capacity,
            date: date,
            timeslots: timeslotStatus,
            availableCount: timeslotStatus.filter(slot => slot.status === 'available').length,
            pendingCount: timeslotStatus.filter(slot => slot.status === 'pending').length,
            bookedCount: timeslotStatus.filter(slot => slot.status === 'approved').length
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get dashboard overview
router.get('/dashboard/overview', verifyToken, async (req, res) => {
    try {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const rooms = await Room.find();
        const todayBookings = await Booking.find({
            date: {
                $gte: today,
                $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000)
            }
        }).populate('roomId userId');

        const overview = {
            totalRooms: rooms.length,
            roomStatus: await Promise.all(rooms.map(async (room) => {
                const roomBookings = todayBookings.filter(b => b.roomId._id.toString() === room._id.toString());
                const availableSlots = room.timeslots.filter(slot => 
                    !roomBookings.some(b => b.bookingTime === slot)
                );

                return {
                    roomName: room.roomName,
                    totalSlots: room.timeslots.length,
                    availableSlots: availableSlots.length,
                    pendingBookings: roomBookings.filter(b => b.status === 'pending').length,
                    approvedBookings: roomBookings.filter(b => b.status === 'approved').length
                };
            })),
            todayStats: {
                totalBookings: todayBookings.length,
                pendingBookings: todayBookings.filter(b => b.status === 'pending').length,
                approvedBookings: todayBookings.filter(b => b.status === 'approved').length
            }
        };

        res.json(overview);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router; 