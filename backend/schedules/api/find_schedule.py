from schedules import models as schedule_models
from schedules.api.serializers import ScheduleSerializer
from routes.api.find_routes import find_route, find_steps
from routes.api.find_places import find_place


def find_schedule(user_id, date):
    """
    user_id, date를 받아 스케쥴을 json 객체로 리턴
    """

    schedule = schedule_models.Schedule.objects.filter(
        user_id=user_id).filter(date=date).get()

    result = ScheduleSerializer(schedule).data

    result["order"] = []

    for iter_order in schedule.orders.iterator():
        order = {
            "order_serial": iter_order.serial,
            "type": "PL" if iter_order.is_place else "RO",
        }

        if iter_order.is_place:
            order["detail"] = find_place(iter_order)
        else:
            order["detail"] = find_route(iter_order)
            order["step"] = find_steps(iter_order)

        result["order"].append(order)

    return result
