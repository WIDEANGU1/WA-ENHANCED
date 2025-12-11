# Wide Angu - Media Professionals Marketplace Setup (Windows)
# Run in VSCode PowerShell terminal

Write-Host "🚀 Wide Angu - Media Professionals Marketplace Setup" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Connecting clients with photographers, videographers," -ForegroundColor Yellow
Write-Host "editors, lighting pros, event specialists, and more!" -ForegroundColor Yellow
Write-Host ""

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js installed: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found. Please install from nodejs.org" -ForegroundColor Red
    exit 1
}

# Create project
Write-Host "Creating Wide Angu project..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "wide-angu" | Out-Null
Set-Location "wide-angu"

# Backend setup
Write-Host "Setting up backend API..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "backend\src" | Out-Null
Set-Location "backend"

# Create package.json
@'
{
  "name": "wide-angu-api",
  "version": "1.0.0",
  "description": "Wide Angu - Media Professionals Marketplace API",
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js"
  }
}
'@ | Out-File -FilePath "package.json" -Encoding UTF8

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm init -y | Out-Null
npm install express cors dotenv jsonwebtoken bcryptjs socket.io multer pg sequelize redis stripe
npm install -D typescript tsx @types/node @types/express nodemon

# Create TypeScript config
@'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
'@ | Out-File -FilePath "tsconfig.json" -Encoding UTF8

# Create server.ts with all media professional types
@'
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

// Wide Angu Professional Types
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
  STUDIO_MANAGER: 'studio_manager'
};

// Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'Wide Angu Media Professionals API',
    message: 'Supporting all media professional types'
  });
});

app.get('/api/v1/discover/professionals', (req, res) => {
  res.json({
    success: true,
    data: {
      professionals: [
        { id: 1, name: 'Creative Studios', type: 'photographer', rating: 4.8 },
        { id: 2, name: 'ProVideo Team', type: 'videographer', rating: 4.9 },
        { id: 3, name: 'EditPro Services', type: 'video_editor', rating: 4.7 },
        { id: 4, name: 'LightWorks', type: 'lighting_professional', rating: 4.9 },
        { id: 5, name: 'SoundCraft', type: 'sound_engineer', rating: 4.6 },
        { id: 6, name: 'EventMasters', type: 'event_specialist', rating: 4.8 },
        { id: 7, name: 'SkyView', type: 'drone_operator', rating: 4.7 }
      ]
    }
  });
});

const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`Wide Angu API running at http://localhost:${PORT}`);
  console.log(`Supporting: Photographers, Videographers, Editors, Lighting Pros, and more!`);
});
'@ | Out-File -FilePath "src\server.ts" -Encoding UTF8

# Create .env file
@'
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://localhost/wideangu
JWT_SECRET=dev_secret_key
'@ | Out-File -FilePath ".env" -Encoding UTF8

Set-Location ..

# Create docker-compose.yml
@'
version: "3.8"
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: wideangu
      POSTGRES_USER: wideangu
      POSTGRES_PASSWORD: wideangu123
    ports:
      - "5432:5432"
  redis:
    image: redis:7
    ports:
      - "6379:6379"
'@ | Out-File -FilePath "docker-compose.yml" -Encoding UTF8

# Create README
@'
# Wide Angu - Media Professionals Marketplace

## About
Connecting clients with ALL types of media professionals:
- Photographers & Videographers
- Video & Photo Editors
- Lighting & Sound Professionals
- Event Specialists & Drone Operators
- Content Creators & Studio Services

## Quick Start
```
cd backend
npm run dev
```

Access at: http://localhost:3000
'@ | Out-File -FilePath "README.md" -Encoding UTF8

Write-Host ""
Write-Host "✅ Wide Angu project created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Project location: $(Get-Location)" -ForegroundColor White
Write-Host ""
Write-Host "🚀 To start:" -ForegroundColor Yellow
Write-Host "   cd backend" -ForegroundColor Cyan
Write-Host "   npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 API: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Happy coding! 🎉" -ForegroundColor Green
