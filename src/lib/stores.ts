import { writable } from 'svelte/store';
import type { UserProfile, SubscriptionInfo } from './auth';

export interface User {
  id: string;
  email: string;
  full_name: string;
  authenticated: boolean;
  subscription?: SubscriptionInfo;
  profile?: UserProfile;
}

export const user = writable<User | null>(null);
export const isLoading = writable(false);
export const error = writable<string | null>(null);
export const authToken = writable<string | null>(null);

// Helper function to create user object from auth result
export function createUserFromProfile(profile: UserProfile, token: string): User {
  return {
    id: profile.id.toString(),
    email: profile.email,
    full_name: profile.full_name,
    authenticated: true,
    subscription: profile.subscription,
    profile: profile
  };
}

// Helper function to check if user has active subscription
export function hasActiveSubscription(user: User | null): boolean {
  return user?.subscription?.status === 'active';
}

// Helper function to get subscription display text
export function getSubscriptionDisplayText(user: User | null): string {
  if (!user?.subscription) {
    return 'No active subscription';
  }
  
  const planName = user.subscription.plan_type === 'one_time' ? 'One-time Purchase' : 'Monthly Subscription';
  const status = user.subscription.status;
  
  return `${planName} (${status})`;
}