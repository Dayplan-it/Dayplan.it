import datetime
import time
from django.core.exceptions import ValidationError
from schedules import models as schedule_models
from schedules.api.serializers import ScheduleSerializer
from schedules.api.serializers_post import ScheduleSerializer as POST_ScheduleSerializer
from routes.api.route_modules import findRoute, findSteps, findPlace


def findSchedule(user_id, date):
    """
    user_id, date를 받아 스케쥴을 json 객체로 리턴
    """

    schedule = schedule_models.Schedule.objects.get(
        user_id=user_id, date=date)

    result = ScheduleSerializer(schedule).data

    result["order"] = []

    for iter_order in schedule.orders.all().iterator():
        order = {
            "order_serial": iter_order.serial,
            "type": "PL" if iter_order.is_place else "RO",
        }

        if iter_order.is_place:
            order["detail"] = findPlace(iter_order)
        else:
            order["detail"] = findRoute(iter_order)
            order["step"] = findSteps(iter_order)

        result["order"].append(order)

    return result


def findAllSchedule(user_id):
    """
    user_id를 받아 스케쥴 리스트를 json 객체로 리턴

    - 범위는 1주일 전 ~ 30일 뒤
    """

    query_date_range = [(datetime.datetime.now().date() - datetime.timedelta(weeks=1)).strftime("%Y-%m-%d"), (datetime.datetime.now().date() + datetime.timedelta(days=30)).strftime("%Y-%m-%d")]

    schedules = schedule_models.Schedule.objects.filter(user_id=user_id, date__range=query_date_range).order_by("date")#.get()

    result = { "found_schedule_dates": [] }
    for schedule in schedules:
        result["found_schedule_dates"].append(int(time.mktime(schedule.date.timetuple())))

    return result


def createSchedule(obj):
    """
    스케쥴을 생성하고 저장
    """

    schedule_serialized = POST_ScheduleSerializer(data=obj)
    if schedule_serialized.is_valid():
        schedule_serialized.save()
        return schedule_serialized.data
    else:
        raise ValidationError


def createOrders(order_len, schedule_id):
    """
    Order, Place, Route 생성하고 저장
    Place, Route가 OneToOneField
    """

    created_orders = []
    for i in range(0, order_len):
        created_orders.append(schedule_models.Order.objects.create(
            serial=i,
            is_place=True if i % 2 == 0 else False,
            schedule=schedule_models.Schedule.objects.get(id=schedule_id)
        ))

    return created_orders
