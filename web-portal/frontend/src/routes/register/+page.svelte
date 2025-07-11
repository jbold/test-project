<script>
  import { register, createCheckoutSession, getDashboardUrl, getRegistrationUrl } from '$lib/auth.js';
  import { onMount } from 'svelte';

  let email = '';
  let password = '';
  let fullName = '';
  let loading = false;
  let error = '';
  let plan = 'one_time';

  onMount(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const planParam = urlParams.get('plan');
    if (planParam) {
      plan = planParam;
    }
  });

  async function handleSubmit() {
    if (!email || !password || !fullName) {
      error = 'Please fill in all fields';
      return;
    }

    loading = true;
    error = '';

    try {
      // First register the user
      await register(email, password, fullName);
      
      // Then create checkout session
      const successUrl = getDashboardUrl('payment=success');
      const cancelUrl = getRegistrationUrl('payment=cancelled');
      
      const { checkout_url } = await createCheckoutSession(plan, successUrl, cancelUrl);
      
      // Redirect to Stripe checkout
      window.location.href = checkout_url;
      
    } catch (err) {
      error = err.message;
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>Register - Legal Toolkit</title>
</svelte:head>

<div class="register-container">
  <div class="register-card">
    <h1>Create Your Account</h1>
    
    <div class="plan-info">
      <h3>Selected Plan: {plan === 'one_time' ? 'One-Time Purchase ($29)' : 'Monthly Subscription ($9/month)'}</h3>
      <p>You'll be redirected to secure payment after registration</p>
    </div>

    <form on:submit|preventDefault={handleSubmit}>
      <div class="form-group">
        <label for="fullName">Full Name</label>
        <input
          type="text"
          id="fullName"
          bind:value={fullName}
          placeholder="Enter your full name"
          required
        />
      </div>

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
        {loading ? 'Creating Account...' : 'Create Account & Pay'}
      </button>
    </form>

    <p class="login-link">
      Already have an account? <a href="/login">Login here</a>
    </p>
  </div>
</div>

<style>
  .register-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 80vh;
    padding: 2rem;
  }

  .register-card {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    width: 100%;
    max-width: 400px;
  }

  .register-card h1 {
    text-align: center;
    color: #2c3e50;
    margin-bottom: 1rem;
  }

  .plan-info {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 6px;
    margin-bottom: 2rem;
    text-align: center;
  }

  .plan-info h3 {
    color: #667eea;
    margin-bottom: 0.5rem;
  }

  .plan-info p {
    color: #666;
    font-size: 0.9rem;
    margin: 0;
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

  .login-link {
    text-align: center;
    margin-top: 1rem;
    color: #666;
  }

  .login-link a {
    color: #667eea;
    text-decoration: none;
  }

  .login-link a:hover {
    text-decoration: underline;
  }
</style>