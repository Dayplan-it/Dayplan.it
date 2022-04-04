import random
from django.core.management.base import BaseCommand
from django_seed import Seed
from schedules import models as schedule_models


NAME = "Orders"


class Command(BaseCommand):

    help = f'Create {NAME}'

    def handle(self, *args, **options):
        seeder = Seed.seeder()
        all_schedules = schedule_models.Schedule.objects.all()

        for choosen_schedule in all_schedules:
            node_count = random.randint(4, 7)  # 이번에 생성할 스케쥴은 몇 군데를 다닐것인지

            for i in range(0, 2 * node_count - 1):  # node_count + (node_count - 1)
                seeder.add_entity(
                    schedule_models.Order, 1, {
                        'serial': i,
                        'is_place': True if i % 2 == 0 else False,  # 짝수번째라면 장소, 아니면 경로일 것임
                        'schedule': choosen_schedule
                    })

        seeder.execute()
        self.stdout.write(self.style.SUCCESS(f"{NAME} created!"))
