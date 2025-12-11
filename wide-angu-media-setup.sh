#!/bin/bash

# Wide Angu - Media Professionals Marketplace Setup Script
# Connects clients with ALL media professionals: photographers, videographers, editors, lighting pros, event specialists, etc.

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ASCII Art Banner
show_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║  ██╗    ██╗██╗██████╗ ███████╗     █████╗ ███╗   ██╗    ║
║  ██║    ██║██║██╔══██╗██╔════╝    ██╔══██╗████╗  ██║    ║
║  ██║ █╗ ██║██║██║  ██║█████╗      ███████║██╔██╗ ██║    ║
║  ██║███╗██║██║██║  ██║██╔══╝      ██╔══██║██║╚██╗██║    ║
║  ╚███╔███╔╝██║██████╔╝███████╗    ██║  ██║██║ ╚████║    ║
║   ╚══╝╚══╝ ╚═╝╚═════╝ ╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝    ║
║                                                           ║
║       Media Professionals Marketplace Platform           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    local missing_deps=()
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("Node.js")
    else
        echo -e "${GREEN}✓${NC} Node.js $(node --version)"
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_deps+=("npm")
    else
        echo -e "${GREEN}✓${NC} npm $(npm --version)"
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    else
        echo -e "${GREEN}✓${NC} git $(git --version | cut -d' ' -f3)"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "${RED}Missing required dependencies: ${missing_deps[*]}${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All required dependencies installed!${NC}\n"
}

# Main installation function
main() {
    clear
    show_banner
    
    echo -e "${WHITE}Welcome to Wide Angu - Media Professionals Marketplace Setup!${NC}"
    echo -e "${CYAN}Connecting clients with photographers, videographers, editors,${NC}"
    echo -e "${CYAN}lighting professionals, event specialists, and more!${NC}\n"
    
    check_prerequisites
    
    # Get project directory
    read -p "Enter project directory name (default: wide-angu): " PROJECT_NAME
    PROJECT_NAME=${PROJECT_NAME:-wide-angu}
    
    echo -e "\n${BLUE}Creating Wide Angu project in ./${PROJECT_NAME}...${NC}"
    mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME"
    
    # Create backend
    echo -e "${YELLOW}Setting up backend API...${NC}"
    mkdir -p backend/src/{config,controllers,middleware,models,routes,services,utils,sockets}
    
    # Create package.json
    cat > backend/package.json << 'PACKAGE'
{
  "name": "wide-angu-backend",
  "version": "1.0.0",
  "description": "Wide Angu - Media Professionals Marketplace API",
  "main": "dist/server.js",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest --coverage",
    "lint": "eslint src/**/*.ts",
    "migrate": "ts-node src/scripts/migrate.ts"
  },
  "keywords": ["marketplace", "media", "professionals", "videography", "photography", "editing", "events"],
  "license": "MIT"
}
PACKAGE
    
    # Install dependencies
    cd backend
    echo -e "${YELLOW}Installing dependencies...${NC}"
    npm install express cors helmet morgan compression dotenv \
               jsonwebtoken bcryptjs joi uuid \
               multer sharp \
               pg sequelize sequelize-typescript \
               redis ioredis bull \
               socket.io \
               winston express-rate-limit \
               stripe axios nodemailer
               
    npm install -D typescript tsx @types/node @types/express \
                  @types/cors @types/bcryptjs @types/jsonwebtoken \
                  nodemon eslint prettier jest @types/jest ts-jest
    
    # Create TypeScript config
    cat > tsconfig.json << 'TSCONFIG'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
TSCONFIG
    
    # Create main server file
    cat > src/server.ts << 'SERVER'
import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

const app: Application = express();
const httpServer = createServer(app);
const io = new SocketServer(httpServer, {
  cors: {
    origin: process.env.CLIENT_URL?.split(',') || '*',
    credentials: true
  }
});

