from django.core.management.base import BaseCommand
from schedules.models import Schedule


NAME = "Schedules"


class Command(BaseCommand):

    help = f'Delete {NAME}'

    def handle(self, *args, **options):
        number = Schedule.objects.count()
        Schedule.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(f"{number} {NAME} DELETED!"))
