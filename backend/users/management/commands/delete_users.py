from django.core.management.base import BaseCommand
from users.models import User


NAME = "Users"


class Command(BaseCommand):

    help = f'Delete {NAME}'

    def handle(self, *args, **options):
        number = User.objects.exclude(
            is_staff=True).exclude(is_superuser=True).count()
        User.objects.exclude(is_staff=True).exclude(
            is_superuser=True).delete()
        self.stdout.write(self.style.SUCCESS(f"{number} {NAME} DELETED!"))
