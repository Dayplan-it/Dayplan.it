import random
import datetime
from faker import Faker
# django_seed에서도 faker를 제공하지만 이상하게 'ko_KR' locale 설정이 안돼서 직접 import해서 씀
from django.core.management.base import BaseCommand
from django_seed import Seed
from schedules import models as schedule_models
from users import models as user_models
fake_ko = Faker('ko_KR')


NAME = "Schedules"


class Command(BaseCommand):

    help = f'Create {NAME}'

    def add_arguments(self, parser):
        parser.add_argument("--number", default=1, type=int,
                            help=f"How Many {NAME} to Create")

    def handle(self, *args, **options):
        number = options.get("number")
        seeder = Seed.seeder()
        all_users = user_models.User.objects.all()
        seeder.add_entity(
            schedule_models.Schedule, number, {
                'schedule_title': lambda x: fake_ko.catch_phrase(),
                'date': lambda x: fake_ko.date_between(start_date=(datetime.datetime.now() + datetime.timedelta(days=1)).date(), end_date=(datetime.datetime.now() + datetime.timedelta(days=30)).date()),
                'memo': lambda x: fake_ko.bs(),
                'user': lambda x: random.choice(all_users)
            })

        seeder.execute()
        self.stdout.write(self.style.SUCCESS(f"{number} {NAME} created!"))
