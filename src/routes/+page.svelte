<script lang="ts">
  import { onMount } from 'svelte';
  import { user, isLoading, error, createUserFromProfile } from '$lib/stores';
  import { AuthService } from '$lib/auth';
  import Dashboard from '$lib/components/Dashboard.svelte';

  // Environment configuration
  const WEB_PORTAL_URL = import.meta.env.VITE_WEB_PORTAL_URL || 'http://localhost:3000';

  let email = '';
  let password = '';
  let authResult: string | null = null;

  onMount(async () => {
    // Set up auth expiration event listener
    const handleAuthExpiredEvent = () => {
      handleAuthExpired();
    };
    window.addEventListener('auth-expired', handleAuthExpiredEvent);

    // Initialize authentication check
    isLoading.set(true);
    try {
      console.log('Starting authentication check...');
      const result = await AuthService.validateToken();
      console.log('Auth validation result:', result);
      if (result.success && result.user_profile) {
        const userData = createUserFromProfile(result.user_profile, result.token!);
        user.set(userData);
        authResult = 'Welcome back! Authentication successful.';
      } else {
        // Clear any invalid stored data
        await AuthService.logout();
      }
    } catch (err) {
      console.error('Error during initial auth check:', err);
      error.set(`Failed to check authentication status: ${err}`);
    } finally {
      console.log('Authentication check complete, setting loading to false');
      isLoading.set(false);
    }

    // Cleanup function
    return () => {
      window.removeEventListener('auth-expired', handleAuthExpiredEvent);
    };
  });

  async function handleLogin() {
    if (!email || !password) {
      error.set('Please enter both email and password');
      return;
    }

    if (!isValidEmail(email)) {
      error.set('Please enter a valid email address');
      return;
    }

    isLoading.set(true);
    try {
      const result = await AuthService.login(email, password);
      if (result.success && result.user_profile) {
        const userData = createUserFromProfile(result.user_profile, result.token!);
        user.set(userData);
        authResult = 'Login successful! Welcome to Legal Toolkit.';
      } else {
        error.set(result.message || 'Login failed');
      }
    } catch (err) {
      console.error('Login error:', err);
      error.set('Login failed. Please try again.');
    } finally {
      isLoading.set(false);
    }
  }

  function isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  function clearMessages() {
    error.set(null);
    authResult = null;
  }

  function handleAuthExpired() {
    // Handle authentication expiration
    user.set(null);
    error.set('Your session has expired. Please log in again.');
  }

  $: if (email || password) clearMessages();
</script>

{#if $isLoading}
  <div class="loading-container">
    <div class="loading-spinner">
      <div class="spinner"></div>
      <p>Loading...</p>
    </div>
  </div>
{:else if $error}
  <div class="container">
    <h1>Error</h1>
    <p>Error details: {$error}</p>
    <button on:click={() => { error.set(null); isLoading.set(false); }}>Dismiss Error</button>
  </div>
{:else if $user?.authenticated}
  <Dashboard />
{:else}
  <div class="container">
    <div class="auth-header">
      <h1>Legal Toolkit</h1>
      <p class="subtitle">Secure Legal Case Management</p>
    </div>

    <div class="auth-container">
      <div class="auth-form">
        <h2>Sign in to your account</h2>
        <p class="info">
          Enter your email and password to access your legal cases and documents.
        </p>
        
        <div class="form-group">
          <label for="email">Email Address</label>
          <input
            id="email"
            type="email"
            bind:value={email}
            placeholder="Enter your email"
            autocomplete="email"
            on:keydown={(e) => {
              if (e.key === 'Enter') {
                handleLogin();
              }
            }}
          />
        </div>

        <div class="form-group">
          <label for="password">Password</label>
          <input
            id="password"
            type="password"
            bind:value={password}
            placeholder="Enter your password"
            autocomplete="current-password"
            on:keydown={(e) => {
              if (e.key === 'Enter') {
                handleLogin();
              }
            }}
          />
        </div>

        <button 
          on:click={handleLogin}
          disabled={!email || !password || $isLoading}
          class="login-btn"
        >
          {$isLoading ? 'Signing in...' : 'Sign In'}
        </button>

        <div class="auth-footer">
          <p>Don't have an account? <a href="{WEB_PORTAL_URL}/register" target="_blank">Register here</a></p>
          <p class="note">Registration and subscription management is handled through the web portal.</p>
        </div>
      </div>
    </div>

    {#if $error}
      <div class="error-message">{$error}</div>
    {/if}

    {#if authResult}
      <div class="success-message">{authResult}</div>
    {/if}
  </div>
{/if}

<style>
  .container {
    max-width: 450px;
    margin: 2rem auto;
    padding: 2rem;
  }

  .auth-header {
    text-align: center;
    margin-bottom: 2rem;
  }

  .auth-header h1 {
    color: #1f2937;
    margin-bottom: 0.5rem;
    font-size: 2rem;
    font-weight: 700;
  }

  .subtitle {
    color: #6b7280;
    font-size: 1.125rem;
    margin: 0;
  }

  .loading-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background: #f9fafb;
  }

  .loading-spinner {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 1rem;
  }

  .spinner {
    width: 32px;
    height: 32px;
    border: 3px solid #e5e7eb;
    border-top: 3px solid #3b82f6;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }

  .loading-spinner p {
    color: #6b7280;
    margin: 0;
  }

  .auth-container {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    padding: 2rem;
  }

  .auth-form h2 {
    color: #1f2937;
    margin-bottom: 0.5rem;
    font-size: 1.5rem;
    font-weight: 600;
  }

  .info {
    color: #6b7280;
    margin-bottom: 2rem;
    font-size: 0.875rem;
    line-height: 1.5;
  }

  .form-group {
    margin-bottom: 1.5rem;
  }

  label {
    display: block;
    margin-bottom: 0.5rem;
    color: #374151;
    font-weight: 500;
    font-size: 0.875rem;
  }

  input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 8px;
    font-size: 0.875rem;
    box-sizing: border-box;
    transition: border-color 0.2s ease, box-shadow 0.2s ease;
  }

  input:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .login-btn {
    width: 100%;
    padding: 0.875rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s ease;
    margin-bottom: 1.5rem;
  }

  .login-btn:hover:not(:disabled) {
    background: #2563eb;
  }

  .login-btn:disabled {
    background: #9ca3af;
    cursor: not-allowed;
  }

  .auth-footer {
    text-align: center;
    color: #6b7280;
    font-size: 0.875rem;
    line-height: 1.5;
  }

  .auth-footer a {
    color: #3b82f6;
    text-decoration: none;
  }

  .auth-footer a:hover {
    text-decoration: underline;
  }

  .note {
    margin-top: 0.5rem;
    font-size: 0.75rem;
    color: #9ca3af;
  }

  .error-message {
    background: #fef2f2;
    border: 1px solid #fecaca;
    color: #dc2626;
    padding: 1rem;
    border-radius: 8px;
    margin-top: 1rem;
    text-align: center;
    font-size: 0.875rem;
  }

  .success-message {
    background: #f0fdf4;
    border: 1px solid #bbf7d0;
    color: #166534;
    padding: 1rem;
    border-radius: 8px;
    margin-top: 1rem;
    text-align: center;
    font-size: 0.875rem;
  }
</style>