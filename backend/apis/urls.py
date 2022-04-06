from django.urls import path
from .views import PlaceRecommend, PlaceDetail, MakeRoute
urlpatterns = [
    path('placerecommend/', PlaceRecommend.as_view()),
    path('placedetail/', PlaceDetail.as_view()),
    path('getroute/', MakeRoute.as_view())
]
