import { writable } from 'svelte/store';
import axios from 'axios';

const API_BASE = 'http://localhost:8000';

// Auth store
export const user = writable(null);
export const token = writable(null);

// Initialize auth from localStorage
if (typeof window !== 'undefined') {
  const storedToken = localStorage.getItem('token');
  if (storedToken) {
    token.set(storedToken);
    // Verify token and get user info
    getUserProfile();
  }
}

// API client with auth headers
const apiClient = axios.create({
  baseURL: API_BASE,
});

// Add auth header to requests
apiClient.interceptors.request.use((config) => {
  const storedToken = localStorage.getItem('token');
  if (storedToken) {
    config.headers.Authorization = `Bearer ${storedToken}`;
  }
  return config;
});

// Handle auth errors
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      logout();
    }
    return Promise.reject(error);
  }
);

export async function register(email, password, fullName) {
  try {
    const response = await axios.post(`${API_BASE}/auth/register`, {
      email,
      password,
      full_name: fullName
    });
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.detail || 'Registration failed');
  }
}

export async function login(email, password) {
  try {
    const response = await axios.post(`${API_BASE}/auth/login`, {
      email,
      password
    });
    
    const { access_token } = response.data;
    localStorage.setItem('token', access_token);
    token.set(access_token);
    
    // Get user profile
    await getUserProfile();
    
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.detail || 'Login failed');
  }
}

export async function logout() {
  localStorage.removeItem('token');
  token.set(null);
  user.set(null);
}

export async function getUserProfile() {
  try {
    const response = await apiClient.get('/user/profile');
    user.set(response.data);
    return response.data;
  } catch (error) {
    console.error('Failed to get user profile:', error);
    logout();
    throw error;
  }
}

export async function createCheckoutSession(planType, successUrl, cancelUrl) {
  try {
    const response = await apiClient.post('/payment/create-checkout', {
      plan_type: planType,
      success_url: successUrl,
      cancel_url: cancelUrl
    });
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.detail || 'Failed to create checkout session');
  }
}

export async function getDownloadLink() {
  try {
    const response = await apiClient.get('/download/app');
    return response.data;
  } catch (error) {
    throw new Error(error.response?.data?.detail || 'Failed to get download link');
  }
}