// Middleware
app.use(helmet({ crossOriginResourcePolicy: { policy: "cross-origin" } }));
app.use(cors());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Static files for media uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'Wide Angu Media Professionals API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// API Info
app.get('/api', (req, res) => {
  res.json({
    name: 'Wide Angu API',
    description: 'Media Professionals Marketplace Platform',
    professionals: [
      'Photographers',
      'Videographers', 
      'Video Editors',
      'Photo Editors',
      'Lighting Professionals',
      'Sound Engineers',
      'Event Specialists',
      'Drone Operators',
      'Content Creators',
      'Studio Managers'
    ],
    endpoints: {
      auth: '/api/v1/auth',
      users: '/api/v1/users',
      professionals: '/api/v1/professionals',
      bookings: '/api/v1/bookings',
      discover: '/api/v1/discover',
      messages: '/api/v1/messages',
      wallet: '/api/v1/wallet',
      portfolio: '/api/v1/portfolio',
      reviews: '/api/v1/reviews'
    }
  });
});

const API_PREFIX = '/api/v1';

// Sample discovery endpoint with various media professionals
app.get(`${API_PREFIX}/discover/professionals`, (req, res) => {
  const { category, location, priceMin, priceMax } = req.query;
  
  res.json({
    success: true,
    data: {
      professionals: [
        {
          id: '1',
          businessName: 'Creative Lens Studios',
          type: 'photographer',
          category: 'Photography',
          specializations: ['Wedding', 'Corporate Events', 'Portrait'],
          rating: 4.8,
          reviews: 156,
          hourlyRate: 150,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          portfolio_count: 45
        },
        {
          id: '2',
          businessName: 'Skyline Productions',
          type: 'videographer',
          category: 'Videography',
          specializations: ['Corporate', 'Documentary', 'Music Videos', 'Commercials'],
          rating: 4.9,
          reviews: 89,
          hourlyRate: 200,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          portfolio_count: 32
        },
        {
          id: '3',
          businessName: 'EditPro Services',
          type: 'editor',
          category: 'Video Editing',
          specializations: ['Color Grading', 'Motion Graphics', 'Post-Production'],
          rating: 4.7,
          reviews: 203,
          projectRate: 500,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          turnaround: '24-48 hours'
        },
        {
          id: '4',
          businessName: 'Lumina Lighting',
          type: 'lighting_professional',
          category: 'Lighting',
          specializations: ['Stage Lighting', 'Film Lighting', 'Event Lighting'],
          rating: 4.9,
          reviews: 67,
          dailyRate: 800,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          equipment: ['LED Panels', 'Softboxes', 'Lighting Rigs']
        },
        {
          id: '5',
          businessName: 'EventMaster Plus',
          type: 'event_professional',
          category: 'Events',
          specializations: ['Weddings', 'Corporate', 'Concerts', 'Conferences'],
          rating: 4.6,
          reviews: 124,
          packageRate: 2000,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          team_size: 12
        },
        {
          id: '6',
          businessName: 'Aerial Vision',
          type: 'drone_operator',
          category: 'Aerial Media',
          specializations: ['Real Estate', 'Events', 'Surveying', 'Cinematography'],
          rating: 4.8,
          reviews: 45,
          hourlyRate: 250,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          certifications: ['FAA Licensed', 'Insurance Coverage']
        },
        {
          id: '7',
          businessName: 'SoundScape Audio',
          type: 'sound_engineer',
          category: 'Audio',
          specializations: ['Live Events', 'Studio Recording', 'Post-Production'],
          rating: 4.7,
          reviews: 78,
          hourlyRate: 180,
          location: 'Lagos, Nigeria',
          verified: true,
          available: true,
          equipment: ['Professional Mics', 'Mixing Console', 'Audio Interface']
        }
      ],
      total: 7,
      categories: [
        { name: 'Photography', count: 145 },
        { name: 'Videography', count: 98 },
        { name: 'Video Editing', count: 76 },
        { name: 'Photo Editing', count: 65 },
        { name: 'Lighting', count: 34 },
        { name: 'Events', count: 89 },
        { name: 'Sound/Audio', count: 43 },
        { name: 'Drone/Aerial', count: 28 }
      ],
      filters: {
        location: location || 'all',
        category: category || 'all',
        priceRange: { min: priceMin || 0, max: priceMax || 10000 }
      }
    }
  });
});

