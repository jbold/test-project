<script lang="ts">
  import { onMount } from 'svelte';

  interface Message {
    id: string;
    content: string;
    sender: 'user' | 'ai';
    timestamp: Date;
    type?: 'text' | 'file' | 'timeline' | 'action';
  }

  let messages: Message[] = [
    {
      id: '1',
      content: 'Hello! I\'m your legal AI assistant. I can help you manage your case timeline, organize evidence, draft documents, and research legal precedents. What would you like to work on today?',
      sender: 'ai',
      timestamp: new Date(),
      type: 'text'
    }
  ];

  let newMessage = '';
  let chatContainer: HTMLElement;
  let isTyping = false;
  let fileInput: HTMLInputElement;

  // Mock AI responses for development
  const mockResponses = [
    "I've analyzed your request. Let me help you with that legal matter.",
    "Based on the evidence you've shared, I can see a clear pattern emerging in your case.",
    "I've added this information to your timeline and cross-referenced it with existing evidence.",
    "This document contains important dates. Would you like me to extract them and add to your case timeline?",
    "I found several relevant case precedents that support your position. Let me summarize the key points.",
    "I've generated a draft response based on your case details. Would you like me to refine any specific sections?"
  ];

  function addMessage(content: string, sender: 'user' | 'ai', type: 'text' | 'file' | 'timeline' | 'action' = 'text') {
    const message: Message = {
      id: Date.now().toString(),
      content,
      sender,
      timestamp: new Date(),
      type
    };
    messages = [...messages, message];
    scrollToBottom();
  }

  function scrollToBottom() {
    setTimeout(() => {
      if (chatContainer) {
        chatContainer.scrollTop = chatContainer.scrollHeight;
      }
    }, 100);
  }

  async function sendMessage() {
    if (!newMessage.trim()) return;

    const userMessage = newMessage.trim();
    newMessage = '';
    
    // Add user message
    addMessage(userMessage, 'user');

    // Show typing indicator
    isTyping = true;
    scrollToBottom();

    // Simulate AI response delay
    setTimeout(() => {
      isTyping = false;
      const randomResponse = mockResponses[Math.floor(Math.random() * mockResponses.length)];
      addMessage(randomResponse, 'ai');
    }, 1000 + Math.random() * 2000);
  }

  function handleKeyPress(event: KeyboardEvent) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      sendMessage();
    }
  }

  function handleFileUpload() {
    fileInput.click();
  }

  function handleFileSelected(event: Event) {
    const target = event.target as HTMLInputElement;
    const files = target.files;
    
    if (files && files.length > 0) {
      const file = files[0];
      addMessage(`📎 Uploaded: ${file.name}`, 'user', 'file');
      
      // Mock AI response for file upload
      setTimeout(() => {
        addMessage(`I've processed your file "${file.name}". I found several key dates and legal terms. Would you like me to add these to your case timeline?`, 'ai');
      }, 1500);
    }
  }

  function formatTime(date: Date): string {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  }

  onMount(() => {
    scrollToBottom();
  });
</script>

