<script lang="ts">
  interface EvidenceItem {
    id: string;
    name: string;
    type: 'email' | 'document' | 'image' | 'audio' | 'video';
    size: string;
    uploadDate: Date;
    tags: string[];
    description?: string;
    relatedEvents?: string[];
  }

  const mockEvidence: EvidenceItem[] = [
    {
      id: '1',
      name: 'accommodation_request.pdf',
      type: 'document',
      size: '245 KB',
      uploadDate: new Date('2024-03-15'),
      tags: ['ADA', 'Accommodation', 'HR'],
      description: 'Initial formal accommodation request submitted to HR department',
      relatedEvents: ['Initial Accommodation Request']
    },
    {
      id: '2',
      name: 'hr_response_1.pdf',
      type: 'email',
      size: '156 KB',
      uploadDate: new Date('2024-03-20'),
      tags: ['HR Response', 'Medical Documentation'],
      description: 'HR response requesting additional medical documentation',
      relatedEvents: ['HR Response - Request for Medical Documentation']
    },
    {
      id: '3',
      name: 'medical_documentation.pdf',
      type: 'document',
      size: '1.2 MB',
      uploadDate: new Date('2024-04-02'),
      tags: ['Medical', 'Physician', 'Documentation'],
      description: 'Medical records and physician letter supporting accommodation request',
      relatedEvents: ['Medical Documentation Submitted']
    },
    {
      id: '4',
      name: 'meeting_recording.m4a',
      type: 'audio',
      size: '45 MB',
      uploadDate: new Date('2024-04-15'),
      tags: ['Meeting', 'Recording', 'HR'],
      description: 'Audio recording of accommodation discussion meeting',
      relatedEvents: ['Follow-up Meeting Scheduled']
    },
    {
      id: '5',
      name: 'workspace_photos.zip',
      type: 'image',
      size: '8.7 MB',
      uploadDate: new Date('2024-04-10'),
      tags: ['Workspace', 'Photos', 'Accommodation'],
      description: 'Photos of current workspace showing accessibility challenges'
    }
  ];

  let searchTerm = '';
  let selectedType = 'all';
  let selectedTag = 'all';

  $: filteredEvidence = mockEvidence.filter(item => {
    const matchesSearch = item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         (item.description && item.description.toLowerCase().includes(searchTerm.toLowerCase()));
    const matchesType = selectedType === 'all' || item.type === selectedType;
    const matchesTag = selectedTag === 'all' || item.tags.some(tag => 
      tag.toLowerCase().includes(selectedTag.toLowerCase())
    );
    
    return matchesSearch && matchesType && matchesTag;
  });

  $: allTags = [...new Set(mockEvidence.flatMap(item => item.tags))];

  function getTypeIcon(type: string): string {
    const icons = {
      'email': '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline>',
      'document': '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14,2 14,8 20,8"></polyline>',
      'image': '<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21,15 16,10 5,21"></polyline>',
      'audio': '<polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>',
      'video': '<polygon points="23 7 16 12 23 17 23 7"></polygon><rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect>'
    };
    return icons[type] || icons['document'];
  }

  function getTypeColor(type: string): string {
    const colors = {
      'email': '#3b82f6',
      'document': '#10b981',
      'image': '#f59e0b',
      'audio': '#8b5cf6',
      'video': '#ef4444'
    };
    return colors[type] || colors['document'];
  }

  function formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  }

  function handleUpload() {
    alert('Feature coming soon: Upload new evidence');
  }

  function viewEvidence(item: EvidenceItem) {
    alert(`Feature coming soon: View ${item.name}`);
  }
</script>

