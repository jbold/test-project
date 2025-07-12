<script lang="ts">
  import { onMount } from 'svelte';
  import { user, isLoading } from '$lib/stores';
  import { AuthService } from '$lib/auth';

  onMount(async () => {
    isLoading.set(true);
    
    try {
      const hasAuth = await AuthService.checkAuthStatus();
      if (!hasAuth) {
        // No stored authentication - user needs to login
        user.set(null);
      } else {
        // User has stored auth but we'll validate it in the main page
        user.set(null);
      }
    } catch (error) {
      console.error('Error checking auth status:', error);
    } finally {
      isLoading.set(false);
    }
  });
</script>

<main>
  <slot />
</main>

<style>
  main {
    padding: 1rem;
    max-width: 1200px;
    margin: 0 auto;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }
</style>