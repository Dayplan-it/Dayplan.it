import random
import time
from datetime import datetime
from django.core.management.base import BaseCommand, CommandError
from schedules import models as schedule_models


class Command(BaseCommand):

    help = 'Return Randomly Picked Schedule\'s user_id and date(as Timestamp)'

    def handle(self, *args, **options):
        if schedule_models.Schedule.objects.all().count() == 0:
            raise CommandError('There is No Schedule. Please Create Schedule.')

        picked_schedule = random.choice(schedule_models.Schedule.objects.all())
        date = picked_schedule.date
        date_in_timestamp = int(time.mktime(date.timetuple()))
        user_id = picked_schedule.user.id

        self.stdout.write(self.style.WARNING(
            f'user_id: {user_id}\ndate(Timestamp): {date_in_timestamp}'))
        self.stdout.write(self.style.SUCCESS(
            "A Schedule was Randomly Picked!"))
