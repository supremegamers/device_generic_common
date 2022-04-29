/*
 * Copyright (C) 2013 The Android-x86 Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#ifndef _BDROID_BUILDCFG_H
#define _BDROID_BUILDCFG_H

// At present either USB or UART is supported
#define BLUETOOTH_HCI_USE_USB          TRUE
// Bluetooth Low Power Mode is supported on BT4.0
#define HCILP_INCLUDED                 FALSE
#define KERNEL_MISSING_CLOCK_BOOTTIME_ALARM TRUE

// Disable HFP on Tablet (0x00000040) / only enable HSP (0x00000020)
#define BTIF_HF_SERVICES 0x00000020

/* Default Bluetooth Class of Device/Service:
 * MAJOR_SERVICE:0x1A - Networking / Capturing / Object Transfer
 * MAJOR_CLASS:0x01 - Computer
 * MINOR_CLASS:0x14 - Palm sized PC/PDA
 */
#define BTA_DM_COD {0x1A, 0x01, 0x14}

/* Enable Interleave scan on Intel Controller */
#define BTA_HOST_INTERLEAVE_SEARCH    TRUE

/* Framework BT ON timeout is about 8s.
 * We can retry one time if internal bluedroid timeout is 3500ms.
 */
#define PRELOAD_START_TIMEOUT_MS 3500
#define PRELOAD_MAX_RETRY_ATTEMPTS 1

#endif
