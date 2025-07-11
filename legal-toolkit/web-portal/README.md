# Legal Toolkit Web Portal

A complete web portal for user registration, payment processing, and desktop app distribution.

## Features

- **FastAPI Backend** with PostgreSQL database
- **SvelteKit Frontend** with modern UI
- **Stripe Payment Integration** (one-time $29 or monthly $9 subscription)
- **JWT Authentication** for secure API access
- **Desktop App Distribution** with auth token validation

## Quick Start

1. **Clone and setup**:
   ```bash
   cd legal-toolkit/web-portal
   ```

2. **Configure environment**:
   ```bash
   cp backend/.env.example backend/.env
   # Edit backend/.env with your database and Stripe keys
   ```

3. **Start services**:
   ```bash
   ./start.sh
   ```

4. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

## Environment Variables

### Required Environment Variables (backend/.env):

```env
# Database
DATABASE_URL=postgresql://legaluser:legalpass123@postgres:5432/legal_toolkit

# JWT Secret
SECRET_KEY=your-secret-key-change-in-production

# Stripe Configuration
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user

### Payments
- `POST /payment/create-checkout` - Create Stripe checkout session
- `POST /webhook/stripe` - Handle Stripe webhooks

### User Management
- `GET /user/profile` - Get user profile (requires auth)
- `GET /download/app` - Get download link (requires active subscription)

## Project Structure

```
web-portal/
├── backend/
│   ├── main.py           # FastAPI application
│   ├── models.py         # Database models
│   ├── schemas.py        # Pydantic schemas
│   ├── auth.py           # Authentication utilities
│   ├── database.py       # Database configuration
│   └── requirements.txt  # Python dependencies
├── frontend/
│   ├── src/
│   │   ├── routes/       # SvelteKit pages
│   │   └── lib/          # Utility functions
│   └── package.json      # Node.js dependencies
├── docker-compose.yml    # Docker services
└── start.sh             # Startup script
```

## Development

### Backend Development
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### Frontend Development
```bash
cd frontend
npm install
npm run dev
```

## Production Deployment

1. **Update environment variables** for production
2. **Configure SSL/TLS** for HTTPS
3. **Set up Stripe webhooks** for payment processing
4. **Configure database backups**
5. **Set up monitoring and logging**

## Security Considerations

- Change default JWT secret key
- Use environment variables for sensitive data
- Configure CORS for production domains
- Implement rate limiting
- Set up proper database permissions
- Use HTTPS in production

## Desktop App Integration

The desktop app (Tauri) will authenticate with this web portal by:

1. **User login** through the web portal
2. **Payment processing** via Stripe
3. **Token generation** for desktop app access
4. **Download authentication** using JWT tokens

The desktop app can then use the API endpoints to verify user subscription status and access protected features.