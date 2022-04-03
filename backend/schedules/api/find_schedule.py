from schedules import models as schedule_models
from .serializers import ScheduleSerializer


def find_schedule(user_id, date):
    result = dict()

    schedule = schedule_models.Schedule.objects.filter(
        user_id=user_id).filter(date=date)
    orders = schedule.schedule_orders