<div class="chat-interface">
  <div class="chat-header">
    <h2>Legal Assistant</h2>
    <div class="chat-actions">
      <button class="action-btn" on:click={handleFileUpload} title="Upload evidence" aria-label="Upload evidence">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
          <polyline points="7,10 12,15 17,10"></polyline>
          <line x1="12" y1="15" x2="12" y2="3"></line>
        </svg>
      </button>
    </div>
  </div>

  <div class="chat-container" bind:this={chatContainer}>
    <div class="messages">
      {#each messages as message (message.id)}
        <div class="message" class:user={message.sender === 'user'} class:ai={message.sender === 'ai'}>
          <div class="message-content">
            {#if message.sender === 'ai'}
              <div class="ai-avatar">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M12 2L2 7v10l10 5 10-5V7z"></path>
                  <circle cx="12" cy="13" r="4"></circle>
                </svg>
              </div>
            {/if}
            <div class="message-bubble" class:file={message.type === 'file'}>
              <p>{message.content}</p>
              <span class="message-time">{formatTime(message.timestamp)}</span>
            </div>
          </div>
        </div>
      {/each}

      {#if isTyping}
        <div class="message ai">
          <div class="message-content">
            <div class="ai-avatar">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M12 2L2 7v10l10 5 10-5V7z"></path>
                <circle cx="12" cy="13" r="4"></circle>
              </svg>
            </div>
            <div class="typing-indicator">
              <div class="typing-dots">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        </div>
      {/if}
    </div>
  </div>

  <div class="chat-input">
    <div class="input-container">
      <textarea
        bind:value={newMessage}
        on:keydown={handleKeyPress}
        placeholder="Ask about your case, upload evidence, or request document drafts..."
        rows="1"
        class="message-input"
      ></textarea>
      <button 
        class="send-btn" 
        on:click={sendMessage}
        disabled={!newMessage.trim()}
        title="Send message"
        aria-label="Send message"
      >
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <line x1="22" y1="2" x2="11" y2="13"></line>
          <polygon points="22,2 15,22 11,13 2,9"></polygon>
        </svg>
      </button>
    </div>
    <div class="input-hints">
      <span class="hint">💡 Try: "Show me my timeline" • "Upload evidence" • "Draft a response"</span>
    </div>
  </div>
</div>

<!-- Hidden file input -->
<input 
  type="file" 
  bind:this={fileInput}
  on:change={handleFileSelected}
  accept=".pdf,.doc,.docx,.png,.jpg,.jpeg,.txt,.eml"
  style="display: none;"
/>

<style>
  .chat-interface {
    height: 100%;
    display: flex;
    flex-direction: column;
    background: white;
  }

  .chat-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #e5e7eb;
    background: white;
  }

  .chat-header h2 {
    font-size: 1.125rem;
    font-weight: 600;
    color: #1f2937;
    margin: 0;
  }

  .chat-actions {
    display: flex;
    gap: 0.5rem;
  }

  .action-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    padding: 0;
    background: #f3f4f6;
    border: none;
    border-radius: 6px;
    color: #6b7280;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .action-btn:hover {
    background: #e5e7eb;
    color: #374151;
  }

  .chat-container {
    flex: 1;
    overflow-y: auto;
    padding: 1rem;
    background: #f9fafb;
  }

  .messages {
    max-width: 800px;
    margin: 0 auto;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .message {
    display: flex;
    width: 100%;
  }

  .message.user {
    justify-content: flex-end;
  }

  .message.ai {
    justify-content: flex-start;
  }

  .message-content {
    display: flex;
    align-items: flex-end;
    gap: 0.5rem;
    max-width: 70%;
  }

  .message.user .message-content {
    flex-direction: row-reverse;
  }

  .ai-avatar {
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

  .message-bubble {
    position: relative;
    padding: 0.75rem 1rem;
    border-radius: 12px;
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }

  .message.user .message-bubble {
    background: #3b82f6;
    color: white;
    border-bottom-right-radius: 4px;
  }

  .message.ai .message-bubble {
    background: white;
    color: #1f2937;
    border: 1px solid #e5e7eb;
    border-bottom-left-radius: 4px;
  }

  .message-bubble.file {
    background: #f0f9ff;
    border: 1px solid #bae6fd;
    color: #0c4a6e;
  }

  .message-bubble p {
    margin: 0;
    line-height: 1.5;
    word-wrap: break-word;
  }

  .message-time {
    display: block;
    font-size: 0.75rem;
    opacity: 0.7;
    margin-top: 0.25rem;
  }

  .typing-indicator {
    padding: 0.75rem 1rem;
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 12px;
    border-bottom-left-radius: 4px;
  }

  .typing-dots {
    display: flex;
    gap: 0.25rem;
  }

  .typing-dots span {
    width: 6px;
    height: 6px;
    background: #6b7280;
    border-radius: 50%;
    animation: typing 1.5s infinite ease-in-out;
  }

  .typing-dots span:nth-child(2) {
    animation-delay: 0.2s;
  }

  .typing-dots span:nth-child(3) {
    animation-delay: 0.4s;
  }

  @keyframes typing {
    0%, 60%, 100% {
      transform: translateY(0);
      opacity: 0.4;
    }
    30% {
      transform: translateY(-10px);
      opacity: 1;
    }
  }

  .chat-input {
    padding: 1rem 1.5rem;
    background: white;
    border-top: 1px solid #e5e7eb;
  }

  .input-container {
    display: flex;
    gap: 0.75rem;
    align-items: flex-end;
    max-width: 800px;
    margin: 0 auto;
  }

  .message-input {
    flex: 1;
    min-height: 44px;
    max-height: 120px;
    padding: 0.75rem 1rem;
    border: 1px solid #d1d5db;
    border-radius: 12px;
    font-size: 0.875rem;
    resize: none;
    font-family: inherit;
    line-height: 1.5;
    transition: border-color 0.2s ease;
  }

  .message-input:focus {
    outline: none;
    border-color: #3b82f6;
    box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  }

  .send-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 44px;
    height: 44px;
    padding: 0;
    background: #3b82f6;
    border: none;
    border-radius: 12px;
    color: white;
    cursor: pointer;
    transition: all 0.2s ease;
    flex-shrink: 0;
  }

  .send-btn:hover:not(:disabled) {
    background: #2563eb;
  }

  .send-btn:disabled {
    background: #d1d5db;
    cursor: not-allowed;
  }

  .input-hints {
    margin-top: 0.5rem;
    text-align: center;
  }

  .hint {
    font-size: 0.75rem;
    color: #6b7280;
  }

  @media (max-width: 768px) {
    .message-content {
      max-width: 85%;
    }
    
    .chat-container {
      padding: 0.75rem;
    }
    
    .chat-input {
      padding: 0.75rem;
    }
  }
</style>