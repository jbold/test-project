<script>
  import { user, getDownloadLink } from '$lib/auth.js';
  import { onMount } from 'svelte';

  let currentUser = null;
  let downloadInfo = null;
  let loading = false;
  let error = '';

  user.subscribe(value => {
    currentUser = value;
  });

  onMount(() => {
    if (currentUser) {
      handleGetDownloadLink();
    }
  });

  async function handleGetDownloadLink() {
    loading = true;
    error = '';

    try {
      downloadInfo = await getDownloadLink();
    } catch (err) {
      error = err.message;
    } finally {
      loading = false;
    }
  }

  function downloadApp() {
    if (downloadInfo) {
      // In a real implementation, this would download the actual app file
      alert('Download would start here. This is a demo implementation.');
    }
  }
</script>

<svelte:head>
  <title>Download - Legal Toolkit</title>
</svelte:head>

<div class="download-page">
  <h1>Download Legal Toolkit</h1>

  {#if currentUser}
    {#if loading}
      <div class="loading">
        <p>Preparing download...</p>
      </div>
    {:else if error}
      <div class="error-message">
        <h2>Download Not Available</h2>
        <p>{error}</p>
        {#if error.includes('subscription')}
          <p>Please complete your payment to access the desktop application.</p>
          <a href="/register" class="btn btn-primary">Subscribe Now</a>
        {/if}
      </div>
    {:else if downloadInfo}
      <div class="download-ready">
        <h2>Your Download is Ready!</h2>
        <p>Click the button below to download the Legal Toolkit desktop application.</p>
        
        <div class="download-info">
          <p><strong>Download expires:</strong> {new Date(downloadInfo.expires_at).toLocaleString()}</p>
          <p><strong>File size:</strong> ~125 MB</p>
          <p><strong>Version:</strong> 1.0.0</p>
        </div>

        <button on:click={downloadApp} class="btn btn-primary btn-large">
          Download Desktop App
        </button>

        <div class="system-requirements">
          <h3>System Requirements</h3>
          <div class="requirements-grid">
            <div class="requirement">
              <h4>Windows</h4>
              <ul>
                <li>Windows 10 or later</li>
                <li>4GB RAM minimum</li>
                <li>500MB free disk space</li>
              </ul>
            </div>
            <div class="requirement">
              <h4>macOS</h4>
              <ul>
                <li>macOS 10.15 or later</li>
                <li>4GB RAM minimum</li>
                <li>500MB free disk space</li>
              </ul>
            </div>
            <div class="requirement">
              <h4>Linux</h4>
              <ul>
                <li>Ubuntu 18.04+ or equivalent</li>
                <li>4GB RAM minimum</li>
                <li>500MB free disk space</li>
              </ul>
            </div>
          </div>
        </div>

        <div class="installation-help">
          <h3>Installation Help</h3>
          <p>Having trouble installing? Check out our <a href="/help">installation guide</a> or <a href="/contact">contact support</a>.</p>
        </div>
      </div>
    {/if}
  {:else}
    <div class="login-required">
      <h2>Login Required</h2>
      <p>You must be logged in to download the Legal Toolkit desktop application.</p>
      <a href="/login" class="btn btn-primary">Login</a>
    </div>
  {/if}
</div>

<style>
  .download-page {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem;
  }

  .download-page h1 {
    color: #2c3e50;
    text-align: center;
    margin-bottom: 2rem;
  }

  .loading {
    text-align: center;
    padding: 2rem;
  }

  .error-message {
    background: #fee;
    color: #c33;
    padding: 2rem;
    border-radius: 8px;
    text-align: center;
    border: 1px solid #fcc;
  }

  .error-message h2 {
    margin-bottom: 1rem;
  }

  .download-ready {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
  }

  .download-ready h2 {
    color: #667eea;
    margin-bottom: 1rem;
  }

  .download-info {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 6px;
    margin: 1rem 0;
    text-align: left;
  }

  .download-info p {
    margin: 0.5rem 0;
    color: #666;
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
    font-size: 1rem;
  }

  .btn-primary {
    background-color: #667eea;
    color: white;
  }

  .btn-primary:hover {
    background-color: #5a6fd8;
  }

  .btn-large {
    padding: 1rem 2rem;
    font-size: 1.2rem;
    margin: 1rem 0;
  }

  .system-requirements {
    margin-top: 2rem;
    text-align: left;
  }

  .system-requirements h3 {
    color: #2c3e50;
    margin-bottom: 1rem;
  }

  .requirements-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
  }

  .requirement {
    background: #f8f9fa;
    padding: 1rem;
    border-radius: 6px;
  }

  .requirement h4 {
    color: #667eea;
    margin-bottom: 0.5rem;
  }

  .requirement ul {
    margin: 0;
    padding-left: 1rem;
  }

  .requirement li {
    margin: 0.25rem 0;
    color: #666;
  }

  .installation-help {
    margin-top: 2rem;
    text-align: left;
  }

  .installation-help h3 {
    color: #2c3e50;
    margin-bottom: 1rem;
  }

  .installation-help a {
    color: #667eea;
    text-decoration: none;
  }

  .installation-help a:hover {
    text-decoration: underline;
  }

  .login-required {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    text-align: center;
  }

  .login-required h2 {
    color: #667eea;
    margin-bottom: 1rem;
  }
</style>