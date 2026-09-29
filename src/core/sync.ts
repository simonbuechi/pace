export type SyncState = 'offline' | 'syncing' | 'synced' | 'error';

export interface UserProfile {
  uid: string;
  email: string;
  displayName: string;
}

class SyncController {
  private user: UserProfile | null = null;
  private state: SyncState = 'offline';
  private listeners: Array<(state: SyncState, user: UserProfile | null) => void> = [];

  constructor() {
    // Check saved session
    try {
      const saved = localStorage.getItem('pace_cloud_user');
      if (saved) {
        this.user = JSON.parse(saved);
        this.state = 'synced';
      }
    } catch {
      // Offline
    }
  }

  getUser(): UserProfile | null {
    return this.user;
  }

  getState(): SyncState {
    return this.state;
  }

  subscribe(listener: (state: SyncState, user: UserProfile | null) => void): () => void {
    this.listeners.push(listener);
    listener(this.state, this.user);
    return () => {
      this.listeners = this.listeners.filter((l) => l !== listener);
    };
  }

  private notify(): void {
    this.listeners.forEach((l) => l(this.state, this.user));
  }

  async signInWithGoogle(): Promise<boolean> {
    this.state = 'syncing';
    this.notify();

    // Simulated authentic OAuth handshake
    await new Promise((resolve) => setTimeout(resolve, 800));

    this.user = {
      uid: 'user_pace_web_demo',
      email: 'alex.runner@gmail.com',
      displayName: 'Alex Runner',
    };
    this.state = 'synced';
    try {
      localStorage.setItem('pace_cloud_user', JSON.stringify(this.user));
    } catch {}
    this.notify();
    return true;
  }

  async signOut(): Promise<void> {
    this.state = 'syncing';
    this.notify();

    await new Promise((resolve) => setTimeout(resolve, 400));
    this.user = null;
    this.state = 'offline';
    try {
      localStorage.removeItem('pace_cloud_user');
    } catch {}
    this.notify();
  }

  async triggerSync(): Promise<void> {
    if (!this.user) {
      this.state = 'offline';
      this.notify();
      return;
    }
    this.state = 'syncing';
    this.notify();

    await new Promise((resolve) => setTimeout(resolve, 600));
    this.state = 'synced';
    this.notify();
  }
}

export const syncController = new SyncController();
