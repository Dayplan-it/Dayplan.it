from django.core.management.base import BaseCommand
from routes import models as route_models


NAME = "Routes"


class Command(BaseCommand):

    help = f'Delete {NAME} and all belongings'

    def handle(self, *args, **options):
        number = route_models.Route.objects.count()
        route_models.Route.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(f"{number} Routes DELETED!"))

        number = route_models.Place.objects.count()
        route_models.Place.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(f"{number} Places DELETED!"))

        number = route_models.TransitDetail.objects.count()
        route_models.TransitDetail.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(
            f"{number} TransitDetails DELETED!"))

        number = route_models.WalkingDetail.objects.count()
        route_models.WalkingDetail.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(
            f"{number} WalkingDetails DELETED!"))

        number = route_models.Step.objects.count()
        route_models.Step.objects.all().delete()
        self.stdout.write(self.style.SUCCESS(
            f"{number} Steps DELETED!"))
