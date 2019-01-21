/*
 * Copyright (c) 2019 Wind River Systems, Inc.
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 */

 /**
  * @file
  * Wind River CGTS Platform Controller Maintenance
  * Access to Openstack Barbican via REST API Interface.
  *
  * This file implements the a set of mtcSecretApi utilities that maintenance
  * calls upon to get/read Barbican secrets from the Barbican Secret storage.
  *
  * The APIs exposed from this file are
  *
  *   mtcSecretApi_get_secret   - gets the Barbican secret, filtered by name
  *   mtcSecretApi_read_secret  - reads the payload for a specified secret uuid
  *
  *   Each utility is paired with a private handler.
  *
  *   mtcSecretApi_get_handler  - handles response for mtcSecretApi_get_secret
  *   mtcSecretApi_read_handler - handles response for mtcSecretApi_read_secret
  *
  * Warning: These calls cannot be nested.
  *
  **/

#ifdef  __AREA__
#undef  __AREA__
#endif
#define __AREA__ "pwd"

#include "nodeBase.h"       /* for ... Base Service Header             */
#include "nodeClass.h"      /* for ... maintenance class nodeLinkClass */
#include "nodeUtil.h"       /* for ... Utility Service Header          */
#include "jsonUtil.h"       /* for ... Json utilities                  */
#include "mtcSecretApi.h"   /* this .. module header                   */


/***********************************************************************
 *
 * Name       : mtcSecretApi_get_secret
 *
 * Purpose    : Issue an Barbican GET request for a specified secret name
 *              to obtain secret's reference.
 *
 */

int nodeLinkClass::mtcSecretApi_get_secret ( string & hostname )
{
    GET_NODE_PTR(hostname);
    return (mtcSecretApi_get_secret( node_ptr ));
}

int nodeLinkClass::mtcSecretApi_get_secret ( struct nodeLinkClass::node * node_ptr )
{
    int rc    = PASS ;

    CHK_NODE_PTR(node_ptr);
    rc = mtcHttpUtil_event_init ( &node_ptr->secretEvent,
                                   node_ptr->hostname,
                                   "mtcSecretApi_get_secret",
                                   hostUtil_getServiceIp  (SERVICE_SECRET),
                                   hostUtil_getServicePort(SERVICE_SECRET));
    if ( rc )
    {
        elog ("%s failed to allocate libEvent memory (%d)\n", node_ptr->hostname.c_str(), rc );
        return (rc);
    }

    node_ptr->secretEvent.token.url = MTC_SECRET_LABEL;
    node_ptr->secretEvent.token.url.append(MTC_SECRET_NAME);
    node_ptr->secretEvent.token.url.append(node_ptr->uuid);
    node_ptr->secretEvent.token.url.append(MTC_SECRET_BATCH);
    node_ptr->secretEvent.token.url.append(MTC_SECRET_BATCH_MAX);

    node_ptr->secretEvent.hostname    = node_ptr->hostname;
    node_ptr->secretEvent.request     = BARBICAN_GET_SECRET;
    node_ptr->secretEvent.operation   = "get secret reference";
    node_ptr->secretEvent.uuid        = node_ptr->uuid;
    node_ptr->secretEvent.blocking    = true;

    dlog ("Path:%s\n", node_ptr->secretEvent.token.url.c_str() );

    return ( mtcHttpUtil_api_request ( node_ptr->secretEvent ) ) ;
}

/* ******************************************************************
 *
 * Name:       mtcSecretApi_read_secret
 *
 * Purpose:    Issue an Barbican GET request for a specified secret uuid
 *             to read secret's payload, ie password itself.
 *
 *********************************************************************/

int nodeLinkClass::mtcSecretApi_read_secret ( string & hostname )
{
    GET_NODE_PTR(hostname);
    return (mtcSecretApi_read_secret( node_ptr ));
}

