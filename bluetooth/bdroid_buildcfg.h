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

// Turn off BLE_LOCAL_PRIVACY_ENABLED. Remote reconnect fails on
// often if this is enabled.
#define BLE_LOCAL_PRIVACY_ENABLED FALSE

/* minimum acceptable connection interval */
#define BTM_BLE_CONN_INT_MIN_LIMIT 0x0006  /*7.5ms=6*1.25*/

/*fix bt crash about init */
#define KERNEL_MISSING_CLOCK_BOOTTIME_ALARM TRUE

#define BTM_BLE_CONN_INT_MIN_DEF       6
#define BTM_BLE_CONN_INT_MAX_DEF       12
#define BTM_BLE_SCAN_SLOW_INT_1        64
#define BTM_BLE_SCAN_SLOW_WIN_1        16

#define BTA_SKIP_BLE_READ_REMOTE_FEAT  TRUE
#define BLE_DELAY_REQUEST_ENC          TRUE

#define BTA_AV_SINK_INCLUDED           TRUE

#endif