// Instant Capture endpoint for quick booking
app.post(`${API_PREFIX}/discover/instant-capture`, (req, res) => {
  const { eventType, eventDate, location, services } = req.body;
  
  res.json({
    success: true,
    message: 'Instant capture request processed',
    data: {
      eventType,
      eventDate,
      location,
      requestedServices: services,
      matchedProfessionals: 5,
      estimatedBudget: {
        min: 1500,
        max: 5000,
        currency: 'USD'
      },
      bookingId: 'BOOK_' + Date.now()
    }
  });
});

// Categories endpoint
app.get(`${API_PREFIX}/discover/categories`, (req, res) => {
  res.json({
    success: true,
    data: {
      categories: [
        {
          id: 'photography',
          name: 'Photography',
          icon: '📸',
          subcategories: ['Wedding', 'Portrait', 'Event', 'Product', 'Fashion', 'Real Estate'],
          professionals_count: 145
        },
        {
          id: 'videography',
          name: 'Videography',
          icon: '🎥',
          subcategories: ['Wedding', 'Corporate', 'Documentary', 'Music Video', 'Commercial'],
          professionals_count: 98
        },
        {
          id: 'editing',
          name: 'Editing Services',
          icon: '✂️',
          subcategories: ['Video Editing', 'Photo Editing', 'Color Grading', 'Motion Graphics'],
          professionals_count: 141
        },
        {
          id: 'lighting',
          name: 'Lighting',
          icon: '💡',
          subcategories: ['Stage Lighting', 'Studio Lighting', 'Event Lighting', 'Film Lighting'],
          professionals_count: 34
        },
        {
          id: 'audio',
          name: 'Audio/Sound',
          icon: '🎙️',
          subcategories: ['Sound Recording', 'Live Sound', 'Audio Mixing', 'Sound Design'],
          professionals_count: 43
        },
        {
          id: 'events',
          name: 'Event Services',
          icon: '🎪',
          subcategories: ['Event Planning', 'Event Coverage', 'Live Streaming', 'Coordination'],
          professionals_count: 89
        },
        {
          id: 'aerial',
          name: 'Aerial/Drone',
          icon: '🚁',
          subcategories: ['Aerial Photography', 'Aerial Videography', 'Mapping', 'Inspection'],
          professionals_count: 28
        },
        {
          id: 'studio',
          name: 'Studio Services',
          icon: '🏢',
          subcategories: ['Studio Rental', 'Equipment Rental', 'Set Design', 'Props'],
          professionals_count: 22
        }
      ]
    }
  });
});

// Sample auth endpoints
app.post(`${API_PREFIX}/auth/register`, (req, res) => {
  const { email, password, userType, professionalType } = req.body;
  
  res.json({
    success: true,
    message: 'Registration successful',
    data: {
      user: {
        id: 'USER_' + Date.now(),
        email,
        userType,
        professionalType: userType === 'professional' ? professionalType : null
      },
      accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
    }
  });
});

// Socket.IO for real-time features
io.on('connection', (socket) => {
  console.log(`New connection: ${socket.id}`);
  
  // Join conversation room
  socket.on('join-conversation', (conversationId: string) => {
    socket.join(`conversation:${conversationId}`);
    socket.emit('joined-conversation', { conversationId });
  });
  
  // Handle messages
  socket.on('send-message', (data) => {
    io.to(`conversation:${data.conversationId}`).emit('new-message', {
      ...data,
      timestamp: new Date().toISOString()
    });
  });
  
  // Booking updates
  socket.on('booking-update', (data) => {
    io.to(`user:${data.userId}`).emit('booking-status-changed', data);
  });
  
  socket.on('disconnect', () => {
    console.log(`Disconnected: ${socket.id}`);
  });
});

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  const status = err.status || 500;
  res.status(status).json({
    success: false,
    error: {
      status,
      message: err.message || 'Internal Server Error',
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    }
  });
});

const PORT = process.env.PORT || 3000;

