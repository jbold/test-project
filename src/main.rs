// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod auth;

use auth::{
    check_auth_status, login_user, logout_user, refresh_user_profile, validate_token, AuthManager,
};

#[tokio::main]
async fn main() {
    // Load environment variables from .env file
    dotenv::dotenv().ok();

    let auth_manager = AuthManager::new().expect("Failed to initialize auth manager");

    tauri::Builder::default()
        .manage(auth_manager)
        .invoke_handler(tauri::generate_handler![
            login_user,
            validate_token,
            logout_user,
            check_auth_status,
            refresh_user_profile
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
