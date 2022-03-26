from django.db import models
from core import models as core_models


class Schedule(core_models.TimeStampedModel):

    """ Schedule Model Definition """

    title = models.CharField(max_length=50)

    def __str__(self):
        return self.title
