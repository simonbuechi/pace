class NotificationController {
  private isSupported(): boolean {
    return typeof window !== 'undefined' && 'Notification' in window;
  }

  async requestPermission(): Promise<boolean> {
    if (!this.isSupported()) return false;
    try {
      const res = await Notification.requestPermission();
      return res === 'granted';
    } catch {
      return false;
    }
  }

  isPermissionGranted(): boolean {
    if (!this.isSupported()) return false;
    return Notification.permission === 'granted';
  }

  show(title: string, options?: NotificationOptions): void {
    if (!this.isSupported() || !this.isPermissionGranted()) return;

    try {
      const n = new Notification(title, {
        icon: '/favicon.ico',
        badge: '/favicon.ico',
        ...options,
      });

      // Automatically close notification after 6 seconds
      setTimeout(() => n.close(), 6000);
    } catch (e) {
      console.warn('Notification error:', e);
    }
  }
}

export const notificationController = new NotificationController();
