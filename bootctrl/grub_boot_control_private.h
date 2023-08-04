#pragma once

namespace android {
namespace bootable {
class BootControlExt {
  public:
    bool SetGrubBootSlot(const char* new_suffix);
};
}
}
