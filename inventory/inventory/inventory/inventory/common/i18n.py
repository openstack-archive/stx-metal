#
# Copyright (c) 2018 Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

import oslo_i18n

_translators = oslo_i18n.TranslatorFactory(domain='inventory')

# The primary translation function using the well-known name "_"
_ = _translators.primary