<div class="evidence-view">
  <div class="evidence-header">
    <div class="header-content">
      <h2>Evidence Library</h2>
      <p class="subtitle">Manage and organize all case-related documents and media</p>
    </div>
    <button class="upload-btn" on:click={handleUpload}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
        <polyline points="7,10 12,15 17,10"></polyline>
        <line x1="12" y1="15" x2="12" y2="3"></line>
      </svg>
      Upload Evidence
    </button>
  </div>

  <div class="evidence-filters">
    <div class="search-box">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <circle cx="11" cy="11" r="8"></circle>
        <path d="m21 21-4.35-4.35"></path>
      </svg>
      <input 
        type="text" 
        placeholder="Search evidence..."
        bind:value={searchTerm}
      />
    </div>

    <div class="filter-group">
      <select bind:value={selectedType}>
        <option value="all">All Types</option>
        <option value="document">Documents</option>
        <option value="email">Emails</option>
        <option value="image">Images</option>
        <option value="audio">Audio</option>
        <option value="video">Video</option>
      </select>

      <select bind:value={selectedTag}>
        <option value="all">All Tags</option>
        {#each allTags as tag}
          <option value={tag}>{tag}</option>
        {/each}
      </select>
    </div>
  </div>

  <div class="evidence-grid">
    {#each filteredEvidence as item (item.id)}
      <div class="evidence-card" on:click={() => viewEvidence(item)} on:keydown={(e) => e.key === 'Enter' && viewEvidence(item)} role="button" tabindex="0">
        <div class="card-header">
          <div class="file-icon" style="background-color: {getTypeColor(item.type)}">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
              {@html getTypeIcon(item.type)}
            </svg>
          </div>
          <div class="file-info">
            <h3 class="file-name">{item.name}</h3>
            <div class="file-meta">
              <span class="file-size">{item.size}</span>
              <span class="file-date">{formatDate(item.uploadDate)}</span>
            </div>
          </div>
        </div>

        {#if item.description}
          <p class="file-description">{item.description}</p>
        {/if}

        <div class="file-tags">
          {#each item.tags as tag}
            <span class="tag">{tag}</span>
          {/each}
        </div>

        {#if item.relatedEvents && item.relatedEvents.length > 0}
          <div class="related-events">
            <h4>Related Timeline Events:</h4>
            <ul>
              {#each item.relatedEvents as event}
                <li>{event}</li>
              {/each}
            </ul>
          </div>
        {/if}

        <div class="card-actions">
          <button class="action-btn view">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
              <circle cx="12" cy="12" r="3"></circle>
            </svg>
            View
          </button>
          <button class="action-btn download">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7,10 12,15 17,10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Download
          </button>
        </div>
      </div>
    {/each}

    {#if filteredEvidence.length === 0}
      <div class="empty-state">
        <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1">
          <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
        </svg>
        <h3>No evidence found</h3>
        <p>Try adjusting your search or filters, or upload new evidence to get started.</p>
      </div>
    {/if}
  </div>

  <div class="evidence-stats">
    <div class="stat-card">
      <div class="stat-number">{mockEvidence.length}</div>
      <div class="stat-label">Total Files</div>
    </div>
    <div class="stat-card">
      <div class="stat-number">{mockEvidence.filter(e => e.type === 'document').length}</div>
      <div class="stat-label">Documents</div>
    </div>
    <div class="stat-card">
      <div class="stat-number">{mockEvidence.filter(e => e.type === 'email').length}</div>
      <div class="stat-label">Emails</div>
    </div>
    <div class="stat-card">
      <div class="stat-number">{allTags.length}</div>
      <div class="stat-label">Tags</div>
    </div>
  </div>
</div>

<style>
  .evidence-view {
    height: 100%;
    display: flex;
    flex-direction: column;
    background: #f9fafb;
  }

  .evidence-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 2rem 2rem 1rem 2rem;
    background: white;
    border-bottom: 1px solid #e5e7eb;
  }

  .header-content h2 {
    font-size: 1.5rem;
    font-weight: 600;
    color: #1f2937;
    margin: 0 0 0.5rem 0;
  }

  .subtitle {
    font-size: 0.875rem;
    color: #6b7280;
    margin: 0;
  }

  .upload-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1rem;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 0.875rem;
    font-weight: 500;
    cursor: pointer;
    transition: background-color 0.2s ease;
  }

  .upload-btn:hover {
    background: #2563eb;
  }

  .evidence-filters {
    display: flex;
    gap: 1rem;
    padding: 1.5rem 2rem;
    background: white;
    border-bottom: 1px solid #e5e7eb;
  }

  .search-box {
    position: relative;
    flex: 1;
    max-width: 400px;
  }

  .search-box svg {
    position: absolute;
    left: 0.75rem;
    top: 50%;
    transform: translateY(-50%);
    color: #6b7280;
  }

  .search-box input {
    width: 100%;
    padding: 0.75rem 0.75rem 0.75rem 2.5rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    background: white;
  }

  .search-box input:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .filter-group {
    display: flex;
    gap: 1rem;
  }

  .filter-group select {
    padding: 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 6px;
    font-size: 0.875rem;
    background: white;
    cursor: pointer;
  }

  .filter-group select:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .evidence-grid {
    flex: 1;
    overflow-y: auto;
    padding: 2rem;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 1.5rem;
    align-content: start;
  }

  .evidence-card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .evidence-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    transform: translateY(-2px);
  }

  .card-header {
    display: flex;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  .file-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    border-radius: 8px;
    flex-shrink: 0;
  }

  .file-info {
    flex: 1;
    min-width: 0;
  }

  .file-name {
    font-size: 1rem;
    font-weight: 600;
    color: #1f2937;
    margin: 0 0 0.25rem 0;
    word-break: break-word;
  }

  .file-meta {
    display: flex;
    gap: 1rem;
    font-size: 0.75rem;
    color: #6b7280;
  }

  .file-description {
    font-size: 0.875rem;
    color: #4b5563;
    line-height: 1.5;
    margin: 0 0 1rem 0;
  }

  .file-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-bottom: 1rem;
  }

  .tag {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    background: #f3f4f6;
    color: #374151;
    font-size: 0.75rem;
    font-weight: 500;
    border-radius: 4px;
  }

  .related-events {
    margin-bottom: 1rem;
    padding-top: 1rem;
    border-top: 1px solid #f3f4f6;
  }

  .related-events h4 {
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
    margin: 0 0 0.5rem 0;
  }

  .related-events ul {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .related-events li {
    font-size: 0.875rem;
    color: #6b7280;
    padding: 0.125rem 0;
  }

  .card-actions {
    display: flex;
    gap: 0.5rem;
  }

  .action-btn {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 0.75rem;
    border: 1px solid #d1d5db;
    border-radius: 4px;
    background: white;
    font-size: 0.875rem;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .action-btn:hover {
    background: #f9fafb;
    border-color: #9ca3af;
  }

  .action-btn.view {
    color: #3b82f6;
    border-color: #bfdbfe;
  }

  .action-btn.download {
    color: #10b981;
    border-color: #a7f3d0;
  }

  .empty-state {
    grid-column: 1 / -1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 3rem;
    text-align: center;
    color: #6b7280;
  }

  .empty-state svg {
    margin-bottom: 1rem;
    opacity: 0.5;
  }

  .empty-state h3 {
    font-size: 1.125rem;
    font-weight: 600;
    color: #374151;
    margin: 0 0 0.5rem 0;
  }

  .empty-state p {
    margin: 0;
    max-width: 400px;
  }

  .evidence-stats {
    display: flex;
    gap: 1rem;
    padding: 1.5rem 2rem;
    background: white;
    border-top: 1px solid #e5e7eb;
  }

  .stat-card {
    flex: 1;
    text-align: center;
    padding: 1rem;
    background: #f9fafb;
    border-radius: 8px;
  }

  .stat-number {
    font-size: 1.875rem;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 0.25rem;
  }

  .stat-label {
    font-size: 0.875rem;
    color: #6b7280;
    font-weight: 500;
  }

  @media (max-width: 768px) {
    .evidence-header {
      flex-direction: column;
      gap: 1rem;
      align-items: stretch;
    }

    .evidence-filters {
      flex-direction: column;
      gap: 1rem;
    }

    .filter-group {
      flex-direction: column;
    }

    .evidence-grid {
      padding: 1rem;
      grid-template-columns: 1fr;
    }

    .evidence-stats {
      flex-wrap: wrap;
      gap: 0.75rem;
    }

    .stat-card {
      flex: 1;
      min-width: calc(50% - 0.375rem);
    }
  }
</style>