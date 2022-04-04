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
        "Schedule", related_name="orders", on_delete=models.CASCADE)

    def __str__(self):
        return f'{self.schedule.user.username}의 {self.schedule.date} 스케쥴 "{self.schedule.schedule_title}" {self.serial + 1}번째 Order: {self.place.place_name + "에서 일정" if self.is_place else self.routes.distance + "KM 이동"}'
