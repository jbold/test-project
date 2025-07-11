import pytest
from fastapi.testclient import TestClient

def test_health_check(client: TestClient):
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_register_user_success(client: TestClient, test_user_data):
    """Test successful user registration"""
    response = client.post("/auth/register", json=test_user_data)
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user_data["email"]
    assert data["full_name"] == test_user_data["full_name"]
    assert data["is_active"] is True
    assert "id" in data

def test_register_user_weak_password(client: TestClient, test_user_weak_password):
    """Test registration with weak password fails"""
    response = client.post("/auth/register", json=test_user_weak_password)
    assert response.status_code == 422
    error_detail = response.json()["detail"][0]
    assert "Password must be at least 12 characters long" in error_detail["msg"]

def test_register_duplicate_email(client: TestClient, test_user_data):
    """Test registration with duplicate email fails"""
    # Register user first time
    response = client.post("/auth/register", json=test_user_data)
    assert response.status_code == 200
    
    # Try to register same email again
    response = client.post("/auth/register", json=test_user_data)
    assert response.status_code == 400
    assert "Email already registered" in response.json()["detail"]

def test_login_success(client: TestClient, test_user_data):
    """Test successful login"""
    # Register user first
    client.post("/auth/register", json=test_user_data)
    
    # Login
    login_data = {
        "email": test_user_data["email"],
        "password": test_user_data["password"]
    }
    response = client.post("/auth/login", json=login_data)
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"

def test_login_invalid_credentials(client: TestClient, test_user_data):
    """Test login with invalid credentials fails"""
    # Register user first
    client.post("/auth/register", json=test_user_data)
    
    # Try login with wrong password
    login_data = {
        "email": test_user_data["email"],
        "password": "WrongPassword123!"
    }
    response = client.post("/auth/login", json=login_data)
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

def test_login_nonexistent_user(client: TestClient):
    """Test login with non-existent user fails"""
    login_data = {
        "email": "nonexistent@example.com",
        "password": "TestPassword123!"
    }
    response = client.post("/auth/login", json=login_data)
    assert response.status_code == 401
    assert "Incorrect email or password" in response.json()["detail"]

def test_get_user_profile_without_token(client: TestClient):
    """Test accessing user profile without token fails"""
    response = client.get("/user/profile")
    assert response.status_code == 403

def test_get_user_profile_with_token(client: TestClient, test_user_data):
    """Test accessing user profile with valid token"""
    # Register and login
    client.post("/auth/register", json=test_user_data)
    login_response = client.post("/auth/login", json={
        "email": test_user_data["email"],
        "password": test_user_data["password"]
    })
    token = login_response.json()["access_token"]
    
    # Get profile
    headers = {"Authorization": f"Bearer {token}"}
    response = client.get("/user/profile", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == test_user_data["email"]
    assert data["full_name"] == test_user_data["full_name"]