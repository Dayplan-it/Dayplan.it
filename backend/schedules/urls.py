from django.urls import path
from .views import FindScheduleAPIView, FindScheduleListAPIView, DeleteScheduleAPIView, CreateScheduleAPIView
urlpatterns = [

    path('find', FindScheduleAPIView.as_view()),
    path('create', CreateScheduleAPIView.as_view()),
    path('delete', DeleteScheduleAPIView.as_view()),
    path('findlist', FindScheduleListAPIView.as_view()),

]
