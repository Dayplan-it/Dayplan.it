from django.core.management.base import BaseCommand
from schedules.models import Order


NAME = "Orders"


class Command(BaseCommand):

    help = f'Delete {NAME}'

    def handle(self, *args, **options):
        number = Order.objects.count()
        Order.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(f"{number} {NAME} DELETED!"))
