#ifndef __INCLUDE_MTCSECRETAPI_H__
#define __INCLUDE_MTCSECRETAPI_H__

/*
 * Copyright (c) 2019 Wind River Systems, Inc.
*
* SPDX-License-Identifier: Apache-2.0
*
 */

 /**
  * @file
  * Wind River CGCS Platform - Maintenance - Openstack Barbican API Header
  */

/**
  * @addtogroup mtcSecretApi
  * @{
  *
  * This file implements the a set of mtcSecretApi utilities that maintenance
  * calls upon to get/read Barbican secrets from the Barbican Secret storage.
  *
  * The APIs exposed from this file are
  *
  *   mtcSecretApi_get_secret   - gets all the Barbican secrets, filtered by name
  *   mtcSecretApi_read_secret  - reads the payload for a specified secret
  *
  *   See nodeClass.h for these prototypes
  *
  *   Each utility is paired with a private handler.
  *
  *   mtcSecretApi_get_handler  - handles response for mtcSecretApi_get_secret
  *   mtcSecretApi_read_handler - handles response for mtcSecretApi_read_secret
  *
  * Warning: These calls cannot be nested.
  *
  **/

#include "mtcHttpUtil.h"    /* for mtcHttpUtil_libEvent_init
                                   mtcHttpUtil_api_request
                                   mtcHttpUtil_log_event */

#define MTC_SECRET_LABEL           "/v1/secrets"    /**< barbican secrets url label        */
#define MTC_SECRET_NAME            "?name="         /**< name of barbican secret prefix    */
#define MTC_SECRET_BATCH           "&limit="        /**< batch read limit specified prefix */
#define MTC_SECRET_BATCH_MAX       "1"              /**< maximum allowed batched read      */
#define MTC_SECRET_PAYLOAD         "payload"        /**< barbican secret payload label     */

/** Reads the Barbican secret, filtered by name.
  *
  * @param hostname - reference to a name string of the host.
  *
  * @return execution status
  *
  *- PASS - indicates successful send request
  *- FAIL_TIMEOUT - no response received in timeout period
  *- FAIL_JSON_PARSE - response json string did not parse properly
  *- HTTP status codes - any standard HTTP codes
  *
  *****************************************************************************/
int mtcSecretApi_get_secret ( string & hostname );

/** Loads the payload for a specified secret.
  *
  * @param hostname - reference to a name string of the host.
  *
  * @return execution status
  *
  *- PASS - indicates successful send request
  *- FAIL_TIMEOUT - no response received in timeout period
  *- FAIL_JSON_PARSE - response json string did not parse properly
  *- HTTP status codes - any standard HTTP codes
  *
  *****************************************************************************/
int mtcSecretApi_read_secret  ( string & hostname );

/** @} mtcSecretApi */

#endif /* __INCLUDE_MTCSECRETAPI_H__ */
