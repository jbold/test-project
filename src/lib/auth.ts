import { invoke } from '@tauri-apps/api/core';

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
      const credentials: UserCredentials = { email, password };
      const result = await invoke<AuthResult>('login_user', { credentials });
      
      if (result.success) {
        // Start automatic token refresh
        this.startTokenRefresh();
      }
      
      return result;
    } catch (error) {
      console.error('Error during login:', error);
      return {
        success: false,
        message: `Login failed: ${error}`
      };
    }
  }

  static async validateToken(): Promise<AuthResult> {
    try {
      const result = await invoke<AuthResult>('validate_token');
      
      if (result.success) {
        // Start automatic token refresh if not already running
        if (!this.refreshInterval) {
          this.startTokenRefresh();
        }
      } else {
        this.stopTokenRefresh();
      }
      
      return result;
    } catch (error) {
      console.error('Error validating token:', error);
      this.stopTokenRefresh();
      return {
        success: false,
        message: `Token validation failed: ${error}`
      };
    }
  }

  static async logout(): Promise<AuthResult> {
    try {
      this.stopTokenRefresh();
      return await invoke<AuthResult>('logout_user');
    } catch (error) {
      console.error('Error during logout:', error);
      return {
        success: false,
        message: `Logout failed: ${error}`
      };
    }
  }

  static async checkAuthStatus(): Promise<boolean> {
    try {
      return await invoke<boolean>('check_auth_status');
    } catch (error) {
      console.error('Error checking auth status:', error);
      return false;
    }
  }

  static async refreshUserProfile(): Promise<AuthResult> {
    try {
      return await invoke<AuthResult>('refresh_user_profile');
    } catch (error) {
      console.error('Error refreshing user profile:', error);
      return {
        success: false,
        message: `Profile refresh failed: ${error}`
      };
    }
  }

  private static startTokenRefresh(): void {
    // Clear existing interval if any
    this.stopTokenRefresh();
    
    // Refresh every 25 minutes (tokens expire after 30 minutes)
    this.refreshInterval = setInterval(async () => {
      try {
        const result = await this.validateToken();
        if (!result.success) {
          console.log('Token refresh failed, stopping refresh interval');
          this.stopTokenRefresh();
          // Emit event to notify app of authentication failure
          window.dispatchEvent(new CustomEvent('auth-expired'));
        }
      } catch (error) {
        console.error('Error during token refresh:', error);
        this.stopTokenRefresh();
        window.dispatchEvent(new CustomEvent('auth-expired'));
      }
    }, 25 * 60 * 1000); // 25 minutes
  }

  private static stopTokenRefresh(): void {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
      this.refreshInterval = null;
    }
  }

  static getSubscriptionDisplayName(planType: string): string {
    switch (planType) {
      case 'one_time':
        return 'One-time Purchase';
      case 'monthly':
        return 'Monthly Subscription';
      default:
        return 'Unknown Plan';
    }
  }

  static getSubscriptionStatus(status: string): string {
    switch (status) {
      case 'active':
        return 'Active';
      case 'canceled':
        return 'Canceled';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }
}

// Set up global auth event listener
if (typeof window !== 'undefined') {
  window.addEventListener('auth-expired', () => {
    // This event can be listened to by components to handle auth expiration
    console.log('Authentication expired');
  });
}