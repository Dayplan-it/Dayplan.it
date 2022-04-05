from django.urls import path
from .views import FindScheduleAPIView, DeleteScheduleAPIView
urlpatterns = [

    path('find', FindScheduleAPIView.as_view()),  # user_id, date param 필요
    # path('create', .as_view()),
    # path('update', .as_view()),
    path('delete', DeleteScheduleAPIView.as_view()),

]
