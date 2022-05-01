import jwt
from config.settings import SECRET_KEY
from django.http import JsonResponse
from rest_framework.status import HTTP_401_UNAUTHORIZED
from users.models import User


def token2userid(token):
    token_payload = jwt.decode(
        token, SECRET_KEY, algorithms="HS256")
    userid = token_payload['user']
    return userid
