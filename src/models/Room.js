const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
    roomName: {
        type: String,
        required: true,
        unique: true
    },
    timeslots: [{
        type: String
    }],
    capacity: {
        type: Number,
        required: true
    }
}, { timestamps: true });

module.exports = mongoose.model('Room', roomSchema); 