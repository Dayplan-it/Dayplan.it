import logging
from datetime import datetime
from django.core.exceptions import ValidationError, ObjectDoesNotExist
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_400_BAD_REQUEST, HTTP_200_OK, HTTP_404_NOT_FOUND
from .api.find_schedule import find_schedule
from schedules import models as schedule_models
from schedules.api.serializers import ScheduleSerializer


# Define Param Names
PARAM_USER_ID = 'user_id'
PARAM_DATE = 'date'

# Define Boby Keys
KEY_USER_ID = 'user_id'
KEY_DATE = 'date'

logger = logging.getLogger('django.server')


class FindScheduleAPIView(APIView):
    """
    user_id와 date를 parameter로 받아 해당 유저의 해당 날짜의 스케쥴을 JSON 형식으로 리턴합니다.
    date는 Timestamp값으로 주어야 합니다.

    - 추후 user_id가 아닌 user_token으로 Permission을 확인하는 로직이 필요함
    """

    def get(self, request):
        try:
            user_id = int(request.query_params[PARAM_USER_ID])
            date = datetime.fromtimestamp(
                int(request.query_params[PARAM_DATE])).date()

            return Response(find_schedule(user_id=user_id, date=date), status=HTTP_200_OK)

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

    def get_object(self, user_id, date):
        try:
            return schedule_models.Schedule.objects.get(user_id=user_id, date=date)
        except schedule_models.Schedule.DoesNotExist:
            raise ObjectDoesNotExist

    def delete(self, request):
        try:
            user_id = request.data[KEY_USER_ID]
            date = datetime.fromtimestamp(
                int(request.data[KEY_DATE])).date()

            schedule = self.get_object(user_id, date)
            title = schedule.schedule_title
            username = schedule.user.username

            logger.info(
                f'{username}의 {date} 스케쥴 "{title}" 삭제')
            schedule.delete()

            return JsonResponse({"message": f"{username}의 {date} 스케쥴 \"{title}\" 삭제"}, status=HTTP_200_OK)

        except ValidationError:
            return JsonResponse({"message": "TYPE_ERROR"}, status=HTTP_400_BAD_REQUEST)
        except ValueError:
            return JsonResponse({"message": "INVALID_VALUE"}, status=HTTP_400_BAD_REQUEST)
        except ObjectDoesNotExist:
            logger.error(
                f'{user_id}의 {date} 스케쥴이 없습니다.')
            return JsonResponse({"message": "NO_SUCH_SCHEDULE"}, status=HTTP_404_NOT_FOUND)
