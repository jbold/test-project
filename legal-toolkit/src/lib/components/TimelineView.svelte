<script lang="ts">
  interface TimelineEvent {
    id: string;
    date: Date;
    title: string;
    description: string;
    type: 'email' | 'document' | 'meeting' | 'deadline' | 'action';
    evidence?: string[];
  }

  const mockEvents: TimelineEvent[] = [
    {
      id: '1',
      date: new Date('2024-03-15'),
      title: 'Initial Accommodation Request',
      description: 'Submitted formal request for ADA accommodation to HR department',
      type: 'email',
      evidence: ['accommodation_request.pdf']
    },
    {
      id: '2',
      date: new Date('2024-03-20'),
      title: 'HR Response - Request for Medical Documentation',
      description: 'HR requested additional medical documentation to support accommodation request',
      type: 'email',
      evidence: ['hr_response_1.pdf']
    },
    {
      id: '3',
      date: new Date('2024-04-02'),
      title: 'Medical Documentation Submitted',
      description: 'Provided required medical documentation from treating physician',
      type: 'document',
      evidence: ['medical_doc_1.pdf', 'physician_letter.pdf']
    },
    {
      id: '4',
      date: new Date('2024-04-15'),
      title: 'Follow-up Meeting Scheduled',
      description: 'HR scheduled meeting to discuss accommodation options',
      type: 'meeting',
      evidence: ['meeting_invite.eml']
    },
    {
      id: '5',
      date: new Date('2024-04-25'),
      title: 'Response Deadline',
      description: 'Deadline for HR to provide response on accommodation request',
      type: 'deadline',
      evidence: []
    }
  ];

  function getTypeIcon(type: string): string {
    const icons = {
      'email': '<path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline>',
      'document': '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14,2 14,8 20,8"></polyline>',
      'meeting': '<path d="M17 2.5a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1h-5l-5 5v-5H3a1 1 0 0 1-1-1v-10a1 1 0 0 1 1-1h14z"></path>',
      'deadline': '<circle cx="12" cy="12" r="10"></circle><polyline points="12,6 12,12 16,14"></polyline>',
      'action': '<circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1 1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>'
    };
    return icons[type] || icons['action'];
  }

  function getTypeColor(type: string): string {
    const colors = {
      'email': '#3b82f6',
      'document': '#10b981',
      'meeting': '#f59e0b',
      'deadline': '#ef4444',
      'action': '#8b5cf6'
    };
    return colors[type] || colors['action'];
  }

  function formatDate(date: Date): string {
    return date.toLocaleDateString('en-US', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    });
  }

  function isUpcoming(date: Date): boolean {
    return date > new Date();
  }

  function addNewEvent() {
    // Placeholder for adding new events
    alert('Feature coming soon: Add new timeline event');
  }
</script>

