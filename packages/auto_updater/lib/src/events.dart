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
      case 'checkingForUpdate':
        return UpdaterEvent.checkingForUpdate;
      case 'update-available':
      case 'updateAvailable':
        return UpdaterEvent.updateAvailable;
      case 'update-not-available':
      case 'updateNotAvailable':
        return UpdaterEvent.updateNotAvailable;
      case 'update-downloaded':
      case 'updateDownloaded':
        return UpdaterEvent.updateDownloaded;
      case 'before-quit-for-update':
      case 'beforeQuitForUpdate':
        return UpdaterEvent.beforeQuitForUpdate;
      case 'user-update-choice':
      case 'userUpdateChoice':
        return UpdaterEvent.userUpdateChoice;
      case 'update-cancelled':
      case 'updateCancelled':
        return UpdaterEvent.updateCancelled;
      case 'update-skipped':
      case 'updateSkipped':
        return UpdaterEvent.updateSkipped;
      case 'update-installed':
      case 'updateInstalled':
        return UpdaterEvent.updateInstalled;
      case 'update-postponed':
      case 'updatePostponed':
        return UpdaterEvent.updatePostponed;
      case 'update-dismissed':
      case 'updateDismissed':
        return UpdaterEvent.updateDismissed;
      case 'user-run-installer':
      case 'userRunInstaller':
        return UpdaterEvent.userRunInstaller;
      default:
        throw ArgumentError('Invalid event name: $name');
    }
  }
}
