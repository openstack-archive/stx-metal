# -*- encoding: utf-8 -*-
#
# Copyright © 2012 New Dream Network, LLC (DreamHost)
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
#
# Copyright (c) 2018 Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
import pecan
from pecan import rest
from wsme import types as wtypes
import wsmeext.pecan as wsme_pecan

from inventory.api.controllers import v1
from inventory.api.controllers.v1 import base
from inventory.api.controllers.v1 import link

ID_VERSION = 'v1'


def expose(*args, **kwargs):
    """Ensure that only JSON, and not XML, is supported."""
    if 'rest_content_types' not in kwargs:
        kwargs['rest_content_types'] = ('json',)
    return wsme_pecan.wsexpose(*args, **kwargs)


class Version(base.APIBase):
    """An API version representation.

    This class represents an API version, including the minimum and
    maximum minor versions that are supported within the major version.
    """

    id = wtypes.text
    """The ID of the (major) version, also acts as the release number"""

    links = [link.Link]
    """A Link that point to a specific version of the API"""

    @classmethod
    def convert(cls, vid):
        version = Version()
        version.id = vid
        version.links = [link.Link.make_link('self', pecan.request.host_url,
                                             vid, '', bookmark=True)]
        return version


class Root(base.APIBase):

    name = wtypes.text
    """The name of the API"""

    description = wtypes.text
    """Some information about this API"""

    versions = [Version]
    """Links to all the versions available in this API"""

    default_version = Version
    """A link to the default version of the API"""

    @staticmethod
    def convert():
        root = Root()
        root.name = "Inventory API"
        root.description = ("Inventory is an OpenStack project which "
                            "provides REST API services for "
                            "system configuration.")
        root.default_version = Version.convert(ID_VERSION)
        root.versions = [root.default_version]
        return root


class RootController(rest.RestController):

    _versions = [ID_VERSION]
    """All supported API versions"""

    _default_version = ID_VERSION
    """The default API version"""

    v1 = v1.Controller()

    @expose(Root)
    def get(self):
        # NOTE: The reason why convert() it's being called for every
        #       request is because we need to get the host url from
        #       the request object to make the links.
        return Root.convert()

    @pecan.expose()
    def _route(self, args, request=None):
        """Overrides the default routing behavior.

        It redirects the request to the default version of the Inventory API
        if the version number is not specified in the url.
        """

        if args[0] and args[0] not in self._versions:
            args = [self._default_version] + args
        return super(RootController, self)._route(args, request)