httpServer.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║        🚀 Wide Angu Media Professionals API Started 🚀        ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  🌍 Environment: ${(process.env.NODE_ENV || 'development').padEnd(45)}║
║  🔗 Server: http://localhost:${PORT}${' '.repeat(34 - PORT.toString().length)}║
║  📚 API: http://localhost:${PORT}/api/v1${' '.repeat(27 - PORT.toString().length)}║
║  💙 Health: http://localhost:${PORT}/health${' '.repeat(25 - PORT.toString().length)}║
║                                                                ║
║  Available Professional Categories:                           ║
║  📸 Photography  🎥 Videography  ✂️ Editing                    ║
║  💡 Lighting     🎙️ Audio        🎪 Events                     ║
║  🚁 Aerial       🏢 Studio Services                            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
  `);
});

export default app;
SERVER
    
    # Create environment file
    cat > .env << 'ENV'
# Server Configuration
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database
DATABASE_URL=postgresql://wideangu:wideangu123@localhost:5432/wideangu_db

# Redis
REDIS_URL=redis://localhost:6379

# JWT
JWT_SECRET=wide_angu_dev_jwt_secret_2024
JWT_REFRESH_SECRET=wide_angu_refresh_secret_2024

# Email
SMTP_HOST=localhost
SMTP_PORT=1025
FROM_EMAIL=noreply@wideangu.com

# Payment Gateways
STRIPE_SECRET_KEY=sk_test_your_stripe_key
PAYSTACK_SECRET_KEY=sk_test_your_paystack_key

# Media Upload
MAX_FILE_SIZE=104857600
UPLOAD_PATH=./uploads

# Client URLs
CLIENT_URL=http://localhost:3001
ADMIN_URL=http://localhost:3002
ENV
    
    cd ..
    
    # Create Docker configuration
    echo -e "${YELLOW}Creating Docker configuration...${NC}"
    cat > docker-compose.yml << 'DOCKER'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: wideangu_postgres
    environment:
      POSTGRES_USER: wideangu
      POSTGRES_PASSWORD: wideangu123
      POSTGRES_DB: wideangu_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    container_name: wideangu_redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  mailhog:
    image: mailhog/mailhog
    container_name: wideangu_mail
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI

volumes:
  postgres_data:
  redis_data:
DOCKER
    
    # Create comprehensive README
    cat > README.md << 'README'
# 🚀 Wide Angu - Media Professionals Marketplace

<div align="center">
  <h3>Connecting Clients with Media Professionals</h3>
  <p>Photographers • Videographers • Editors • Lighting Pros • Event Specialists • Audio Engineers • Drone Operators</p>
</div>

## 📋 About Wide Angu

Wide Angu is a comprehensive two-sided marketplace platform that connects clients with a diverse range of media professionals. Whether you need a photographer for your wedding, a videographer for your corporate event, an editor for post-production, or a complete media team for a large production, Wide Angu makes it easy to find, book, and collaborate with the right professionals.

## 🎯 Professional Categories

- **📸 Photography** - Wedding, Portrait, Event, Product, Fashion, Real Estate
- **🎥 Videography** - Corporate, Documentary, Music Videos, Commercials
- **✂️ Editing Services** - Video Editing, Photo Editing, Color Grading, Motion Graphics
- **💡 Lighting Professionals** - Stage, Studio, Event, Film Lighting
- **🎙️ Audio/Sound Engineers** - Recording, Live Sound, Mixing, Sound Design
- **🎪 Event Specialists** - Planning, Coverage, Live Streaming, Coordination
- **🚁 Aerial/Drone Operators** - Aerial Photography, Videography, Mapping
- **🏢 Studio Services** - Studio Rental, Equipment Rental, Set Design

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- PostgreSQL (or use Docker)
- Redis (or use Docker)

### Setup

```bash
# 1. Install dependencies
cd backend
npm install

# 2. Start services with Docker (optional)
docker-compose up -d

# 3. Run the development server
npm run dev
```

Your API is now running at: **http://localhost:3000**

### Test the API

```bash
# Health check
curl http://localhost:3000/health

# Get all professional categories
curl http://localhost:3000/api/v1/discover/categories

# Browse professionals
curl http://localhost:3000/api/v1/discover/professionals

# Filter by category
curl "http://localhost:3000/api/v1/discover/professionals?category=videography"
```

## 📚 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/v1/discover/professionals` | Browse all professionals |
| GET | `/api/v1/discover/categories` | Get all service categories |
| POST | `/api/v1/discover/instant-capture` | Quick booking request |
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | User login |
| GET | `/api/v1/bookings` | Get user bookings |
| POST | `/api/v1/bookings` | Create new booking |

