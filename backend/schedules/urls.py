from django.urls import path, include
from .views import FindScheduleAPIView
urlpatterns = [

    path('find', FindScheduleAPIView.as_view()),  # user_id, date param 필요

]
