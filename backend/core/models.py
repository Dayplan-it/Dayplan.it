from django.db import models
from django.contrib.gis.db import models as geom_models
from django.conf import settings


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

    distance = models.FloatField(null=False)  # 단위 KM

    start_loc = geom_models.PointField(
        null=False, srid=settings.SRID)
    end_loc = geom_models.PointField(
        null=False, srid=settings.SRID)

    poly_line = geom_models.GeometryField(
        null=False, srid=settings.SRID)

    class Meta:
        abstract = True


class TravelCoreModelForSubSteps(TimeStampedModel):

    """ Travel-Core Model for sub-Steps """

    duration = models.DurationField(null=False)

    distance = models.FloatField(null=False)  # 단위 KM

    start_loc = geom_models.PointField(
        null=False, srid=settings.SRID)
    end_loc = geom_models.PointField(
        null=False, srid=settings.SRID)

    poly_line = geom_models.GeometryField(
        null=False, srid=settings.SRID)

    class Meta:
        abstract = True


class TravelModel(TravelCoreModelForSubSteps):

    """ Travel Model """

    serial = models.IntegerField(null=False)

    class Meta:
        abstract = True
