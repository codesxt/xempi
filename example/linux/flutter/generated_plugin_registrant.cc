//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <xempi/xempi_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) xempi_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "XempiPlugin");
  xempi_plugin_register_with_registrar(xempi_registrar);
}