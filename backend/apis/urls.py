from django.urls import path
from .views import PlaceRecommend, PlaceDetail, MakeRoute, PlaceAutocomplete
urlpatterns = [
    path('placerecommend/', PlaceRecommend.as_view()),
    path('placedetail/', PlaceDetail.as_view()),
    path('getroute/', MakeRoute.as_view()),
    path('placeautocomplete/', PlaceAutocomplete.as_view())
]
