import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketIO } from 'socket.io';

dotenv.config();

const app = express();
const httpServer = createServer(app);
const io = new SocketIO(httpServer, { cors: { origin: '*' } });

app.use(cors());
app.use(express.json());

// Professional types in Wide Angu
const PROFESSIONAL_TYPES = {
  PHOTOGRAPHER: 'photographer',
  VIDEOGRAPHER: 'videographer',
  VIDEO_EDITOR: 'video_editor',
  PHOTO_EDITOR: 'photo_editor',
  LIGHTING_PRO: 'lighting_professional',
  SOUND_ENGINEER: 'sound_engineer',
  EVENT_SPECIALIST: 'event_specialist',
  DRONE_OPERATOR: 'drone_operator',
  CONTENT_CREATOR: 'content_creator',
  STUDIO_MANAGER: 'studio_manager',
  MAKEUP_ARTIST: 'makeup_artist',
  STYLIST: 'stylist',
  SET_DESIGNER: 'set_designer',
  PRODUCER: 'producer',
  DIRECTOR: 'director'
};

// Service categories
const SERVICE_CATEGORIES = [
  { id: 'photography', name: 'Photography Services', icon: '📸' },
  { id: 'videography', name: 'Videography Services', icon: '🎥' },
  { id: 'editing', name: 'Editing & Post-Production', icon: '✂️' },
  { id: 'lighting', name: 'Lighting Services', icon: '💡' },
  { id: 'audio', name: 'Audio & Sound', icon: '🎙️' },
  { id: 'events', name: 'Event Services', icon: '🎪' },
  { id: 'aerial', name: 'Aerial & Drone', icon: '🚁' },
  { id: 'studio', name: 'Studio Services', icon: '🏢' },
  { id: 'creative', name: 'Creative Services', icon: '🎨' }
];

// Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'Wide Angu Media Professionals API',
    professionals_types: Object.keys(PROFESSIONAL_TYPES).length,
    categories: SERVICE_CATEGORIES.length
  });
});

app.get('/api/v1/professionals/types', (req, res) => {
  res.json({
    success: true,
    data: PROFESSIONAL_TYPES
  });
});

app.get('/api/v1/discover/categories', (req, res) => {
  res.json({
    success: true,
    data: SERVICE_CATEGORIES
  });
});

app.get('/api/v1/discover/professionals', (req, res) => {
  res.json({
    success: true,
    data: {
      professionals: [
        {
          id: 1,
          name: 'Creative Lens Studios',
          type: PROFESSIONAL_TYPES.PHOTOGRAPHER,
          rating: 4.8,
          location: 'Lagos',
          specializations: ['Wedding', 'Corporate', 'Portrait']
        },
        {
          id: 2,
          name: 'ProVideo Solutions',
          type: PROFESSIONAL_TYPES.VIDEOGRAPHER,
          rating: 4.9,
          location: 'Lagos',
          specializations: ['Documentary', 'Commercial', 'Event']
        },
        {
          id: 3,
          name: 'EditMaster Pro',
          type: PROFESSIONAL_TYPES.VIDEO_EDITOR,
          rating: 4.7,
          location: 'Lagos',
          specializations: ['Color Grading', 'Motion Graphics', 'VFX']
        },
        {
          id: 4,
          name: 'LightWorks Professional',
          type: PROFESSIONAL_TYPES.LIGHTING_PRO,
          rating: 4.9,
          location: 'Lagos',
          specializations: ['Stage Lighting', 'Film Lighting', 'Event']
        },
        {
          id: 5,
          name: 'SoundCraft Audio',
          type: PROFESSIONAL_TYPES.SOUND_ENGINEER,
          rating: 4.6,
          location: 'Lagos',
          specializations: ['Live Sound', 'Studio Recording', 'Mixing']
        },
        {
          id: 6,
          name: 'EventPro Masters',
          type: PROFESSIONAL_TYPES.EVENT_SPECIALIST,
          rating: 4.8,
          location: 'Lagos',
          specializations: ['Corporate Events', 'Weddings', 'Conferences']
        },
        {
          id: 7,
          name: 'SkyView Aerials',
          type: PROFESSIONAL_TYPES.DRONE_OPERATOR,
          rating: 4.7,
          location: 'Lagos',
          specializations: ['Aerial Photography', 'Mapping', 'Inspection']
        }
      ],
      total: 7,
      page: 1
    }
  });
});

app.post('/api/v1/discover/instant-capture', (req, res) => {
  const { services, location, date } = req.body;
  res.json({
    success: true,
    message: 'Instant capture request received',
    data: {
      requestId: 'REQ_' + Date.now(),
      services,
      location,
      date,
      matchedProfessionals: Math.floor(Math.random() * 10) + 1
    }
  });
});

app.post('/api/v1/auth/register', (req, res) => {
  const { email, userType, professionalType } = req.body;
  res.json({
    success: true,
    data: {
      user: { 
        id: Date.now(), 
        email, 
        userType,
        professionalType: userType === 'professional' ? professionalType : null
      },
      token: 'jwt_token_here'
    }
  });
});

app.post('/api/v1/bookings', (req, res) => {
  res.json({
    success: true,
    data: {
      bookingId: 'BOOK_' + Date.now(),
      status: 'pending',
      message: 'Booking created successfully'
    }
  });
});

// Socket.IO for real-time features
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  
  socket.on('join-room', (roomId) => {
    socket.join(roomId);
  });
  
  socket.on('message', (data) => {
    io.to(data.roomId).emit('new-message', data);
  });
  
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════╗
║     Wide Angu - Media Professionals Marketplace API       ║
║════════════════════════════════════════════════════════════║
║     Server: http://localhost:${PORT}                      ║
║     API: http://localhost:${PORT}/api/v1                  ║
║     Health: http://localhost:${PORT}/health               ║
║════════════════════════════════════════════════════════════║
║     Supporting ${Object.keys(PROFESSIONAL_TYPES).length} Types of Media Professionals    ║
║════════════════════════════════════════════════════════════║
║  📸 Photographers      🎥 Videographers                   ║
║  ✂️  Editors           💡 Lighting Pros                   ║
║  🎙️  Sound Engineers   🎪 Event Specialists               ║
║  🚁 Drone Operators    🏢 Studio Services                 ║
║  🎨 Content Creators   And Many More...                   ║
╚════════════════════════════════════════════════════════════╝
  `);
});
