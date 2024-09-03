#ifndef FLUTTER_PLUGIN_XEMPI_PLUGIN_H_
#define FLUTTER_PLUGIN_XEMPI_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace xempi {

class XempiPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  XempiPlugin();

  virtual ~XempiPlugin();

  // Disallow copy and assign.
  XempiPlugin(const XempiPlugin&) = delete;
  XempiPlugin& operator=(const XempiPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace xempi

#endif  // FLUTTER_PLUGIN_XEMPI_PLUGIN_H_
