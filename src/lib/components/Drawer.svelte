<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let isOpen = false;
  export let currentView = 'chat';

  const dispatch = createEventDispatcher();

  const menuItems = [
    { id: 'chat', label: 'Chat', icon: 'message-circle' },
    { id: 'timeline', label: 'Timeline', icon: 'calendar' },
    { id: 'evidence', label: 'Evidence', icon: 'folder' },
    { id: 'documents', label: 'Documents', icon: 'file-text' },
    { id: 'research', label: 'Research', icon: 'search' },
    { id: 'strategy', label: 'Strategy', icon: 'target' },
    { id: 'analytics', label: 'Analytics', icon: 'bar-chart' },
    { id: 'settings', label: 'Settings', icon: 'settings' }
  ];

  function selectView(viewId: string) {
    dispatch('view-change', { view: viewId });
  }

  function closeDrawer() {
    dispatch('close');
  }

  function renderIcon(iconName: string) {
    const icons = {
      'message-circle': '<circle cx="12" cy="12" r="3"></circle><path d="M12 1a11 11 0 0 0-11 11c0 2.046.561 3.961 1.537 5.596L1 22l4.404-1.537A10.96 10.96 0 0 0 12 23c6.075 0 11-4.925 11-11S18.075 1 12 1z"></path>',
      'calendar': '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line>',
      'folder': '<path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>',
      'file-text': '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14,2 14,8 20,8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10,9 9,9 8,9"></polyline>',
      'search': '<circle cx="11" cy="11" r="8"></circle><path d="m21 21-4.35-4.35"></path>',
      'target': '<circle cx="12" cy="12" r="10"></circle><circle cx="12" cy="12" r="6"></circle><circle cx="12" cy="12" r="2"></circle>',
      'bar-chart': '<line x1="12" y1="20" x2="12" y2="10"></line><line x1="18" y1="20" x2="18" y2="4"></line><line x1="6" y1="20" x2="6" y2="16"></line>',
      'settings': '<circle cx="12" cy="12" r="3"></circle><path d="M12 1a11 11 0 0 0-11 11c0 2.046.561 3.961 1.537 5.596L1 22l4.404-1.537A10.96 10.96 0 0 0 12 23c6.075 0 11-4.925 11-11S18.075 1 12 1z"></path>'
    };
    return icons[iconName] || '';
  }
</script>

<!-- Overlay -->
{#if isOpen}
  <div class="overlay" on:click={closeDrawer} on:keydown={(e) => e.key === 'Escape' && closeDrawer()} role="button" tabindex="-1"></div>
{/if}

<!-- Drawer -->
<nav class="drawer" class:open={isOpen}>
  <div class="drawer-header">
    <h2>Legal Toolkit</h2>
    <button class="close-btn" on:click={closeDrawer} aria-label="Close menu">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="18" y1="6" x2="6" y2="18"></line>
        <line x1="6" y1="6" x2="18" y2="18"></line>
      </svg>
    </button>
  </div>

  <div class="menu-section">
    <h3>Main</h3>
    <ul class="menu-list">
      {#each menuItems as item}
        <li>
          <button 
            class="menu-item" 
            class:active={currentView === item.id}
            on:click={() => selectView(item.id)}
          >
            <svg class="menu-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              {@html renderIcon(item.icon)}
            </svg>
            <span>{item.label}</span>
          </button>
        </li>
      {/each}
    </ul>
  </div>

  <div class="drawer-footer">
    <div class="case-info">
      <div class="case-badge">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
        </svg>
        <span>Current Case</span>
      </div>
      <p class="case-name">Employment Dispute</p>
    </div>
  </div>
</nav>

<style>
  .overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0, 0, 0, 0.3);
    z-index: 150;
    opacity: 0;
    animation: fadeIn 0.2s ease-out forwards;
  }

  @keyframes fadeIn {
    to { opacity: 1; }
  }

  .drawer {
    position: fixed;
    top: 0;
    left: 0;
    height: 100vh;
    width: 280px;
    background: #fff;
    border-right: 1px solid #e5e7eb;
    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
    z-index: 200;
    transform: translateX(-100%);
    transition: transform 0.3s ease-out;
    display: flex;
    flex-direction: column;
  }

  .drawer.open {
    transform: translateX(0);
  }

  .drawer-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #e5e7eb;
    background: #f9fafb;
  }

  .drawer-header h2 {
    font-size: 1.125rem;
    font-weight: 600;
    color: #1f2937;
    margin: 0;
  }

  .close-btn {
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

  .close-btn:hover {
    background: #e5e7eb;
    color: #374151;
  }

  .menu-section {
    flex: 1;
    overflow-y: auto;
    padding: 1rem 0;
  }

  .menu-section h3 {
    font-size: 0.75rem;
    font-weight: 600;
    color: #6b7280;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin: 0 0 0.5rem 0;
    padding: 0 1.5rem;
  }

  .menu-list {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .menu-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    width: 100%;
    padding: 0.75rem 1.5rem;
    background: none;
    border: none;
    text-align: left;
    font-size: 0.875rem;
    color: #374151;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .menu-item:hover {
    background: #f3f4f6;
    color: #1f2937;
  }

  .menu-item.active {
    background: #dbeafe;
    color: #1d4ed8;
    border-right: 3px solid #3b82f6;
  }

  .menu-icon {
    flex-shrink: 0;
    color: currentColor;
  }

  .drawer-footer {
    padding: 1rem 1.5rem;
    border-top: 1px solid #e5e7eb;
    background: #f9fafb;
  }

  .case-info {
    margin-bottom: 1rem;
  }

  .case-badge {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    margin-bottom: 0.5rem;
  }

  .case-badge span {
    font-size: 0.75rem;
    font-weight: 500;
    color: #6b7280;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .case-badge svg {
    color: #6b7280;
  }

  .case-name {
    font-size: 0.875rem;
    font-weight: 500;
    color: #1f2937;
    margin: 0;
  }

  @media (max-width: 768px) {
    .drawer {
      width: 100vw;
      max-width: 320px;
    }
  }
</style>