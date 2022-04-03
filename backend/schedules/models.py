from django.db import models
from core import models as core_models


class Schedule(core_models.TimeStampedModel):

    """ Schedule Model Definition """

    schedule_title = models.CharField(null=False, max_length=50)
    date = models.DateField(null=False)
    memo = models.TextField(null=True)
    user = models.ForeignKey(
        "users.User", related_name="schedules", on_delete=models.CASCADE)

    def __str__(self):
        return self.schedule_title


class Order(core_models.TimeStampedModel):

    """ Schedule_Order Model Definition """

    serial = models.IntegerField(null=False)
    is_place = models.BooleanField()
    schedule = models.ForeignKey(
        "Schedule", related_name="schedule_orders", on_delete=models.CASCADE)

    # def __str__(self):
    #    return f'ScheduleId {self.schedule.id} - {self.serial}. {"장소: " + self.place.place_name if self.is_place else "경로: " + self.routes.first().start_name + " 이동"}'
