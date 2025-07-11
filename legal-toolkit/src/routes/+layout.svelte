<script lang="ts">
  import { onMount } from 'svelte';
  import { user, isLoading } from '$lib/stores';
  import { AuthService } from '$lib/auth';

  onMount(async () => {
    isLoading.set(true);
    
    try {
      const userExists = await AuthService.checkUserExists();
      if (!userExists) {
        // First time user - they'll need to create an account
        user.set(null);
      } else {
        // User exists but needs to authenticate
        user.set(null);
      }
    } catch (error) {
      console.error('Error checking user:', error);
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