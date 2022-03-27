from django.db import models
from django.contrib.gis.db import models as geom_models
from core import models as core_models


class RouteType(core_models.TimeStampedModel):

    """ Schedule_Route_Type Model Definition """

    name = models.CharField(max_length=140)

    class Meta:
        verbose_name_plural = "Route Types"

    def __str__(self):
        return self.name


class Node(core_models.TimeStampedModel):

    """ Schedule_Node Type Model Definition """

    node_name = models.CharField(max_length=50)
    node_geom = geom_models.PointField(srid=4326)

    def __str__(self):
        return self.node_name


class Route(core_models.TimeStampedModel):

    """ Schedule_Route Model Definition """

    route_geom = geom_models.LineStringField()
    route_type = models.ManyToManyField(
        "RouteType", related_name="routes", blank=False)


class Order(core_models.TimeStampedModel):

    """ Schedule_Order Model Definition """

    serial = models.IntegerField()
    is_node = models.BooleanField()
    node_geom = models.ForeignKey(
        "Node", related_name="schedule_orders", on_delete=models.CASCADE, null=True)
    route_geom = models.ForeignKey(
        "Route", related_name="schedule_orders", on_delete=models.CASCADE, null=True)
    starts_at = models.TimeField(null=False)
    ends_at = models.TimeField(null=False)
    schedule = models.ForeignKey(
        "Schedule", related_name="schedule_orders", on_delete=models.CASCADE)


class Schedule(core_models.TimeStampedModel):

    """ Schedule Model Definition """

    schedule_title = models.CharField(max_length=50)
    date = models.DateField(null=False)
    user = models.ForeignKey(
        "users.User", related_name="schedules", on_delete=models.CASCADE)

    def __str__(self):
        return self.schedule_title
