import random
from django.core.management.base import BaseCommand
from django_seed import Seed
from schedules import models as schedule_models


NAME = "Orders"


class Command(BaseCommand):

    help = f'Create {NAME}'

    def add_arguments(self, parser):
        parser.add_argument("--number", default=1, type=int,
                            help=f"How Many {NAME} to Create")

    def handle(self, *args, **options):
        number = options.get("number")
        seeder = Seed.seeder()
        all_schedules = schedule_models.Schedule.objects.all()

        for i in range(0, number + 1):
            choosen_schedule = random.choice(all_schedules)
            all_schedules = all_schedules.exclude(id=choosen_schedule.id)
            node_count = random.randint(4, 7)  # 이번에 생성할 스케쥴은 몇 군데를 다닐것인지

            for j in range(0, 2 * node_count):  # node_count + (node_count - 1) + 1
                seeder.add_entity(
                    schedule_models.Order, 1, {
                        'serial': j,
                        'is_place': True if j % 2 == 0 else False,  # 짝수번째라면 장소, 아니면 경로일 것임
                        'schedule': choosen_schedule
                    })

        seeder.execute()
        self.stdout.write(self.style.SUCCESS(f"{number} {NAME} created!"))
