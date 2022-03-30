# Generated by Django 4.0.3 on 2022-03-30 00:05

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Schedule',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('schedule_title', models.CharField(max_length=50)),
                ('date', models.DateField()),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='schedules', to=settings.AUTH_USER_MODEL)),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='Order',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('serial', models.IntegerField()),
                ('is_place', models.BooleanField()),
                ('schedule', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='schedule_orders', to='schedules.schedule')),
            ],
            options={
                'abstract': False,
            },
        ),
    ]