<div class="timeline-view">
  <div class="timeline-header">
    <div class="header-content">
      <h2>Case Timeline</h2>
      <p class="subtitle">Chronological view of your legal case events and evidence</p>
    </div>
    <button class="add-btn" on:click={addNewEvent}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <line x1="12" y1="5" x2="12" y2="19"></line>
        <line x1="5" y1="12" x2="19" y2="12"></line>
      </svg>
      Add Event
    </button>
  </div>

  <div class="timeline-container">
    <div class="timeline">
      {#each mockEvents as event, index (event.id)}
        <div class="timeline-item" class:upcoming={isUpcoming(event.date)}>
          <div class="timeline-marker">
            <div class="marker-icon" style="background-color: {getTypeColor(event.type)}">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">
                {@html getTypeIcon(event.type)}
              </svg>
            </div>
            {#if index < mockEvents.length - 1}
              <div class="timeline-line"></div>
            {/if}
          </div>

          <div class="timeline-content">
            <div class="event-card">
              <div class="event-header">
                <h3>{event.title}</h3>
                <div class="event-meta">
                  <span class="event-date">{formatDate(event.date)}</span>
                  <span class="event-type" style="color: {getTypeColor(event.type)}">
                    {event.type}
                  </span>
                </div>
              </div>
              
              <p class="event-description">{event.description}</p>
              
              {#if event.evidence && event.evidence.length > 0}
                <div class="evidence-list">
                  <h4>Related Evidence:</h4>
                  <ul>
                    {#each event.evidence as evidence}
                      <li>
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                          <polyline points="14,2 14,8 20,8"></polyline>
                        </svg>
                        {evidence}
                      </li>
                    {/each}
                  </ul>
                </div>
              {/if}
            </div>
          </div>
        </div>
      {/each}
    </div>
  </div>

  <div class="timeline-stats">
    <div class="stat-card">
      <div class="stat-number">{mockEvents.length}</div>
      <div class="stat-label">Total Events</div>
    </div>
    <div class="stat-card">
      <div class="stat-number">{mockEvents.filter(e => e.type === 'email').length}</div>
      <div class="stat-label">Communications</div>
    </div>
    <div class="stat-card">
      <div class="stat-number">{mockEvents.filter(e => e.type === 'document').length}</div>
      <div class="stat-label">Documents</div>
    </div>
    <div class="stat-card">
      <div class="stat-number">{mockEvents.filter(e => isUpcoming(e.date)).length}</div>
      <div class="stat-label">Upcoming</div>
    </div>
  </div>
</div>

<style>
  .timeline-view {
    height: 100%;
    display: flex;
    flex-direction: column;
    background: #f9fafb;
  }

  .timeline-header {
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

  .add-btn {
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

  .add-btn:hover {
    background: #2563eb;
  }

  .timeline-container {
    flex: 1;
    overflow-y: auto;
    padding: 2rem;
  }

  .timeline {
    max-width: 800px;
    margin: 0 auto;
  }

  .timeline-item {
    display: flex;
    gap: 1.5rem;
    margin-bottom: 2rem;
  }

  .timeline-item.upcoming .event-card {
    border-left: 4px solid #f59e0b;
    background: #fffbeb;
  }

  .timeline-marker {
    display: flex;
    flex-direction: column;
    align-items: center;
    flex-shrink: 0;
  }

  .marker-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    margin-bottom: 1rem;
  }

  .timeline-line {
    width: 2px;
    flex: 1;
    background: #e5e7eb;
    min-height: 60px;
  }

  .timeline-content {
    flex: 1;
  }

  .event-card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .event-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1rem;
  }

  .event-header h3 {
    font-size: 1.125rem;
    font-weight: 600;
    color: #1f2937;
    margin: 0;
    flex: 1;
  }

  .event-meta {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 0.25rem;
  }

  .event-date {
    font-size: 0.875rem;
    font-weight: 500;
    color: #374151;
  }

  .event-type {
    font-size: 0.75rem;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .event-description {
    color: #4b5563;
    line-height: 1.6;
    margin: 0 0 1rem 0;
  }

  .evidence-list {
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid #f3f4f6;
  }

  .evidence-list h4 {
    font-size: 0.875rem;
    font-weight: 600;
    color: #374151;
    margin: 0 0 0.5rem 0;
  }

  .evidence-list ul {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .evidence-list li {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.25rem 0;
    font-size: 0.875rem;
    color: #6b7280;
  }

  .evidence-list svg {
    color: #9ca3af;
  }

  .timeline-stats {
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
    .timeline-header {
      flex-direction: column;
      gap: 1rem;
      align-items: stretch;
    }

    .timeline-container {
      padding: 1rem;
    }

    .timeline-item {
      gap: 1rem;
    }

    .event-header {
      flex-direction: column;
      gap: 0.5rem;
    }

    .event-meta {
      align-items: flex-start;
    }

    .timeline-stats {
      flex-wrap: wrap;
      gap: 0.75rem;
    }

    .stat-card {
      flex: 1;
      min-width: calc(50% - 0.375rem);
    }
  }
</style>