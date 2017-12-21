# remove deactivated public images from view

import horizon
from openstack_dashboard.dashboards.project.images import views as images_views
from openstack_dashboard import api
class MyIndexView(images_views.IndexView):
    def get_data(self):
        images = super(MyIndexView, self).get_data()
        return [i for i in images if not api.glance.is_image_public(i)
                or i.status not in ('deactivated',)]

horizon.get_dashboard("project").get_panel('images').urls = "dashboard_overrides.images_urls"
