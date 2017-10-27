/*
 * Copyright (C) 2015-2017 The Android-x86 Open Source Project
 *
 * by Chih-Wei Huang <cwhuang@linux.org.tw>
 *
 * Licensed under the GNU General Public License Version 2 or later.
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.gnu.org/licenses/gpl.html
 *
 */

#define LOG_TAG "libnb"

#include <dlfcn.h>
#include <cutils/log.h>
#include <cutils/properties.h>
#include "nativebridge/native_bridge.h"

#define DBG 0
#if DBG
#define LOGV ALOGD
#else
#define LOGV ALOGV
#endif

namespace android {

static void *native_handle = nullptr;

static bool is_native_bridge_enabled()
{
    return property_get_bool("persist.sys.nativebridge", 0);
}

static NativeBridgeCallbacks *get_callbacks()
{
    static NativeBridgeCallbacks *callbacks = nullptr;

    if (!callbacks) {
        const char *libnb = "/system/lib"
#ifdef __LP64__
                "64"
#endif
                "/libhoudini.so";
        if (!native_handle) {
            native_handle = dlopen(libnb, RTLD_LAZY);
            if (!native_handle) {
                ALOGE("Unable to open %s", libnb);
                return nullptr;
            }
        }
        callbacks = reinterpret_cast<NativeBridgeCallbacks *>(dlsym(native_handle, "NativeBridgeItf"));
        ALOGI("Found %s version %u", libnb, callbacks ? callbacks->version : 0);
    }
    return callbacks;
}

// NativeBridgeCallbacks implementations
static bool native_bridge2_initialize(const NativeBridgeRuntimeCallbacks *art_cbs,
                                      const char *app_code_cache_dir,
                                      const char *isa)
{
    LOGV("enter native_bridge2_initialize %s %s", app_code_cache_dir, isa);
    if (is_native_bridge_enabled()) {
        if (NativeBridgeCallbacks *cb = get_callbacks()) {
            return cb->initialize(art_cbs, app_code_cache_dir, isa);
        }
        ALOGW("Native bridge is enabled but callbacks not found");
    } else {
        ALOGW("Native bridge is disabled");
    }
    return false;
}

static void *native_bridge2_loadLibrary(const char *libpath, int flag)
{
    LOGV("enter native_bridge2_loadLibrary %s", libpath);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->loadLibrary(libpath, flag) : nullptr;
}

static void *native_bridge2_getTrampoline(void *handle, const char *name,
                                          const char* shorty, uint32_t len)
{
    LOGV("enter native_bridge2_getTrampoline %s", name);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->getTrampoline(handle, name, shorty, len) : nullptr;
}

static bool native_bridge2_isSupported(const char *libpath)
{
    LOGV("enter native_bridge2_isSupported %s", libpath);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->isSupported(libpath) : false;
}

static const struct NativeBridgeRuntimeValues *native_bridge2_getAppEnv(const char *abi)
{
    LOGV("enter native_bridge2_getAppEnv %s", abi);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->getAppEnv(abi) : nullptr;
}

static bool native_bridge2_isCompatibleWith(uint32_t version)
{
    static uint32_t my_version = 0;
    LOGV("enter native_bridge2_isCompatibleWith %u", version);
    if (my_version == 0 && is_native_bridge_enabled()) {
        if (NativeBridgeCallbacks *cb = get_callbacks()) {
            my_version = cb->version;
        }
    }
    // We have to claim a valid version before loading the real callbacks,
    // otherwise native bridge will be disabled entirely
    return version <= (my_version ? my_version : 3);
}

static NativeBridgeSignalHandlerFn native_bridge2_getSignalHandler(int signal)
{
    LOGV("enter native_bridge2_getSignalHandler %d", signal);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->getSignalHandler(signal) : nullptr;
}

static int native_bridge3_unloadLibrary(void *handle)
{
    LOGV("enter native_bridge3_unloadLibrary %p", handle);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->unloadLibrary(handle) : -1;
}

static const char *native_bridge3_getError()
{
    LOGV("enter native_bridge3_getError");
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->getError() : "unknown";
}

static bool native_bridge3_isPathSupported(const char *path)
{
    LOGV("enter native_bridge3_isPathSupported %s", path);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb && cb->isPathSupported(path);
}

static bool native_bridge3_initAnonymousNamespace(const char *public_ns_sonames,
                                                  const char *anon_ns_library_path)
{
    LOGV("enter native_bridge3_initAnonymousNamespace %s, %s", public_ns_sonames, anon_ns_library_path);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb && cb->initAnonymousNamespace(public_ns_sonames, anon_ns_library_path);
}

static native_bridge_namespace_t *
native_bridge3_createNamespace(const char *name,
                               const char *ld_library_path,
                               const char *default_library_path,
                               uint64_t type,
                               const char *permitted_when_isolated_path,
                               native_bridge_namespace_t *parent_ns)
{
    LOGV("enter native_bridge3_createNamespace %s, %s, %s, %s", name, ld_library_path, default_library_path, permitted_when_isolated_path);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->createNamespace(name, ld_library_path, default_library_path, type, permitted_when_isolated_path, parent_ns) : nullptr;
}

static bool native_bridge3_linkNamespaces(native_bridge_namespace_t *from,
                                          native_bridge_namespace_t *to,
                                          const char *shared_libs_soname)
{
    LOGV("enter native_bridge3_linkNamespaces %s", shared_libs_soname);
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb && cb->linkNamespaces(from, to, shared_libs_soname);
}

static void *native_bridge3_loadLibraryExt(const char *libpath,
                                           int flag,
                                           native_bridge_namespace_t *ns)
{
    LOGV("enter native_bridge3_loadLibraryExt %s, %d, %p", libpath, flag, ns);
    NativeBridgeCallbacks *cb = get_callbacks();
    void *result = cb ? cb->loadLibraryExt(libpath, flag, ns) : nullptr;
//  void *result = cb ? cb->loadLibrary(libpath, flag) : nullptr;
    LOGV("native_bridge3_loadLibraryExt: %p", result);
    return result;
}

static native_bridge_namespace_t *native_bridge4_getVendorNamespace()
{
    LOGV("enter native_bridge4_getVendorNamespace");
    NativeBridgeCallbacks *cb = get_callbacks();
    return cb ? cb->getVendorNamespace() : nullptr;
}

static void __attribute__ ((destructor)) on_dlclose()
{
    if (native_handle) {
        dlclose(native_handle);
        native_handle = nullptr;
    }
}

extern "C" {

NativeBridgeCallbacks NativeBridgeItf = {
    // v1
    .version = 4,
    .initialize = native_bridge2_initialize,
    .loadLibrary = native_bridge2_loadLibrary,
    .getTrampoline = native_bridge2_getTrampoline,
    .isSupported = native_bridge2_isSupported,
    .getAppEnv = native_bridge2_getAppEnv,
    // v2
    .isCompatibleWith = native_bridge2_isCompatibleWith,
    .getSignalHandler = native_bridge2_getSignalHandler,
    // v3
    .unloadLibrary = native_bridge3_unloadLibrary,
    .getError = native_bridge3_getError,
    .isPathSupported = native_bridge3_isPathSupported,
    .initAnonymousNamespace = native_bridge3_initAnonymousNamespace,
    .createNamespace = native_bridge3_createNamespace,
    .linkNamespaces = native_bridge3_linkNamespaces,
    .loadLibraryExt = native_bridge3_loadLibraryExt,
    // v4
    .getVendorNamespace = native_bridge4_getVendorNamespace,
};

} // extern "C"
} // namespace android
