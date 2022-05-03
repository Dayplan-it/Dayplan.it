from django.urls import path
from .views import PlaceRecommend, PlaceDetail, MakeRoute, PlaceAutocomplete, FindAddressByLatLng
urlpatterns = [
    path('placerecommend/', PlaceRecommend.as_view()),
    path('placedetail/', PlaceDetail.as_view()),
    path('getroute/', MakeRoute.as_view()),
    path('placeautocomplete/', PlaceAutocomplete.as_view()),
    path('findaddressbylatlng/', FindAddressByLatLng.as_view())
]
