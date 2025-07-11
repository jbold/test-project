<script>
  import { user } from '$lib/auth.js';
  import { onMount } from 'svelte';

  let currentUser = null;
  let paymentSuccess = false;

  user.subscribe(value => {
    currentUser = value;
  });

  onMount(() => {
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('payment') === 'success') {
      paymentSuccess = true;
    }
  });
</script>

<svelte:head>
  <title>Dashboard - Legal Toolkit</title>
</svelte:head>

{#if paymentSuccess}
  <div class="success-message">
    <h2>Payment Successful!</h2>
    <p>Thank you for your purchase. Your account is now active.</p>
  </div>
{/if}

<div class="dashboard">
  <h1>Dashboard</h1>
  
  {#if currentUser}
    <div class="user-info">
      <h2>Welcome, {currentUser.full_name}</h2>
      <p><strong>Email:</strong> {currentUser.email}</p>
      <p><strong>Account Status:</strong> {currentUser.is_active ? 'Active' : 'Inactive'}</p>
      <p><strong>Member Since:</strong> {new Date(currentUser.created_at).toLocaleDateString()}</p>
      
      {#if currentUser.subscription}
        <div class="subscription-info">
          <h3>Subscription Details</h3>
          <p><strong>Plan:</strong> {currentUser.subscription.plan_type === 'one_time' ? 'One-Time Purchase' : 'Monthly Subscription'}</p>
          <p><strong>Status:</strong> {currentUser.subscription.status}</p>
          <p><strong>Started:</strong> {new Date(currentUser.subscription.created_at).toLocaleDateString()}</p>
        </div>
      {/if}
    </div>

    <div class="actions">
      <a href="/download" class="btn btn-primary">Download Desktop App</a>
      <a href="/profile" class="btn btn-secondary">Manage Profile</a>
    </div>

    <div class="features">
      <h3>Available Features</h3>
      <div class="feature-grid">
        <div class="feature-card">
          <h4>Document Management</h4>
          <p>Organize and manage your legal documents efficiently</p>
        </div>
        <div class="feature-card">
          <h4>Case Tracking</h4>
          <p>Track case progress and important deadlines</p>
        </div>
        <div class="feature-card">
          <h4>Client Management</h4>
          <p>Manage client information and communications</p>
        </div>
        <div class="feature-card">
          <h4>Time Tracking</h4>
          <p>Track billable hours and generate reports</p>
        </div>
      </div>
    </div>
  {:else}
    <p>Loading user information...</p>
  {/if}
</div>

<style>
  .success-message {
    background: linear-gradient(135deg, #4CAF50, #45a049);
    color: white;
    padding: 2rem;
    border-radius: 8px;
    margin-bottom: 2rem;
    text-align: center;
  }

  .dashboard {
    max-width: 1000px;
    margin: 0 auto;
  }

  .dashboard h1 {
    color: #2c3e50;
    margin-bottom: 2rem;
  }

  .user-info {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    margin-bottom: 2rem;
  }

  .user-info h2 {
    color: #667eea;
    margin-bottom: 1rem;
  }

  .user-info p {
    margin-bottom: 0.5rem;
    color: #666;
  }

  .subscription-info {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 6px;
    margin-top: 1rem;
  }

  .subscription-info h3 {
    color: #2c3e50;
    margin-bottom: 0.5rem;
  }

  .actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
  }

  .btn {
    display: inline-block;
    padding: 0.75rem 1.5rem;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.2s;
    border: none;
    cursor: pointer;
  }

  .btn-primary {
    background-color: #667eea;
    color: white;
  }

  .btn-primary:hover {
    background-color: #5a6fd8;
  }

  .btn-secondary {
    background-color: #6c757d;
    color: white;
  }

  .btn-secondary:hover {
    background-color: #5a6268;
  }

  .features {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .features h3 {
    color: #2c3e50;
    margin-bottom: 1rem;
  }

  .feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1rem;
  }

  .feature-card {
    background: #f8f9fa;
    padding: 1.5rem;
    border-radius: 6px;
    border-left: 4px solid #667eea;
  }

  .feature-card h4 {
    color: #2c3e50;
    margin-bottom: 0.5rem;
  }

  .feature-card p {
    color: #666;
    margin: 0;
  }
</style>