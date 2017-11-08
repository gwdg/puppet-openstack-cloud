import horizon
from openstack_dashboard.dashboards.project.volumes import panel as volumes_panel
from django.utils.translation import ugettext as _

volumes_rule = (('identity', "identity:show_volumes"),)
network_rule = (('identity', "identity:show_networks"),)
stacks_rule = (('identity', "identity:show_stacks"),)
projects_rule = (('identity', "identity:show_projects"),)
api_rule = (('identity', "identity:show_api"),)
all_rule = (('identity', "identity:show_all"),)


volumes_panel.Volumes.policy_rules = volumes_rule

project = horizon.get_dashboard("project")
project.get_panel("images").policy_rules = volumes_rule
project.get_panel('network_topology').policy_rules = network_rule
project.get_panel('networks').policy_rules = network_rule
project.get_panel('routers').policy_rules = network_rule
project.get_panel('stacks').policy_rules = stacks_rule
project.get_panel('stacks.resource_types').policy_rules = stacks_rule

horizon.get_dashboard('identity').get_panel('projects').policy_rules = projects_rule

horizon.get_dashboard('developer').policy_rules = all_rule


from openstack_dashboard.dashboards.project.access_and_security import tabs as aas_tabs
from openstack_dashboard import policy
class MyFloatingIPsTab(aas_tabs.FloatingIPsTab):
    def allowed(self, request):
        return super(MyFloatingIPsTab, self).allowed(request) and \
                policy.check(api_rule, request)

aas_tabs.AccessAndSecurityTabs.tabs = (aas_tabs.SecurityGroupsTab, aas_tabs.KeypairsTab, MyFloatingIPsTab, aas_tabs.APIAccessTab)
#project.get_panel('access_and_security').get_tab('api_access_tab').policy_rules = default_rule
