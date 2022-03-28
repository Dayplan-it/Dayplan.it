from django.urls import path, include
from .views import SignIn, Signup, Activate
urlpatterns = [

    path('login', SignIn.as_view()),
    path('signup', Signup.as_view()),
    path('auth', include('rest_framework.urls', namespace='rest_framework')),
    path('activate/<str:uidb64>/<str:token>', Activate.as_view())

]
