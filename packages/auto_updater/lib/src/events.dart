enum UpdaterEvent {
  error,
  checkingForUpdate,
  updateAvailable,
  updateNotAvailable,
  updateDownloaded,
  beforeQuitForUpdate,

  // this event is only available on macOS
  userUpdateChoice,

  // these events are only available on Windows
  updateCancelled,
  updateSkipped,
  updateInstalled;

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
      case 'update-cancelled':
        return UpdaterEvent.updateCancelled;
      case 'update-skipped':
        return UpdaterEvent.updateSkipped;
      case 'update-installed':
        return UpdaterEvent.updateInstalled;
      default:
        throw ArgumentError('Invalid event name: $name');
    }
  }
}
