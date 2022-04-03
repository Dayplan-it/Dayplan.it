from datetime import datetime
from django.core.exceptions import ValidationError
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.status import HTTP_400_BAD_REQUEST, HTTP_200_OK
from .api.find_schedule import find_schedule

# Define Param Names
PARAM_USER_ID = 'user_id'
PARAM_DATE = 'date'


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