int nodeLinkClass::mtcSecretApi_read_secret ( struct nodeLinkClass::node * node_ptr )
{
    int rc = PASS ;

    CHK_NODE_PTR(node_ptr);
    rc = mtcHttpUtil_event_init ( &node_ptr->secretEvent,
                                   node_ptr->hostname,
                                   "mtcSecretApi_read_secret",
                                   hostUtil_getServiceIp  (SERVICE_SECRET),
                                   hostUtil_getServicePort(SERVICE_SECRET));
    if ( rc )
    {
        elog ("%s failed to allocate libEvent memory (%d)\n", node_ptr->hostname.c_str(), rc );
        return (rc);
    }

    node_ptr->secretEvent.token.url = MTC_SECRET_LABEL;
    node_ptr->secretEvent.token.url.append("/");
    node_ptr->secretEvent.token.url.append(node_ptr->bm_pw_ref);
    node_ptr->secretEvent.token.url.append("/");
    node_ptr->secretEvent.token.url.append(MTC_SECRET_PAYLOAD);

    /* Set the host context */
    node_ptr->secretEvent.request     = BARBICAN_READ_SECRET ;
    node_ptr->secretEvent.operation   = "get secret payload";
    node_ptr->secretEvent.uuid        = node_ptr->uuid;
    node_ptr->secretEvent.information = node_ptr->bm_pw_ref ;
    node_ptr->secretEvent.blocking    = true ;

    dlog ("Path:%s\n", node_ptr->secretEvent.token.url.c_str() );

    return ( mtcHttpUtil_api_request ( node_ptr->secretEvent ) ) ;
}

/*****************************************************************************/
/********************        H A N D L E R S          ************************/
/*****************************************************************************/

/* The handles the Barbican get  secrets request's response */
void nodeLinkClass::mtcSecretApi_get_handler ( struct evhttp_request *req, void *arg )
{
    int rc = PASS ;

    /* Declare and clean the json info object string containers */
    jsonUtil_secret_type json_info ;

    /* Find the host this handler instance is being run against
     * and get its event base - secretEvent.base:wq */
    nodeLinkClass * obj_ptr = get_mtcInv_ptr () ;
    nodeLinkClass::node * node_ptr =
        obj_ptr->getEventBaseNode ( BARBICAN_GET_SECRET, (struct event_base *)arg ) ;

    if ( node_ptr == NULL )
    {
        slog ("node lookup failed - secret event (%p)\n", arg);
        goto _get_handler_done ;
    }

    else if ( node_ptr->secretEvent.hostname.empty() )
    {
        elog ("don't know what hostname to look for - secret event\n");
        node_ptr->secretEvent.status = FAIL_UNKNOWN_HOSTNAME ;
        goto _get_handler_done ;
    }

    if ( ! req )
    {
        elog ("%s request timeout (%s)\n",
                  node_ptr->secretEvent.hostname.c_str(),
                  node_ptr->secretEvent.entity_path.c_str() );

        node_ptr->secretEvent.status = FAIL_TIMEOUT ;
        goto _get_handler_done ;
    }

    /* Check the HTTP Status Code */
    node_ptr->secretEvent.status = mtcHttpUtil_status ( node_ptr->secretEvent ) ;
    if ( node_ptr->secretEvent.status != PASS )
    {
        elog ("%s request failed (%d)\n",
                  node_ptr->secretEvent.hostname.c_str(),
                  node_ptr->secretEvent.status );
        goto _get_handler_done ;
    }

    if ( mtcHttpUtil_get_response ( node_ptr->secretEvent ) != PASS )
    {
        elog ("%s secret server may be down\n",
               node_ptr->secretEvent.hostname.c_str() );
        goto _get_handler_done ;
    }

    /* Parse through the response and fill in json_info */
    rc = jsonUtil_secret_load ( node_ptr->secretEvent.uuid,
                                (char*)node_ptr->secretEvent.response.data(),
                                json_info );
    if ( rc != PASS )
    {
       elog ("%s failed to parse secret response (%s)\n",
             node_ptr->secretEvent.hostname.c_str(),
             node_ptr->secretEvent.response.c_str() );
       node_ptr->secretEvent.status = FAIL_JSON_PARSE ;
    }
    else
    {
       size_t pos = json_info.secret_ref.find_last_of( '/' );
       node_ptr->bm_pw_ref = json_info.secret_ref.substr( pos+1 );
    }

    jlog ("%s Address : %s\n", node_ptr->secretEvent.hostname.c_str(),
                               node_ptr->secretEvent.address.c_str());
    jlog ("%s Payload : %s\n", node_ptr->secretEvent.hostname.c_str(),
                               node_ptr->secretEvent.payload.c_str());
    jlog ("%s Response: %s\n", node_ptr->secretEvent.entity_path.c_str(),
                               node_ptr->secretEvent.response.c_str());

_get_handler_done:

    mtcHttpUtil_log_event ( node_ptr->secretEvent );

    /* This is needed to get out of the loop */
    event_base_loopbreak((struct event_base *)arg);
}


