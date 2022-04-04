from django.urls import path
from .views import PlaceRecommand
urlpatterns = [
    path('placerecommand', PlaceRecommand.as_view()),
]
