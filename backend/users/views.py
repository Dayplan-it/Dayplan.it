import jwt
# 비밀번호 해쉬함수로 암호화
import bcrypt
# 이메일 인증을 위해 수정
from .token import account_activation_token
# 이메일 텍스트를 저장한 함수
from .text import message
# 이메일 유효성 검사
from django.contrib.sites.shortcuts import get_current_site
from django.http import HttpResponse, JsonResponse
from django.utils.encoding import force_bytes, force_str
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.core.mail import EmailMessage
from django.core.validators import validate_email
from django.core.exceptions import ValidationError
from rest_framework.status import HTTP_400_BAD_REQUEST, HTTP_404_NOT_FOUND, HTTP_200_OK, HTTP_401_UNAUTHORIZED
from rest_framework.parsers import JSONParser
from rest_framework.views import APIView

from .models import User
from config.settings import SECRET_KEY
# =====================로그인============================


class SignIn(APIView):
    def post(self, request):

        # 데이터 파싱
        data = JSONParser().parse(request)
        print(data)
        try:
            # DB에서 유저 존재유무확인
            if User.objects.filter(email=data["email"]).exists():
                user = User.objects.get(email=data["email"])
                # 비밀번호 검사
                if bcrypt.checkpw(data['password'].encode('UTF-8'), user.password.encode('UTF-8')):
                    token = jwt.encode(
                        {'user': user.id}, SECRET_KEY, algorithm='HS256')
                    return JsonResponse({"token": token}, status=HTTP_200_OK)

                return HttpResponse(status=HTTP_401_UNAUTHORIZED)
            return HttpResponse(status=HTTP_400_BAD_REQUEST)
        except KeyError:
            return JsonResponse({'message': 'INVALID_KEYS'}, status=HTTP_400_BAD_REQUEST)

# =====================회원가입============================


class Signup(APIView):
    def post(self, request):
        try:
            data = JSONParser().parse(request)
            usernamee = data['username']
            password1 = data['password1']
            password2 = data['password2']
            emaill = data['email']
            nick = data['nickname']
            phonee = data['phone']

            validate_email(emaill)

            # 이메일 존재하는지 여부
            if User.objects.filter(email=emaill).exists():
                return JsonResponse({"message": "이미 이메일이 존재합니다."}, status=HTTP_400_BAD_REQUEST)

            # 비밀번호재확인의 통과 여부
            if password1 != password2:
                return JsonResponse({"message": "비밀번호가 다릅니다."}, status=HTTP_400_BAD_REQUEST)

            # 유저 저장
            user = User.objects.create(
                username=usernamee,
                # 암호화
                password=bcrypt.hashpw(password1.encode(
                    "UTF-8"), bcrypt.gensalt()).decode("UTF-8"),
                email=emaill,
                phone=phonee,
                # 이메일 인증하기전까진 계정 비활성화
                is_active=False,
                nickname=nick)

            # 인증url을 만들기 위한 변수들
            current_site = get_current_site(request)
            domain = current_site.domain
            uidb64 = urlsafe_base64_encode(force_bytes(user.pk))
            # 토큰 만들기
            token = account_activation_token.make_token(user)
            # text.py에서 message 가져옴
            message_data = message(domain, uidb64, token)

            # 이메일 제목, 내용, 보낼사람을 정해서 이메일 전송
            mail_title = "이메일 인증을 완료해주세요"
            mail_to = emaill
            email = EmailMessage(mail_title, message_data, to=[mail_to])
            email.send()

            return JsonResponse({"message": "SUCCESS"}, status=HTTP_200_OK)
        except KeyError:
            return JsonResponse({"message": "INVALID_KEY"}, status=HTTP_400_BAD_REQUEST)
        except TypeError:
            return JsonResponse({"message": "INVALID_TYPE"}, status=HTTP_400_BAD_REQUEST)
        except ValidationError:
            return JsonResponse({"message": "VALIDATION_ERROR"}, status=HTTP_400_BAD_REQUEST)

# =======================이메일 인증================================


class Activate(APIView):
    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)

            if account_activation_token.check_token(user, token):
                user.is_active = True
                user.save()
                return JsonResponse({"message": "SUCCESS"}, status=HTTP_200_OK)
            return JsonResponse({"message": "AUTH FAIL"}, status=HTTP_400_BAD_REQUEST)

        except ValidationError:
            return JsonResponse({"message": "TYPE_ERROR"}, status=HTTP_400_BAD_REQUEST)
        except KeyError:
            return JsonResponse({"message": "INVALID_KEY"}, status=HTTP_400_BAD_REQUEST)
