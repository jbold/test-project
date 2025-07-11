// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod auth;

use auth::{AuthManager, login_user, validate_token, logout_user, check_auth_status, refresh_user_profile};

#[tokio::main]
async fn main() {
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
