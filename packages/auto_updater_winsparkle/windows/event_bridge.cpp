#include <dart_native_api.h>

#include <atomic>

namespace {

using PostCObject = bool (*)(Dart_Port, Dart_CObject*);

std::atomic<Dart_Port> event_port{0};
std::atomic<PostCObject> post_c_object{nullptr};

void PostEvent(const char* event, const char* error = nullptr) {
  const auto port = event_port.load();
  const auto post = post_c_object.load();
  if (port == 0 || post == nullptr) {
    return;
  }
  Dart_CObject type{};
  type.type = Dart_CObject_kString;
  type.value.as_string = event;
  // A port from a previous Flutter isolate simply rejects the message.
  if (error == nullptr) {
    post(port, &type);
    return;
  }

  Dart_CObject details{};
  details.type = Dart_CObject_kString;
  details.value.as_string = error;
  Dart_CObject* values[] = {&type, &details};
  Dart_CObject message{};
  message.type = Dart_CObject_kArray;
  message.value.as_array.length = 2;
  message.value.as_array.values = values;
  post(port, &message);
}

}  // namespace

extern "C" {

__declspec(dllexport) void auto_updater_set_event_port(Dart_Port port,
                                                     PostCObject post) {
  post_c_object.store(post);
  event_port.store(port);
}

__declspec(dllexport) void auto_updater_on_error() { PostEvent("error"); }

__declspec(dllexport) void auto_updater_on_error_details(const char* message) {
  PostEvent("error", message);
}

__declspec(dllexport) void auto_updater_on_shutdown_request() {
  PostEvent("before-quit-for-update");
}

__declspec(dllexport) void auto_updater_on_did_find_update() {
  PostEvent("update-available");
}

__declspec(dllexport) void auto_updater_on_did_not_find_update() {
  PostEvent("update-not-available");
}

__declspec(dllexport) void auto_updater_on_update_cancelled() {
  PostEvent("updateCancelled");
}

__declspec(dllexport) void auto_updater_on_update_downloaded() {
  PostEvent("update-downloaded");
}

}  // extern "C"
