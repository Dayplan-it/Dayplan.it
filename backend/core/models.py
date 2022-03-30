from django.db import models
from django.contrib.gis.db import models as geom_models


class TimeStampedModel(models.Model):

    """ Time Stamped Model """

    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class StartEndTimeModel(TimeStampedModel):

    """ Start-End Time Model """

    starts_at = models.TimeField(null=False)
    ends_at = models.TimeField(null=False)
    duration = models.DurationField(null=False)

    class Meta:
        abstract = True


class TravelCoreModel(StartEndTimeModel):

    """ Travel-Core Model """

    distance = models.FloatField(null=False)

    start_loc = geom_models.PointField(
        null=False, srid=900913)  # Google Maps Global Mercator
    end_loc = geom_models.PointField(
        null=False, srid=900913)  # Google Maps Global Mercator

    poly_line = geom_models.LineStringField(
        null=False, srid=900913)  # Google Maps Global Mercator

    class Meta:
        abstract = True


class TravelModel(TravelCoreModel):

    """ Travel Model """

    serial = models.IntegerField(null=False)

    class Meta:
        abstract = True
