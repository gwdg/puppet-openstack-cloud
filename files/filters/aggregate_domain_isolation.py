# Copyright (c) 2011-2013 OpenStack Foundation
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

from oslo_log import log as logging

from nova.scheduler import filters
from nova.scheduler.filters import utils

import keystoneauth1.identity.v3
import keystoneauth1.session as session
import keystoneclient.v3.client as keystoneclient_v3
import ConfigParser


LOG = logging.getLogger(__name__)


class AggregateDomainIsolation(filters.BaseHostFilter):
    """Isolate tenants in specific aggregates based on the domain id."""

    def __init__(self):
        novaconfig = ConfigParser.ConfigParser()
        novaconfig.read("/etc/nova/nova.conf")

        admin_auth_password     = novaconfig.get("keystone_authtoken","password")
        auth_url                = novaconfig.get("keystone_authtoken","auth_uri") + "/v3/"

        admin_auth_username     = "admin"
        admin_project_name      = "admin"
        admin_project_domain_id = "default"
        admin_user_domain_id    = "default"

        auth_v3 = keystoneauth1.identity.v3.Password(
                auth_url          = auth_url,
                username          = admin_auth_username,
                password          = admin_auth_password,
                project_name      = admin_project_name,
                project_domain_id = admin_project_domain_id,
                user_domain_id    = admin_user_domain_id )

        sess = session.Session(auth = auth_v3)

        self.keystone =  keystoneclient_v3.Client(session=sess)


    # Aggregate data and tenant do not change within a request
    run_filter_once_per_request = True


    def host_passes(self, host_state, spec_obj):
        """If a host is in an aggregate that has the metadata key
        "filter_domain_id" it can only create instances from that tenant(s).
        A host can be in different aggregates.

        If a host doesn't belong to an aggregate with the metadata key
        "filter_domain_id" it can create instances from all tenants.
        """
        project_id = spec_obj.project_id

        project_obj       = self.keystone.projects.get(project_id)
        domain_id = project_obj.domain_id

        metadata = utils.aggregate_metadata_get_by_host(host_state,
                                                        key="filter_domain_id")

        if metadata != {}:
            configured_domain_ids = metadata.get("filter_domain_id")
            if configured_domain_ids:
                if domain_id not in configured_domain_ids:
                    LOG.debug("%s fails domain id on aggregate", host_state)
                    return False
                LOG.debug("Host domain id %s matched", domain_id)
            else:
                LOG.debug("No domain id's defined on host. Host passes.")
        return True