## 🏗️ Project Structure

```
wide-angu/
├── backend/
│   ├── src/
│   │   ├── controllers/    # Request handlers
│   │   ├── models/        # Database models
│   │   ├── routes/        # API routes
│   │   ├── services/      # Business logic
│   │   └── server.ts      # Main application
│   └── package.json
├── mobile/                # React Native app (optional)
├── docker-compose.yml     # Database services
└── README.md
```

## 🛠️ Technology Stack

- **Backend**: Node.js, Express, TypeScript
- **Database**: PostgreSQL
- **Cache**: Redis
- **Real-time**: Socket.io
- **Authentication**: JWT
- **Payments**: Stripe & Paystack
- **File Storage**: Local/S3

## 🔐 Features

### For Clients
- Browse media professionals by category
- Filter by location, price, availability
- Instant booking requests
- Real-time messaging
- Secure payments
- Review and rating system

### For Professionals
- Create comprehensive profiles
- Showcase portfolio
- Manage bookings
- Set availability
- Track earnings
- Receive instant notifications

## 📱 WebSocket Events

The platform supports real-time features via Socket.io:

- `join-conversation` - Join a chat room
- `send-message` - Send real-time messages
- `booking-update` - Receive booking status updates
- `new-notification` - Get instant notifications

## 🚀 Deployment

### Railway
```bash
railway login
railway up
```

### Docker
```bash
docker build -t wideangu-api .
docker run -p 3000:3000 wideangu-api
```

## 📧 Support

For questions or support, contact: support@wideangu.com

## 📄 License

MIT License - see LICENSE file

---

**Wide Angu** - Empowering Media Professionals, Connecting Creative Talent
README
    
    # Create basic mobile structure
    mkdir -p mobile
    cat > mobile/README.md << 'MOBILE'
# Wide Angu Mobile App

## Setup React Native App

```bash
npx react-native init WideAnguApp --template react-native-template-typescript
cd WideAnguApp
npm install @reduxjs/toolkit react-redux @react-navigation/native
npm install axios socket.io-client
```

## Features
- Browse media professionals
- Book services
- Real-time chat
- Payment processing
- Push notifications

## Professional Types Supported
- Photographers
- Videographers
- Video/Photo Editors
- Lighting Professionals
- Sound Engineers
- Event Specialists
- Drone Operators
- Studio Managers
MOBILE
    
    # Create VS Code settings
    mkdir -p .vscode
    cat > .vscode/settings.json << 'VSCODE'
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "backend/node_modules/typescript/lib"
}
VSCODE
    
    # Initialize git
    git init
    
    # Create .gitignore
    cat > .gitignore << 'GITIGNORE'
node_modules/
dist/
.env
.env.local
*.log
.DS_Store
coverage/
uploads/
*.swp
GITIGNORE
    
    git add .
    git commit -m "Initial commit: Wide Angu Media Professionals Marketplace" &> /dev/null
    
    # Success message
    echo -e "\n${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✨ Wide Angu Media Professionals Marketplace Created! ✨${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${WHITE}📁 Project location:${NC} $(pwd)"
    echo -e "${WHITE}📚 Available at:${NC} http://localhost:3000\n"
    
    echo -e "${CYAN}Supported Professional Types:${NC}"
    echo -e "  📸 Photographers"
    echo -e "  🎥 Videographers" 
    echo -e "  ✂️ Video/Photo Editors"
    echo -e "  💡 Lighting Professionals"
    echo -e "  🎙️ Sound Engineers"
    echo -e "  🎪 Event Specialists"
    echo -e "  🚁 Drone Operators"
    echo -e "  🏢 Studio Services\n"
    
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Start database services:"
    echo -e "   ${CYAN}docker-compose up -d${NC}\n"
    echo -e "2. Start the backend:"
    echo -e "   ${CYAN}cd backend && npm run dev${NC}\n"
    echo -e "3. Test the API:"
    echo -e "   ${CYAN}curl http://localhost:3000/api/v1/discover/categories${NC}\n"
    
    echo -e "${GREEN}Happy coding! 🎉${NC}"
}

# Run main function
main "$@"
