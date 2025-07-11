use chrono::{DateTime, Utc};
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use tauri::State;

// API Base URL - in production this would be configurable
const API_BASE_URL: &str = "http://localhost:8000";

#[derive(Debug, Serialize, Deserialize)]
pub struct AuthResult {
    pub success: bool,
    pub user_id: Option<String>,
    pub message: String,
    pub token: Option<String>,
    pub user_profile: Option<UserProfile>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserCredentials {
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserProfile {
    pub id: i32,
    pub email: String,
    pub full_name: String,
    pub is_active: bool,
    pub created_at: DateTime<Utc>,
    pub subscription: Option<SubscriptionInfo>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SubscriptionInfo {
    pub plan_type: String,
    pub status: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct TokenResponse {
    pub access_token: String,
    pub token_type: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct JwtClaims {
    pub sub: String,
    pub exp: usize,
    pub iat: usize,
}

pub struct AuthManager {
    client: Client,
}

impl AuthManager {
    pub fn new() -> Result<Self, String> {
        Ok(Self {
            client: Client::new(),
        })
    }
    
    fn get_token_file_path(&self) -> Result<PathBuf, String> {
        let mut token_file_path = dirs::data_local_dir()
            .ok_or("Failed to get local data directory")?;
        token_file_path.push("legal-toolkit");
        
        // Create directory if it doesn't exist
        if !token_file_path.exists() {
            fs::create_dir_all(&token_file_path)
                .map_err(|e| format!("Failed to create data directory: {}", e))?;
        }
        
        token_file_path.push("auth_token.json");
        Ok(token_file_path)
    }

    pub async fn login(&self, email: &str, password: &str) -> Result<AuthResult, String> {
        let mut login_data = HashMap::new();
        login_data.insert("email", email);
        login_data.insert("password", password);

        let response = self
            .client
            .post(&format!("{}/auth/login", API_BASE_URL))
            .json(&login_data)
            .send()
            .await
            .map_err(|e| format!("Network error: {}", e))?;

        if response.status().is_success() {
            let token_response: TokenResponse = response
                .json()
                .await
                .map_err(|e| format!("Failed to parse login response: {}", e))?;

            // Store token securely
            self.save_token(&token_response.access_token)?;

            // Get user profile
            let profile = self.get_user_profile(&token_response.access_token).await?;

            Ok(AuthResult {
                success: true,
                user_id: Some(profile.id.to_string()),
                message: "Login successful".to_string(),
                token: Some(token_response.access_token),
                user_profile: Some(profile),
            })
        } else {
            let error_text = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());
            
            Ok(AuthResult {
                success: false,
                user_id: None,
                message: format!("Login failed: {}", error_text),
                token: None,
                user_profile: None,
            })
        }
    }

    pub async fn get_user_profile(&self, token: &str) -> Result<UserProfile, String> {
        let response = self
            .client
            .get(&format!("{}/user/profile", API_BASE_URL))
            .header("Authorization", format!("Bearer {}", token))
            .send()
            .await
            .map_err(|e| format!("Network error: {}", e))?;

        if response.status().is_success() {
            let profile: UserProfile = response
                .json()
                .await
                .map_err(|e| format!("Failed to parse profile response: {}", e))?;
            Ok(profile)
        } else {
            Err("Failed to get user profile".to_string())
        }
    }

    pub async fn validate_stored_token(&self) -> Result<AuthResult, String> {
        let token = self.load_token()?;
        
        if let Some(token) = token {
            // Validate token with server
            let profile_result = self.get_user_profile(&token).await;
            
            match profile_result {
                Ok(profile) => {
                    Ok(AuthResult {
                        success: true,
                        user_id: Some(profile.id.to_string()),
                        message: "Token valid".to_string(),
                        token: Some(token),
                        user_profile: Some(profile),
                    })
                }
                Err(_) => {
                    // Token is invalid, remove it
                    self.clear_token()?;
                    Ok(AuthResult {
                        success: false,
                        user_id: None,
                        message: "Token expired or invalid".to_string(),
                        token: None,
                        user_profile: None,
                    })
                }
            }
        } else {
            Ok(AuthResult {
                success: false,
                user_id: None,
                message: "No stored token found".to_string(),
                token: None,
                user_profile: None,
            })
        }
    }

    pub fn save_token(&self, token: &str) -> Result<(), String> {
        let token_file_path = self.get_token_file_path()?;
        let token_data = serde_json::json!({
            "access_token": token,
            "stored_at": Utc::now()
        });
        
        fs::write(&token_file_path, token_data.to_string())
            .map_err(|e| format!("Failed to save token: {}", e))?;
        
        Ok(())
    }

    pub fn load_token(&self) -> Result<Option<String>, String> {
        let token_file_path = self.get_token_file_path()?;
        if !token_file_path.exists() {
            return Ok(None);
        }
        
        let token_data = fs::read_to_string(&token_file_path)
            .map_err(|e| format!("Failed to read token file: {}", e))?;
        
        let token_json: serde_json::Value = serde_json::from_str(&token_data)
            .map_err(|e| format!("Failed to parse token file: {}", e))?;
        
        if let Some(token) = token_json.get("access_token").and_then(|v| v.as_str()) {
            Ok(Some(token.to_string()))
        } else {
            Ok(None)
        }
    }

    pub fn clear_token(&self) -> Result<(), String> {
        let token_file_path = self.get_token_file_path()?;
        if token_file_path.exists() {
            fs::remove_file(&token_file_path)
                .map_err(|e| format!("Failed to remove token file: {}", e))?;
        }
        Ok(())
    }

    pub fn has_stored_token(&self) -> bool {
        self.get_token_file_path().map_or(false, |path| path.exists())
    }
}

// Tauri commands
#[tauri::command]
pub async fn login_user(
    auth_manager: State<'_, AuthManager>,
    credentials: UserCredentials,
) -> Result<AuthResult, String> {
    match auth_manager.login(&credentials.email, &credentials.password).await {
        Ok(result) => Ok(result),
        Err(e) => Ok(AuthResult {
            success: false,
            user_id: None,
            message: format!("Login error: {}", e),
            token: None,
            user_profile: None,
        }),
    }
}

#[tauri::command]
pub async fn validate_token(
    auth_manager: State<'_, AuthManager>,
) -> Result<AuthResult, String> {
    match auth_manager.validate_stored_token().await {
        Ok(result) => Ok(result),
        Err(e) => Ok(AuthResult {
            success: false,
            user_id: None,
            message: format!("Token validation error: {}", e),
            token: None,
            user_profile: None,
        }),
    }
}

#[tauri::command]
pub async fn logout_user(
    auth_manager: State<'_, AuthManager>,
) -> Result<AuthResult, String> {
    match auth_manager.clear_token() {
        Ok(_) => Ok(AuthResult {
            success: true,
            user_id: None,
            message: "Logout successful".to_string(),
            token: None,
            user_profile: None,
        }),
        Err(e) => Ok(AuthResult {
            success: false,
            user_id: None,
            message: format!("Logout error: {}", e),
            token: None,
            user_profile: None,
        }),
    }
}

#[tauri::command]
pub async fn check_auth_status(
    auth_manager: State<'_, AuthManager>,
) -> Result<bool, String> {
    Ok(auth_manager.has_stored_token())
}

#[tauri::command]
pub async fn refresh_user_profile(
    auth_manager: State<'_, AuthManager>,
) -> Result<AuthResult, String> {
    if let Some(token) = auth_manager.load_token()? {
        match auth_manager.get_user_profile(&token).await {
            Ok(profile) => Ok(AuthResult {
                success: true,
                user_id: Some(profile.id.to_string()),
                message: "Profile refreshed".to_string(),
                token: Some(token),
                user_profile: Some(profile),
            }),
            Err(e) => Ok(AuthResult {
                success: false,
                user_id: None,
                message: format!("Profile refresh error: {}", e),
                token: None,
                user_profile: None,
            }),
        }
    } else {
        Ok(AuthResult {
            success: false,
            user_id: None,
            message: "No token found".to_string(),
            token: None,
            user_profile: None,
        })
    }
}