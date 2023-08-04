#include <errno.h>
#include <fstream>
#include <string>

#include <android-base/properties.h>
#include <android-base/logging.h>

#include "grub_boot_control_private.h"

namespace android {
namespace bootable {

static void findAndReplace(std::string& content, const std::string& findStr, const std::string& replaceStr) {
    // Find the position of the substring to replace
    size_t pos = content.find(findStr);
    while (pos != std::string::npos) {
        // Replace the substring
        content.replace(pos, findStr.length(), replaceStr);
        // Find next occurrence
        pos = content.find(findStr, pos + replaceStr.length());
    }
}

bool BootControlExt::SetGrubBootSlot(const char* new_suffix) {
    std::string filename = "/grub/android.cfg";
    std::string texts[] = { "kernel", "initrd", "androidboot.slot_suffix=" };

    std::string old_suffix = android::base::GetProperty("ro.boot.slot_suffix", "");
    if (old_suffix.empty()) {
        LOG(ERROR) << "Slot suffix property is not set";
        return false;
    }

    std::ifstream fileIn(filename);
    if (!fileIn) {
        LOG(ERROR) << "Error: Unable to open file '" << filename << "' for reading." << std::endl;
        return false;
    }

    // Read the entire content of the file into a string
    std::string content((std::istreambuf_iterator<char>(fileIn)), std::istreambuf_iterator<char>());

    for (const std::string &text : texts) {
        std::string findStr = text + old_suffix;
        std::string replaceStr = text + new_suffix;
        findAndReplace(content, findStr, replaceStr);
    }

    fileIn.close();
    // Write the modified content back to the file
    std::ofstream fileOut(filename);
    if (!fileOut) {
        LOG(ERROR) << "Error: Unable to open file '" << filename << "' for writing." << std::endl;
        return false;
    }
    fileOut << content;
    fileOut.close();

    return true;
}

}
}
