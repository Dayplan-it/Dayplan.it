import random
from faker import Faker
from django.core.management.base import BaseCommand
from django_seed import Seed
# django_seed에서도 faker를 제공하지만 이상하게 'ko_KR' locale 설정이 안돼서 직접 import해서 씀
from users.models import User


NAME = "Users"


class Command(BaseCommand):

    help = f'Create {NAME}'

    def add_arguments(self, parser):
        parser.add_argument("--number", default=1, type=int,
                            help=f"How Many {NAME} to Create")

    def handle(self, *args, **options):
        number = options.get("number")
        seeder = Seed.seeder()
        seeder.add_entity(
            User, number, {
                'is_staff': False,
                'is_superuser': False,
                'is_active': True,
                # 'first_name': lambda x: Faker('ko_KR').first_name(),
                # 'last_name': lambda x: Faker('ko_KR').last_name(),
                # 우리는 안쓰긴 하지만 이름도 가짜로 넣을 수 있음
                'password': lambda x: Faker('ko_KR').password(),
                'phone': lambda x: "010" + str(random.randint(10001000, 99999999)),
            })

        seeder.execute()
        self.stdout.write(self.style.SUCCESS(f"{number} {NAME} created!"))
