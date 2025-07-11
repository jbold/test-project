<script>
  import { user } from '$lib/auth.js';
  
  let currentUser = null;

  user.subscribe(value => {
    currentUser = value;
  });
</script>

<svelte:head>
  <title>Legal Toolkit - Professional Legal Document Management</title>
</svelte:head>

<div class="hero">
  <h1>Legal Toolkit</h1>
  <p>Professional legal document management and workflow automation</p>
  
  {#if currentUser}
    <div class="user-welcome">
      <h2>Welcome back, {currentUser.full_name}!</h2>
      <div class="actions">
        <a href="/dashboard" class="btn btn-primary">Go to Dashboard</a>
        <a href="/download" class="btn btn-secondary">Download App</a>
      </div>
    </div>
  {:else}
    <div class="pricing">
      <h2>Choose Your Plan</h2>
      <div class="plans">
        <div class="plan">
          <h3>One-Time Purchase</h3>
          <div class="price">$29</div>
          <ul>
            <li>Lifetime access</li>
            <li>All current features</li>
            <li>Desktop application</li>
            <li>Email support</li>
          </ul>
          <a href="/register?plan=one_time" class="btn btn-primary">Get Started</a>
        </div>
        
        <div class="plan featured">
          <h3>Monthly Subscription</h3>
          <div class="price">$9<span>/month</span></div>
          <ul>
            <li>All features</li>
            <li>Priority support</li>
            <li>Regular updates</li>
            <li>Cloud sync</li>
          </ul>
          <a href="/register?plan=monthly" class="btn btn-primary">Start Free Trial</a>
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .hero {
    text-align: center;
    padding: 4rem 2rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border-radius: 12px;
    margin-bottom: 2rem;
  }

  .hero h1 {
    font-size: 3rem;
    margin-bottom: 1rem;
  }

  .hero p {
    font-size: 1.2rem;
    margin-bottom: 2rem;
  }

  .user-welcome {
    background: rgba(255, 255, 255, 0.1);
    padding: 2rem;
    border-radius: 8px;
    margin-top: 2rem;
  }

  .actions {
    display: flex;
    gap: 1rem;
    justify-content: center;
    margin-top: 1rem;
  }

  .pricing {
    margin-top: 2rem;
  }

  .plans {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
    margin-top: 2rem;
  }

  .plan {
    background: white;
    color: #333;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }

  .plan.featured {
    border: 2px solid #667eea;
    transform: scale(1.05);
  }

  .plan h3 {
    margin-bottom: 1rem;
    color: #2c3e50;
  }

  .price {
    font-size: 2rem;
    font-weight: bold;
    color: #667eea;
    margin-bottom: 1rem;
  }

  .price span {
    font-size: 1rem;
    color: #666;
  }

  .plan ul {
    list-style: none;
    padding: 0;
    margin: 1rem 0;
  }

  .plan li {
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
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
    background-color: transparent;
    color: white;
    border: 2px solid white;
  }

  .btn-secondary:hover {
    background-color: white;
    color: #667eea;
  }
</style>