from django.db import models
from django.contrib.auth.models import AbstractUser
from django.core.validators import RegexValidator


# 현재 별명, 전화번호 정도 필드 추가 / 이후에 필요한 거 있으면 추가할 예정
class User(AbstractUser):

    """ User Model Definition """

    nickname = models.CharField(max_length=50)
    phoneNumberRegex = RegexValidator(
        regex=r'^01([0|1|6|7|8|9]?)-?([0-9]{3,4})-?([0-9]{4})$')
    phone = models.CharField(
        validators=[phoneNumberRegex], max_length=11, unique=True)

    def __str__(self):
        return self.username
