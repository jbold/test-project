<script>
  import { user, logout } from '$lib/auth.js';
  import { onMount } from 'svelte';

  let currentUser = null;

  user.subscribe(value => {
    currentUser = value;
  });

  async function handleLogout() {
    await logout();
    window.location.href = '/';
  }
</script>

<div class="app">
  <nav>
    <h1><a href="/">Legal Toolkit</a></h1>
    <div class="nav-links">
      {#if currentUser}
        <span>Welcome, {currentUser.full_name}</span>
        <a href="/dashboard">Dashboard</a>
        <a href="/download">Download</a>
        <button on:click={handleLogout}>Logout</button>
      {:else}
        <a href="/login">Login</a>
        <a href="/register">Register</a>
      {/if}
    </div>
  </nav>

  <main>
    <slot />
  </main>
</div>

<style>
  .app {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    margin: 0;
    padding: 0;
    min-height: 100vh;
    background-color: #f5f5f5;
  }

  nav {
    background-color: #2c3e50;
    color: white;
    padding: 1rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  nav h1 {
    margin: 0;
  }

  nav h1 a {
    color: white;
    text-decoration: none;
  }

  .nav-links {
    display: flex;
    gap: 1rem;
    align-items: center;
  }

  .nav-links a,
  .nav-links button {
    color: white;
    text-decoration: none;
    padding: 0.5rem 1rem;
    border: 1px solid transparent;
    border-radius: 4px;
    background: none;
    cursor: pointer;
    transition: background-color 0.2s;
  }

  .nav-links a:hover,
  .nav-links button:hover {
    background-color: rgba(255, 255, 255, 0.1);
  }

  main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
  }
</style>