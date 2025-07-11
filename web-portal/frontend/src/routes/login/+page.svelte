<script>
  import { login } from '$lib/auth.js';
  import { goto } from '$app/navigation';

  let email = '';
  let password = '';
  let loading = false;
  let error = '';

  async function handleSubmit() {
    if (!email || !password) {
      error = 'Please fill in all fields';
      return;
    }

    loading = true;
    error = '';

    try {
      await login(email, password);
      goto('/dashboard');
    } catch (err) {
      error = err.message;
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>Login - Legal Toolkit</title>
</svelte:head>

<div class="login-container">
  <div class="login-card">
    <h1>Welcome Back</h1>
    <p>Sign in to your Legal Toolkit account</p>

    <form on:submit|preventDefault={handleSubmit}>
      <div class="form-group">
        <label for="email">Email Address</label>
        <input
          type="email"
          id="email"
          bind:value={email}
          placeholder="Enter your email address"
          required
        />
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input
          type="password"
          id="password"
          bind:value={password}
          placeholder="Enter your password"
          required
        />
      </div>

      {#if error}
        <div class="error">{error}</div>
      {/if}

      <button type="submit" class="btn btn-primary" disabled={loading}>
        {loading ? 'Signing in...' : 'Sign In'}
      </button>
    </form>

    <p class="register-link">
      Don't have an account? <a href="/register">Register here</a>
    </p>
  </div>
</div>

<style>
  .login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 80vh;
    padding: 2rem;
  }

  .login-card {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px;
  }

  .login-card h1 {
    text-align: center;
    color: #2c3e50;
    margin-bottom: 0.5rem;
  }

  .login-card p {
    text-align: center;
    color: #666;
    margin-bottom: 2rem;
  }

  .form-group {
    margin-bottom: 1rem;
  }

  .form-group label {
    display: block;
    margin-bottom: 0.5rem;
    color: #333;
    font-weight: 500;
  }

  .form-group input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 1rem;
    transition: border-color 0.2s;
  }

  .form-group input:focus {
    outline: none;
    border-color: #667eea;
  }

  .error {
    background-color: #fee;
    color: #c33;
    padding: 0.75rem;
    border-radius: 4px;
    margin-bottom: 1rem;
    font-size: 0.9rem;
  }

  .btn {
    width: 100%;
    padding: 0.75rem;
    border: none;
    border-radius: 4px;
    font-size: 1rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .btn-primary {
    background-color: #667eea;
    color: white;
  }

  .btn-primary:hover:not(:disabled) {
    background-color: #5a6fd8;
  }

  .btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .register-link {
    text-align: center;
    margin-top: 1rem;
    color: #666;
  }

  .register-link a {
    color: #667eea;
    text-decoration: none;
  }

  .register-link a:hover {
    text-decoration: underline;
  }
</style>