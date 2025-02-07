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
  updatePostponed,
  updateDismissed,
  updateCancelled,
  updateSkipped,
  updateInstalled,
  userRunInstaller;

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
      case 'update-postponed':
        return UpdaterEvent.updatePostponed;
      case 'update-dismissed':
        return UpdaterEvent.updateDismissed;
      case 'user-run-installer':
        return UpdaterEvent.userRunInstaller;
      default:
        throw ArgumentError('Invalid event name: $name');
    }
  }
}
