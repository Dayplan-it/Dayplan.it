from django.urls import path, include
from .views import PlaceRecommand
urlpatterns = [
    path('placerecommand', PlaceRecommand.as_view()),
]
