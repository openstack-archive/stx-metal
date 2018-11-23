# coding=utf-8
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

"""Central place for handling Keystone authorization and service lookup."""

from keystoneauth1 import exceptions as kaexception
from keystoneauth1 import loading as kaloading
from keystoneauth1 import service_token
from keystoneauth1 import token_endpoint
from oslo_config import cfg
from oslo_log import log
import six

from inventory.common import exception
# from inventory.conf import CONF

CONF = cfg.CONF


LOG = log.getLogger(__name__)


def ks_exceptions(f):
    """Wraps keystoneclient functions and centralizes exception handling."""
    @six.wraps(f)
    def wrapper(*args, **kwargs):
        try:
            return f(*args, **kwargs)
        except kaexception.EndpointNotFound:
            service_type = kwargs.get('service_type', 'inventory')
            endpoint_type = kwargs.get('endpoint_type', 'internal')
            raise exception.CatalogNotFound(
                service_type=service_type, endpoint_type=endpoint_type)
        except (kaexception.Unauthorized, kaexception.AuthorizationFailure):
            raise exception.KeystoneUnauthorized()
        except (kaexception.NoMatchingPlugin,
                kaexception.MissingRequiredOptions) as e:
            raise exception.ConfigInvalid(six.text_type(e))
        except Exception as e:
            LOG.exception('Keystone request failed: %(msg)s',
                          {'msg': six.text_type(e)})
            raise exception.KeystoneFailure(six.text_type(e))
    return wrapper


@ks_exceptions
def get_session(group, **session_kwargs):
    """Loads session object from options in a configuration file section.

    The session_kwargs will be passed directly to keystoneauth1 Session
    and will override the values loaded from config.
    Consult keystoneauth1 docs for available options.

    :param group: name of the config section to load session options from

    """
    return kaloading.load_session_from_conf_options(
        CONF, group, **session_kwargs)


@ks_exceptions
def get_auth(group, **auth_kwargs):
    """Loads auth plugin from options in a configuration file section.

    The auth_kwargs will be passed directly to keystoneauth1 auth plugin
    and will override the values loaded from config.
    Note that the accepted kwargs will depend on auth plugin type as defined
    by [group]auth_type option.
    Consult keystoneauth1 docs for available auth plugins and their options.

    :param group: name of the config section to load auth plugin options from

    """
    try:
        auth = kaloading.load_auth_from_conf_options(CONF, group,
                                                     **auth_kwargs)
    except kaexception.MissingRequiredOptions:
        LOG.error('Failed to load auth plugin from group %s', group)
        raise
    return auth


@ks_exceptions
def get_adapter(group, **adapter_kwargs):
    """Loads adapter from options in a configuration file section.

    The adapter_kwargs will be passed directly to keystoneauth1 Adapter
    and will override the values loaded from config.
    Consult keystoneauth1 docs for available adapter options.

    :param group: name of the config section to load adapter options from

    """
    return kaloading.load_adapter_from_conf_options(CONF, group,
                                                    **adapter_kwargs)


def get_service_auth(context, endpoint, service_auth):
    """Create auth plugin wrapping both user and service auth.

    When properly configured and using auth_token middleware,
    requests with valid service auth will not fail
    if the user token is expired.

    Ideally we would use the plugin provided by auth_token middleware
    however this plugin isn't serialized yet.
    """
    # TODO(pas-ha) use auth plugin from context when it is available
    user_auth = token_endpoint.Token(endpoint, context.auth_token)
    return service_token.ServiceTokenAuthWrapper(user_auth=user_auth,
                                                 service_auth=service_auth)
