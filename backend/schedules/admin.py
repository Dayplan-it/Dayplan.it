from django.contrib import admin
from . import models


@admin.register(models.Schedule)
class ScheduleAdmin(admin.ModelAdmin):

    """ Schedules Admin Definition """

    list_display = (
        "schedule_title",
    )
