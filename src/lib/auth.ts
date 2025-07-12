// Environment configuration
const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || "http://localhost:8000";
const WEB_PORTAL_URL =
  import.meta.env.VITE_WEB_PORTAL_URL || "http://localhost:3000";

// Check if we're running in Tauri desktop app
function isTauri(): boolean {
  return typeof window !== "undefined" && "__TAURI__" in window;
}

// Dynamic import for Tauri invoke
async function getTauriInvoke() {
  if (!isTauri()) return null;
  try {
    const { invoke } = await import("@tauri-apps/api/core");
    return invoke;
  } catch {
    return null;
  }
}

export interface AuthResult {
  success: boolean;
  user_id?: string;
  message: string;
  token?: string;
  user_profile?: UserProfile;
}

export interface UserCredentials {
  email: string;
  password: string;
}

export interface UserProfile {
  id: number;
  email: string;
  full_name: string;
  is_active: boolean;
  created_at: string;
  subscription?: SubscriptionInfo;
}

export interface SubscriptionInfo {
  plan_type: string;
  status: string;
  created_at: string;
}

export class AuthService {
  private static refreshInterval: NodeJS.Timeout | null = null;

  static async login(email: string, password: string): Promise<AuthResult> {
    try {
      const invoke = await getTauriInvoke();

      if (invoke) {
        // Desktop app - use Tauri backend
        const credentials: UserCredentials = { email, password };
        const result = await invoke<AuthResult>("login_user", { credentials });

        if (result.success) {
          this.startTokenRefresh();
        }
        return result;
      } else {
        // Browser - use web API
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password }),
        });

        if (response.ok) {
          const data = await response.json();
          // Store token in localStorage for browser
          localStorage.setItem("auth_token", data.access_token);

          // Get user profile
          const profileResponse = await fetch(`${API_BASE_URL}/user/profile`, {
            headers: { Authorization: `Bearer ${data.access_token}` },
          });

          if (profileResponse.ok) {
            const profile = await profileResponse.json();
            return {
              success: true,
              message: "Login successful",
              token: data.access_token,
              user_profile: profile,
            };
          }
        }

        return {
          success: false,
          message: "Login failed - check credentials",
        };
      }
    } catch (error) {
      console.error("Error during login:", error);
      return {
        success: false,
        message: `Login failed: ${error}`,
      };
    }
  }

  static async validateToken(): Promise<AuthResult> {
    try {
      const invoke = await getTauriInvoke();

      if (invoke) {
        // Desktop app - use Tauri backend
        const result = await invoke<AuthResult>("validate_token");

        if (result.success) {
          if (!this.refreshInterval) {
            this.startTokenRefresh();
          }
        } else {
          this.stopTokenRefresh();
        }
        return result;
      } else {
        // Browser - check localStorage token
        const token = localStorage.getItem("auth_token");
        if (!token) {
          return {
            success: false,
            message: "No token found",
          };
        }

        // Validate with web API
        const response = await fetch(`${API_BASE_URL}/user/profile`, {
          headers: { Authorization: `Bearer ${token}` },
        });

        if (response.ok) {
          const profile = await response.json();
          return {
            success: true,
            message: "Token valid",
            token,
            user_profile: profile,
          };
        } else {
          localStorage.removeItem("auth_token");
          return {
            success: false,
            message: "Token invalid",
          };
        }
      }
    } catch (error) {
      console.error("Error validating token:", error);
      this.stopTokenRefresh();
      return {
        success: false,
        message: `Token validation failed: ${error}`,
      };
    }
  }

  static async logout(): Promise<AuthResult> {
    try {
      this.stopTokenRefresh();
      const invoke = await getTauriInvoke();

      if (invoke) {
        // Desktop app - use Tauri backend
        return await invoke<AuthResult>("logout_user");
      } else {
        // Browser - just clear localStorage
        localStorage.removeItem("auth_token");
        return {
          success: true,
          message: "Logged out successfully",
        };
      }
    } catch (error) {
      console.error("Error during logout:", error);
      return {
        success: false,
        message: `Logout failed: ${error}`,
      };
    }
  }

  static async checkAuthStatus(): Promise<boolean> {
    try {
      const invoke = await getTauriInvoke();

      if (invoke) {
        // Desktop app - use Tauri backend
        return await invoke<boolean>("check_auth_status");
      } else {
        // Browser - check localStorage
        return localStorage.getItem("auth_token") !== null;
      }
    } catch (error) {
      console.error("Error checking auth status:", error);
      return false;
    }
  }

  static async refreshUserProfile(): Promise<AuthResult> {
    try {
      const invoke = await getTauriInvoke();

      if (invoke) {
        // Desktop app - use Tauri backend
        return await invoke<AuthResult>("refresh_user_profile");
      } else {
        // Browser fallback - validate current token
        return await this.validateToken();
      }
    } catch (error) {
      console.error("Error refreshing user profile:", error);
      return {
        success: false,
        message: `Profile refresh failed: ${error}`,
      };
    }
  }

  private static startTokenRefresh(): void {
    // Clear existing interval if any
    this.stopTokenRefresh();

    // Refresh every 20 minutes (tokens expire after 30 minutes)
    this.refreshInterval = setInterval(
      async () => {
        try {
          const result = await this.validateToken();
          if (!result.success) {
            console.log("Token refresh failed, stopping refresh interval");
            this.stopTokenRefresh();
            // Emit event to notify app of authentication failure
            window.dispatchEvent(new CustomEvent("auth-expired"));
          }
        } catch (error) {
          console.error("Error during token refresh:", error);
          this.stopTokenRefresh();
          window.dispatchEvent(new CustomEvent("auth-expired"));
        }
      },
      20 * 60 * 1000,
    ); // 20 minutes
  }

  private static stopTokenRefresh(): void {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
      this.refreshInterval = null;
    }
  }

  static getSubscriptionDisplayName(planType: string): string {
    switch (planType) {
      case "one_time":
        return "One-time Purchase";
      case "monthly":
        return "Monthly Subscription";
      default:
        return "Unknown Plan";
    }
  }

  static getSubscriptionStatus(status: string): string {
    switch (status) {
      case "active":
        return "Active";
      case "canceled":
        return "Canceled";
      case "expired":
        return "Expired";
      default:
        return "Unknown";
    }
  }
}

// Set up global auth event listener
if (typeof window !== "undefined") {
  window.addEventListener("auth-expired", () => {
    // This event can be listened to by components to handle auth expiration
    console.log("Authentication expired");
  });
}
