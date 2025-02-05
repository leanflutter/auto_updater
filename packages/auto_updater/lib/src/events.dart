enum UpdaterEvent {
  error,
  checkingForUpdate,
  updateAvailable,
  updateNotAvailable,
  updateDownloaded,
  beforeQuitForUpdate,
  userUpdateChoice;

  static UpdaterEvent fromString(String name) {
    switch (name) {
      case 'error':
        return UpdaterEvent.error;
      case 'checking-for-update':
        return UpdaterEvent.checkingForUpdate;
      case 'update-available':
        return UpdaterEvent.updateAvailable;
      case 'update-not-available':
        return UpdaterEvent.updateNotAvailable;
      case 'update-downloaded':
        return UpdaterEvent.updateDownloaded;
      case 'before-quit-for-update':
        return UpdaterEvent.beforeQuitForUpdate;
      case 'user-update-choice':
        return UpdaterEvent.userUpdateChoice;
      default:
        throw ArgumentError('Invalid event name: $name');
    }
  }
}
