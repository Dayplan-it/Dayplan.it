from django.urls import path
from .views import PlaceRecommand,PlaceDetail
urlpatterns = [
    path('placerecommand/', PlaceRecommand.as_view()),
    path('placedetail/', PlaceDetail.as_view())
]
