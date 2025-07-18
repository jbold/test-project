from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional
import stripe
import os
import logging
from dotenv import load_dotenv
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from database import SessionLocal, engine, init_db
from models import User, UserSubscription
from schemas import UserCreate, UserLogin, UserResponse, TokenResponse, CheckoutRequest
from auth import (
    create_access_token, 
    verify_password, 
    get_password_hash,
    decode_access_token
)

load_dotenv()

# Initialize database
init_db()

app = FastAPI(title="Legal Toolkit Web Portal", version="1.0.0")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Rate limiting setup
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Configure CORS - Restricted for security
allowed_origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:3001,http://localhost:5173").split(",")
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Accept", "Origin", "X-Requested-With"],
)

# Stripe configuration
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")
STRIPE_WEBHOOK_SECRET = os.getenv("STRIPE_WEBHOOK_SECRET")

# Security
security = HTTPBearer()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security), db: Session = Depends(get_db)):
    """Get current user from JWT token"""
    token = credentials.credentials
    payload = decode_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user

@app.post("/auth/register", response_model=UserResponse)
@limiter.limit("3/minute")  # 3 registration attempts per minute
async def register(request: Request, user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    logger.info(f"Registration attempt for email: {user.email}")
    
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        logger.warning(f"Registration failed - email already exists: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        hashed_password=hashed_password,
        full_name=user.full_name,
        is_active=True
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    logger.info(f"User registered successfully: {user.email} (ID: {db_user.id})")
    
    return UserResponse(
        id=db_user.id,
        email=db_user.email,
        full_name=db_user.full_name,
        is_active=db_user.is_active,
        created_at=db_user.created_at
    )

@app.post("/auth/login", response_model=TokenResponse)
@limiter.limit("5/minute")  # 5 login attempts per minute
async def login(request: Request, user: UserLogin, db: Session = Depends(get_db)):
    """Login user and return JWT token"""
    logger.info(f"Login attempt for email: {user.email}")
    
    db_user = db.query(User).filter(User.email == user.email).first()
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        logger.warning(f"Failed login attempt for email: {user.email}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not db_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    
    access_token = create_access_token(data={"sub": str(db_user.id)})
    logger.info(f"Successful login for email: {user.email} (ID: {db_user.id})")
    return TokenResponse(access_token=access_token, token_type="bearer")

@app.post("/payment/create-checkout")
async def create_checkout_session(
    request: CheckoutRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create Stripe checkout session"""
    try:
        # Define price mapping
        prices = {
            "one_time": {
                "price": 2900,  # $29.00 in cents
                "mode": "payment"
            },
            "monthly": {
                "price": 900,   # $9.00 in cents
                "mode": "subscription"
            }
        }
        
        if request.plan_type not in prices:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid plan type"
            )
        
        plan = prices[request.plan_type]
        
        # Create Stripe checkout session
        checkout_session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': 'usd',
                    'product_data': {
                        'name': f'Legal Toolkit - {request.plan_type.replace("_", " ").title()} Plan',
                    },
                    'unit_amount': plan["price"],
                    'recurring': {'interval': 'month'} if request.plan_type == "monthly" else None
                },
                'quantity': 1,
            }],
            mode=plan["mode"],
            success_url=request.success_url,
            cancel_url=request.cancel_url,
            metadata={
                'user_id': str(current_user.id),
                'plan_type': request.plan_type
            }
        )
        
        return {"checkout_url": checkout_session.url}
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create checkout session: {str(e)}"
        )

@app.get("/download/app")
async def download_app(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Download app with auth token (requires active subscription)"""
    # Check if user has active subscription
    subscription = db.query(UserSubscription).filter(
        UserSubscription.user_id == current_user.id,
        UserSubscription.is_active == True
    ).first()
    
    # Check if we're in Stripe test mode (using test keys)
    stripe_secret_key = os.getenv("STRIPE_SECRET_KEY", "")
    is_stripe_test_mode = stripe_secret_key.startswith("sk_test_")
    
    if not subscription:
        if is_stripe_test_mode:
            logger.info(f"Stripe test mode: Creating test subscription for user {current_user.id}")
            # In test mode, create a test subscription for development workflow
            subscription = UserSubscription(
                user_id=current_user.id,
                plan_type="test_subscription",
                is_active=True,
                stripe_subscription_id="test_sub_" + str(current_user.id),
                created_at=datetime.utcnow()
            )
            db.add(subscription)
            db.commit()
        else:
            # Production mode: Strict subscription check
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Active subscription required to download app"
            )
    
    # Generate download token valid for 1 hour
    download_token = create_access_token(
        data={"sub": str(current_user.id), "type": "download"},
        expires_delta=timedelta(hours=1)
    )
    
    return {
        "download_token": download_token,
        "download_url": f"/download/app/file?token={download_token}",
        "expires_at": datetime.utcnow() + timedelta(hours=1)
    }

@app.get("/user/profile", response_model=UserResponse)
async def get_user_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Get current user profile"""
    # Get subscription info
    subscription = db.query(UserSubscription).filter(
        UserSubscription.user_id == current_user.id,
        UserSubscription.is_active == True
    ).first()
    
    response = UserResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        is_active=current_user.is_active,
        created_at=current_user.created_at
    )
    
    if subscription:
        response.subscription = {
            "plan_type": subscription.plan_type,
            "status": subscription.status,
            "created_at": subscription.created_at
        }
    
    return response

@app.post("/webhook/stripe")
@limiter.limit("100/minute")  # High limit for legitimate webhook traffic
async def stripe_webhook(request: Request, db: Session = Depends(get_db)):
    """Handle Stripe webhooks"""
    payload = await request.body()
    sig_header = request.headers.get('stripe-signature')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, STRIPE_WEBHOOK_SECRET
        )
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid payload")
    except stripe.error.SignatureVerificationError:
        raise HTTPException(status_code=400, detail="Invalid signature")
    
    # Handle the event
    if event['type'] == 'checkout.session.completed':
        session = event['data']['object']
        user_id = session['metadata']['user_id']
        plan_type = session['metadata']['plan_type']
        
        # Create or update subscription
        subscription = UserSubscription(
            user_id=user_id,
            plan_type=plan_type,
            stripe_customer_id=session.get('customer'),
            stripe_subscription_id=session.get('subscription'),
            status='active',
            is_active=True
        )
        db.add(subscription)
        db.commit()
    
    return {"status": "success"}

# Health check endpoint for production
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)