from django.urls import path
from .views import FindScheduleAPIView, DeleteScheduleAPIView, CreateScheduleAPIView
urlpatterns = [

    path('find', FindScheduleAPIView.as_view()),
    path('create', CreateScheduleAPIView.as_view()),
    path('delete', DeleteScheduleAPIView.as_view()),

]
