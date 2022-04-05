from django.urls import path
from .views import PlaceRecommand, PlaceDetail, MakeRoute
urlpatterns = [
    path('placerecommend/', PlaceRecommand.as_view()),
    path('placedetail/', PlaceDetail.as_view()),
    path('getroute/', MakeRoute.as_view())
]
