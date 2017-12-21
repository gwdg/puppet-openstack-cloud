from django.conf.urls import include
from django.conf.urls import patterns
from django.conf.urls import url

from openstack_dashboard.dashboards.project.images.images \
    import urls as image_urls
from openstack_dashboard.dashboards.project.images.snapshots \
    import urls as snapshot_urls
from openstack_dashboard.dashboards.project.images import views

from dashboard_overrides.hide_deactivated_images import MyIndexView


urlpatterns = patterns(
    '',
    url(r'^$', MyIndexView.as_view(), name='index'),
    url(r'', include(image_urls, namespace='images')),
    url(r'', include(snapshot_urls, namespace='snapshots')),
)
