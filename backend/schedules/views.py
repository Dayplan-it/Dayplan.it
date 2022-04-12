import logging
from datetime import datetime
from django.core.exceptions import ValidationError, ObjectDoesNotExist, MultipleObjectsReturned
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_400_BAD_REQUEST, HTTP_200_OK, HTTP_404_NOT_FOUND, HTTP_201_CREATED
from schedules.api.schedule_modules import findSchedule, findAllSchedule, createSchedule, createOrders
from routes.api.route_modules import createPlace, createRoute, createStep, createTransitDetail
from schedules import models as schedule_models


# Define Param Names
PARAM_USER_ID = 'user_id'
PARAM_DATE = 'date'

# Define Boby Keys
KEY_USER_ID = 'user_id'
KEY_USER = 'user'
KEY_DATE = 'date'
KEY_ID = 'id'
KEY_SCHEDULE_TITLE = 'schedule_title'
KEY_MEMO = 'memo'
KEY_ORDER = 'order'
KEY_TYPE = 'type'
KEY_DETAIL = 'detail'
KEY_STARTS_AT = 'starts_at'
KEY_ENDS_AT = 'ends_at'
KEY_DURATION = 'duration'
KEY_PLACE_NAME = 'place_name'
KEY_PLACE_TYPE = 'place_type'
KEY_PLACE_ID = 'place_id'
KEY_STEP = 'step'
KEY_TRAVEL_MODE = 'travel_mode'
KEY_TRANSIT_DETAIL = 'transit_detail'
KEY_START_LOC = 'start_loc'
KEY_END_LOC = 'end_loc'

# Define Const
TYPE_PLACE = 'PL'
TYPE_ROUTE = 'RO'
TYPE_TRANSIT = 'TR'

logger = logging.getLogger('django.server')


class FindScheduleAPIView(APIView):
    """
    user_id와 date를 parameter로 받아 해당 유저의 해당 날짜의 스케쥴을 JSON 형식으로 리턴합니다.
    date는 Timestamp값으로 주어야 합니다.

    - 추후 user_id가 아닌 user_token으로 Permission을 확인하는 로직이 필요함
    """

    # @LoginConfirm
    def get(self, request):
        try:
            user_id = int(request.query_params[PARAM_USER_ID])
            date = datetime.fromtimestamp(
                int(request.query_params[PARAM_DATE])).date()

            return Response(findSchedule(user_id=user_id, date=date), status=HTTP_200_OK)

        except ValidationError:
            return JsonResponse({"message": "TYPE_ERROR"}, status=HTTP_400_BAD_REQUEST)
        except KeyError:
            return JsonResponse({"message": f"INVALID_PARAMETER, you must pass {PARAM_USER_ID}(Integer) and {PARAM_DATE}(Integer)"}, status=HTTP_400_BAD_REQUEST)
        except ValueError:
            return JsonResponse({"message": "INVALID_VALUE"}, status=HTTP_400_BAD_REQUEST)


class FindScheduleListAPIView(APIView):
    """
    user_id를 parameter로 받아 해당 유저의 모든 스케쥴을 가져오는 API입니다.
    date 순으로 정렬된 상태로 리턴됩니다. (과거 -> 미래)

    - 추후 user_id가 아닌 user_token으로 Permission을 확인하는 로직이 필요함
    """

    # @LoginConfirm
    def get(self, request):
        try:
            user_id = int(request.query_params[PARAM_USER_ID])

            return Response(findAllSchedule(user_id=user_id), status=HTTP_200_OK)

        except ValidationError:
            return JsonResponse({"message": "TYPE_ERROR"}, status=HTTP_400_BAD_REQUEST)
        except KeyError:
            return JsonResponse({"message": f"INVALID_PARAMETER, you must pass {PARAM_USER_ID}(Integer) and {PARAM_DATE}(Integer)"}, status=HTTP_400_BAD_REQUEST)
        except ValueError:
            return JsonResponse({"message": "INVALID_VALUE"}, status=HTTP_400_BAD_REQUEST)


class DeleteScheduleAPIView(APIView):
    """
    스케쥴을 삭제하는 API,
    user_id와 schedule의 date(Timestamp)를 body를 통해 받음
    """

    def getSchedule(self, user_id, date):
        """
        스케쥴 객체를 가져옴
        """

        try:
            return schedule_models.Schedule.objects.get(user_id=user_id, date=date)
        except schedule_models.Schedule.DoesNotExist:
            raise ObjectDoesNotExist

    def delete(self, request):
        try:
            user_id = request.data[KEY_USER_ID]
            date = datetime.fromtimestamp(
                int(request.data[KEY_DATE])).date()

            schedule = self.getSchedule(user_id, date)
            title = schedule.schedule_title
            username = schedule.user.username

            logger.info(
                f'{username}의 {date} 스케쥴 "{title}" 삭제')
            schedule.delete()

            return JsonResponse({"message": f"{username}의 {date} 스케쥴 '{title}' 삭제"}, status=HTTP_200_OK)

        except ValidationError:
            return JsonResponse({"message": "TYPE_ERROR"}, status=HTTP_400_BAD_REQUEST)
        except ValueError:
            return JsonResponse({"message": "INVALID_VALUE"}, status=HTTP_400_BAD_REQUEST)
        except ObjectDoesNotExist:
            logger.error(
                f'{user_id}의 {date} 스케쥴이 없습니다.')
            return JsonResponse({"message": "NO_SUCH_SCHEDULE"}, status=HTTP_404_NOT_FOUND)