/* The handles the Inventory Query request's response
 * Should only be called for the active controller */
void nodeLinkClass::mtcSecretApi_read_handler ( struct evhttp_request *req, void *arg )
{
    /* Find the host this handler instance is being run against
     * and get its event base - secretEvent.base */
    nodeLinkClass * obj_ptr = get_mtcInv_ptr () ;
    nodeLinkClass::node * node_ptr =
    obj_ptr->getEventBaseNode ( BARBICAN_READ_SECRET, (struct event_base *)arg ) ;

    if ( node_ptr == NULL )
    {
        slog ("node lookup failed - secret event (%p)\n", arg );
        goto _read_handler_done ;
    }

    else if ( node_ptr->secretEvent.hostname.empty() )
    {
        elog ("don't know what hostname to look for\n" );
        node_ptr->secretEvent.status = FAIL_UNKNOWN_HOSTNAME ;
        goto _read_handler_done ;
    }

    else if ( ! req )
    {
        elog ("%s request timeout (%d)\n",
                  node_ptr->secretEvent.hostname.c_str(),
                  node_ptr->secretEvent.timeout );

        node_ptr->secretEvent.status = FAIL_TIMEOUT ;
        goto _read_handler_done ;
    }

    /* Check the HTTP Status Code */
    node_ptr->secretEvent.status = mtcHttpUtil_status ( node_ptr->secretEvent ) ;
    if ( node_ptr->secretEvent.status == HTTP_NOTFOUND )
    {
        dlog ("%s secret not found (%d)\n",
                  node_ptr->hostname.c_str(),
                  node_ptr->secretEvent.status );

        node_ptr->bm_pw = NONE;

        goto _read_handler_done ;
    }
    else if ( node_ptr->secretEvent.status != PASS )
    {
        elog ("%s request failed (%d)\n",
                  node_ptr->hostname.c_str(),
                  node_ptr->secretEvent.status);

        goto _read_handler_done ;
    }

    if ( mtcHttpUtil_get_response ( node_ptr->secretEvent ) != PASS )
        goto _read_handler_done ;

    node_ptr->bm_pw = node_ptr->secretEvent.response;

    jlog ("%s Address : %s\n", node_ptr->secretEvent.hostname.c_str(),
                               node_ptr->secretEvent.address.c_str());
    jlog ("%s Payload : %s\n", node_ptr->secretEvent.hostname.c_str(),
                               node_ptr->secretEvent.payload.c_str());
    jlog ("%s Response: %s\n", node_ptr->secretEvent.hostname.c_str(),
                               node_ptr->secretEvent.response.c_str());

_read_handler_done:

    mtcHttpUtil_log_event ( node_ptr->secretEvent );

    /* This is needed to get out of the loop */
    event_base_loopbreak((struct event_base *)arg);
}

/* The Inventory 'Qry' request handler wrapper abstracted from nodeLinkClass */
void mtcSecretApi_get_Handler ( struct evhttp_request *req, void *arg )
{
    nodeLinkClass * node_ptr = get_mtcInv_ptr () ;
    node_ptr->mtcSecretApi_get_handler ( req , arg );
}

/* The Inventory 'Get' request handler wrapper abstracted from nodeLinkClass */
void mtcSecretApi_read_Handler ( struct evhttp_request *req, void *arg )
{
    nodeLinkClass * node_ptr = get_mtcInv_ptr () ;
    node_ptr->mtcSecretApi_read_handler ( req , arg );
}
