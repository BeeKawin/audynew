# AUDY Backend - Railway Deployment Guide

## Overview
This FastAPI backend provides:
- Thai Chat API (`/api/thai-chat`) - Powered by Google Gemini
- Emotion Classification API (`/api/emotion/classify`) - Powered by ONNX Runtime
- Health checks and monitoring

## Prerequisites

1. **Railway Account** - Sign up at https://railway.app (free tier available)
2. **GitHub Account** - For deploying from repository
3. **Google Gemini API Key** - Get from https://aistudio.google.com/app/apikey
4. **ONNX Model File** - `models/model.onnx` (converted from TFLite)

## Local Development

### Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Convert TFLite to ONNX (One-time)
```bash
# Install conversion dependencies
pip install tensorflow tf2onnx

# Run conversion script
python scripts/convert_model.py

# This creates: backend/models/model.onnx
```

### Run Locally
```bash
# Copy environment variables
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

# Start server
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Test endpoints:
- http://localhost:8000/api/health
- http://localhost:8000/api/emotion/health

## Railway Deployment Steps

### 1. Prepare Repository

Ensure your `backend/` folder contains:
```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── models/
│   ├── routers/
│   └── services/
├── models/
│   └── model.onnx          # ← Converted ONNX model (required!)
├── Dockerfile              # ← Railway deployment config
├── requirements.txt
└── .env.example
```

### 2. Push to GitHub

```bash
# From your project root
git add backend/
git commit -m "Add FastAPI backend with emotion classification"
git push origin main
```

### 3. Create Railway Project

1. Go to https://railway.app/dashboard
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Choose your repository
5. Railway will auto-detect the Dockerfile

### 4. Configure Environment Variables

In Railway Dashboard → Your Project → Variables, add:

```
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-2.5-flash-lite
MAX_CONTEXT_MESSAGES=10
SESSION_TIMEOUT_MINUTES=30
PORT=8000
```

**Important:** Get your Gemini API key from https://aistudio.google.com/app/apikey

### 5. Add ONNX Model

Railway deployment requires the model file. You have two options:

**Option A: Include in Git (Simple)**
```bash
# Make sure model.onnx is tracked
git add backend/models/model.onnx
git commit -m "Add ONNX emotion model"
git push
```

**Option B: Railway Volume (Better for large files)**
1. Railway Dashboard → Your Service → Volumes
2. Create a volume mounted at `/app/models/`
3. Upload model.onnx via Railway CLI or dashboard

### 6. Deploy

Railway will automatically deploy on git push. Monitor logs in the dashboard.

Once deployed, you'll get a URL like:
```
https://audy-api.up.railway.app
```

### 7. Test Deployment

```bash
curl https://your-app.up.railway.app/api/health
curl https://your-app.up.railway.app/api/emotion/health
```

## Update Flutter App

### 1. Update Railway URL

Edit `audy_app/lib/src/features/social_chat/chat_service.dart`:

```dart
class ApiConfig {
  // Replace with your Railway URL
  static const String railwayUrl = 'https://your-app.up.railway.app';
  // ...
}
```

### 2. Build and Test

```bash
cd audy_app
flutter build apk --release
# Or for web: flutter build web
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API info |
| `/api/health` | GET | Overall health check |
| `/api/thai-chat` | POST | Thai chat with Gemini |
| `/api/emotion/classify` | POST | Emotion detection from image |
| `/api/emotion/health` | GET | Emotion service health |

### Example API Calls

**Thai Chat:**
```bash
curl -X POST https://your-app.up.railway.app/api/thai-chat \
  -H "Content-Type: application/json" \
  -d '{"message": "สวัสดี"}'
```

**Emotion Classification:**
```bash
curl -X POST https://your-app.up.railway.app/api/emotion/classify \
  -F "image=@photo.jpg"
```

## Troubleshooting

### "Model not loaded" Error
- Ensure `models/model.onnx` exists in the repository
- Check Railway logs for file path issues
- Verify the Dockerfile copies the models folder: `COPY models/ ./models/`

### "Service unavailable" (503)
- Check that `GEMINI_API_KEY` is set in Railway variables
- Verify the emotion model loaded successfully in logs

### High Cold Start Times
- Railway free tier sleeps after inactivity
- First request may take 5-10 seconds
- Consider Railway's "Always On" feature (paid) for production

### CORS Errors in Flutter
- Update `main.py` CORS origins with your actual app domains
- For testing: `allow_origins=["*"]` (not recommended for production)

## Free Tier Limits

Railway free tier ($5 credit/month):
- ✅ 512 MB RAM, 1 vCPU
- ✅ Unlimited requests while running
- ⚠️ App sleeps after 5 minutes inactivity (cold start ~5-10s)
- ⚠️ $5 limit per month (usually sufficient for development)

For production with always-on:
- Hobby plan: $5/month fixed
- Pro plan: Usage-based

## Monitoring

Railway Dashboard provides:
- Real-time logs
- Metrics (CPU, memory, requests)
- Deployment history
- Custom domains (on paid plans)

## Security Checklist

- [ ] Never commit `.env` with real API keys
- [ ] Restrict CORS origins in production
- [ ] Enable Railway's "Private Networking" if needed
- [ ] Set up rate limiting for production use
- [ ] Monitor logs for abuse

## Next Steps

1. ✅ Backend deployed to Railway
2. ✅ Flutter app updated with Railway URL
3. ✅ Test all features (chat, emotion detection)
4. 🔄 Optional: Set up custom domain
5. 🔄 Optional: Add monitoring/alerts
6. 🔄 Optional: Implement rate limiting

---

**Questions?** Check Railway docs: https://docs.railway.app/
