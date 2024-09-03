#include "include/xempi/xempi_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "xempi_plugin.h"

void XempiPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  xempi::XempiPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
