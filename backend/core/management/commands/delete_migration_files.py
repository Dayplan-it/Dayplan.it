import os
from pathlib import Path
from django.core.management.base import BaseCommand
from django.conf import settings


APP_NAMES = [app.split('.')[0] for app in settings.PROJECT_APPS]


class Command(BaseCommand):

    help = 'Delete all migration files'

    def handle(self, *args, **options):
        print(f'Project Apps: {APP_NAMES}')
        for path in settings.BASE_DIR.iterdir():
            if path.name in APP_NAMES:
                migration_path = Path(path) / 'migrations'
                for file_path in migration_path.iterdir():
                    if file_path.name != '__init__.py':
                        os.remove(file_path)

        self.stdout.write(self.style.SUCCESS(
            "Migration files are all removed."))
