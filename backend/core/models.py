from django.db import models


class TimeStampedModel(models.Model):

    """ Time Stamped Model """

    created = models.DateTimeField(auto_now_add=True)
    updated = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class StartEndTimeModel(models.Model):

    """ Start-End Time Model """

    starts_at = models.TimeField(null=False)
    ends_at = models.TimeField(null=False)

    class Meta:
        abstract = True
