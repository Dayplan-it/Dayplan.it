from django.db import models
from django.contrib.auth.models import AbstractUser


# 현재 별명, 전화번호 정도 필드 추가 / 이후에 필요한 거 있으면 추가할 예정
class User(AbstractUser):
    nickname = models.CharField(max_length=50)
    phone = models.CharField(max_length=50, null=True)
