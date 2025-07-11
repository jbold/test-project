<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { user, getSubscriptionDisplayText } from '$lib/stores';
  import { AuthService } from '$lib/auth';

  const dispatch = createEventDispatcher();

  function toggleDrawer() {
    dispatch('toggle-drawer');
  }

  async function handleLogout() {
    try {
      await AuthService.logout();
      user.set(null);
    } catch (error) {
      console.error('Logout error:', error);
      // Force logout even if API call fails
      user.set(null);
    }
  }

  $: subscriptionText = getSubscriptionDisplayText($user);
</script>

<header class="header">
  <div class="header-left">
    <button class="hamburger-btn" on:click={toggleDrawer} aria-label="Toggle menu">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="3" y1="6" x2="21" y2="6"></line>
        <line x1="3" y1="12" x2="21" y2="12"></line>
        <line x1="3" y1="18" x2="21" y2="18"></line>
      </svg>
    </button>
    <h1 class="app-title">Legal Toolkit</h1>
  </div>

  <div class="header-right">
    {#if $user}
      <div class="user-info">
        <div class="user-details">
          <div class="user-avatar">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
              <circle cx="12" cy="7" r="4"></circle>
            </svg>
          </div>
          <div class="user-text">
            <span class="user-email">{$user.email}</span>
            <span class="subscription-status" class:active={$user.subscription?.status === 'active'}>
              {subscriptionText}
            </span>
          </div>
        </div>
        <button class="logout-btn" on:click={handleLogout} aria-label="Logout">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
            <polyline points="16,17 21,12 16,7"></polyline>
            <line x1="21" y1="12" x2="9" y2="12"></line>
          </svg>
        </button>
      </div>
    {/if}
  </div>
</header>

<style>
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    background: #fff;
    border-bottom: 1px solid #e5e7eb;
    box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
    height: 60px;
    position: sticky;
    top: 0;
    z-index: 100;
  }

  .header-left {
    display: flex;
    align-items: center;
    gap: 1rem;
  }

  .hamburger-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    padding: 0;
    background: none;
    border: none;
    border-radius: 6px;
    color: #6b7280;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .hamburger-btn:hover {
    background: #f3f4f6;
    color: #374151;
  }

  .hamburger-btn:active {
    background: #e5e7eb;
  }

  .app-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #1f2937;
    margin: 0;
  }

  .header-right {
    display: flex;
    align-items: center;
  }

  .user-info {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.5rem;
    border-radius: 8px;
    transition: background-color 0.2s ease;
  }

  .user-info:hover {
    background: #f9fafb;
  }

  .user-details {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .user-avatar {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    background: #3b82f6;
    color: white;
    border-radius: 50%;
    flex-shrink: 0;
  }

  .user-text {
    display: flex;
    flex-direction: column;
    gap: 0.125rem;
  }

  .user-email {
    font-size: 0.875rem;
    color: #1f2937;
    font-weight: 500;
  }

  .subscription-status {
    font-size: 0.75rem;
    color: #6b7280;
    font-weight: 400;
  }

  .subscription-status.active {
    color: #059669;
  }

  .logout-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    padding: 0;
    background: none;
    border: none;
    border-radius: 4px;
    color: #6b7280;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .logout-btn:hover {
    background: #fee2e2;
    color: #dc2626;
  }
</style>