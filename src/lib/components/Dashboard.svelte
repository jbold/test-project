<script lang="ts">
  import Header from './Header.svelte';
  import Drawer from './Drawer.svelte';
  import ChatInterface from './ChatInterface.svelte';
  import TimelineView from './TimelineView.svelte';
  import EvidenceView from './EvidenceView.svelte';

  let isDrawerOpen = false;
  let currentView = 'chat';

  function toggleDrawer() {
    isDrawerOpen = !isDrawerOpen;
  }

  function closeDrawer() {
    isDrawerOpen = false;
  }

  function handleViewChange(event) {
    currentView = event.detail.view;
    isDrawerOpen = false; // Close drawer after selection
  }

  function renderCurrentView() {
    switch (currentView) {
      case 'timeline':
        return TimelineView;
      case 'evidence':
        return EvidenceView;
      case 'documents':
      case 'research':
      case 'strategy':
      case 'analytics':
      case 'settings':
        return ChatInterface; // Placeholder for now
      default:
        return ChatInterface;
    }
  }

  $: CurrentComponent = renderCurrentView();
</script>

<div class="dashboard">
  <Header on:toggle-drawer={toggleDrawer} />
  
  <Drawer 
    {isDrawerOpen} 
    {currentView}
    on:close={closeDrawer}
    on:view-change={handleViewChange}
  />

  <main class="main-content" class:drawer-open={isDrawerOpen}>
    <svelte:component this={CurrentComponent} />
  </main>
</div>

<style>
  .dashboard {
    height: 100vh;
    display: flex;
    flex-direction: column;
    background: #f9fafb;
  }

  .main-content {
    flex: 1;
    overflow: hidden;
    transition: margin-left 0.3s ease-out;
  }

  .main-content.drawer-open {
    margin-left: 0; /* Drawer overlays on mobile */
  }

  @media (min-width: 1024px) {
    .main-content.drawer-open {
      margin-left: 280px; /* Drawer pushes content on desktop */
    }
  }
</style>