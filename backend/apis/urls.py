from django.urls import path
from .views import PlaceRecommend, PlaceDetail
urlpatterns = [
    path('placerecommend/', PlaceRecommend.as_view()),
    path('placedetail/', PlaceDetail.as_view())
]