class CreateScheduleAPIView(APIView):
    """
    스케쥴을 생성하는 API,
    스케쥴 생성에 필요한 정보들 (Schedule, Order, Place, Route, Step, TransitDetail) 생성
    부모 -> 자식 순으로 생성됨
    """

    def checkScheduleAndUserExists(self, user_id, date):
        """
        스케쥴 및 유저의 존재 여부를 확인
        """
        from users import models as user_models
        from schedules import models as schedule_models

        if not user_models.User.objects.filter(id=user_id).exists():
            raise ValueError
        else:
            if schedule_models.Schedule.objects.filter(user_id=user_id, date=date).exists():
                raise MultipleObjectsReturned

    def post(self, request):
        try:
            request.data[KEY_USER] = request.data[KEY_USER_ID]
            request.data[KEY_DATE] = datetime.fromtimestamp(
                int(request.data[KEY_DATE])).date()

            self.checkScheduleAndUserExists(
                request.data[KEY_USER], request.data[KEY_DATE])

            created_id = {}

            # 1. Schedule 생성
            schedule_dict = {
                KEY_USER: request.data[KEY_USER],
                KEY_DATE: request.data[KEY_DATE],
                KEY_SCHEDULE_TITLE: request.data[KEY_SCHEDULE_TITLE],
            }
            if request.data[KEY_MEMO]:
                schedule_dict[KEY_MEMO] = request.data[KEY_MEMO]
            try:
                created_schedule = createSchedule(schedule_dict)
            except ValidationError:
                raise ValidationError

            created_id["created_schedule_id"] = created_schedule[KEY_ID]

            # 2. Order 생성
            created_orders = createOrders(
                len(request.data[KEY_ORDER]), created_schedule[KEY_ID])

            # 3. Place 생성
            created_places = []
            created_id["created_order_id"] = []
            created_id["created_place_id"] = []
            for i in range(0, len(request.data[KEY_ORDER])):
                if request.data[KEY_ORDER][i][KEY_TYPE] == TYPE_PLACE:
                    created_places.append(createPlace(
                        created_orders[i].id, request.data[KEY_ORDER][i][KEY_DETAIL]))
                    created_id["created_order_id"].append(created_orders[i].id)
                    created_id["created_place_id"].append(
                        created_places[i][KEY_ID])
                else:
                    created_places.append(0)  # 자리채우기용

            # Route, Step, TransitDetail 생성
            created_id["created_route_id"] = []
            created_id["created_step_id"] = []
            created_id["created_transit_detail_id"] = []
            for i in range(0, len(request.data[KEY_ORDER])):
                if request.data[KEY_ORDER][i][KEY_TYPE] == TYPE_ROUTE:
                    created_route = createRoute(
                        order_id=created_orders[i].id, route_detail=request.data[KEY_ORDER][i][KEY_DETAIL], start_place=created_places[i-1], end_place=created_places[i+1])
                    created_id["created_route_id"].append(
                        created_route[KEY_ID])

                    for j in range(0, len(request.data[KEY_ORDER][i][KEY_STEP])):
                        created_step = createStep(
                            route_id=created_route[KEY_ID], serial=j, step=request.data[KEY_ORDER][i][KEY_STEP][j])
                        created_id["created_step_id"].append(
                            created_step[KEY_ID])

                        if created_step[KEY_TRAVEL_MODE] == TYPE_TRANSIT:
                            created_transit_detail = createTransitDetail(
                                step_id=created_step[KEY_ID], transit_detail=request.data[KEY_ORDER][i][KEY_STEP][j][KEY_TRANSIT_DETAIL], depart_loc=created_step[KEY_START_LOC], arrive_loc=created_step[KEY_END_LOC])
                            created_id["created_transit_detail_id"].append(
                                created_transit_detail[KEY_ID])

            return Response(created_id, status=HTTP_201_CREATED)

        except ValidationError:
            return JsonResponse({"message": "TYPE_ERROR"}, status=HTTP_400_BAD_REQUEST)
        except ValueError:
            return JsonResponse({"message": "INVALID_VALUE"}, status=HTTP_400_BAD_REQUEST)
        except MultipleObjectsReturned:
            logger.error(
                f'{request.data[KEY_USER]}의 {request.data[KEY_DATE]} 스케쥴이 이미 있습니다.')
            return JsonResponse({"message": "SCHEDULE_ALREADY_EXISTS"}, status=HTTP_400_BAD_REQUEST)
