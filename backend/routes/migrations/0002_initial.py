# Generated by Django 4.0.3 on 2022-04-05 18:08

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('routes', '0001_initial'),
        ('schedules', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='route',
            name='schedule_order',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='route', to='schedules.order'),
        ),
        migrations.AddField(
            model_name='route',
            name='start_place',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='routes_start', to='routes.place'),
        ),
        migrations.AddField(
            model_name='place',
            name='schedule_order',
            field=models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='place', to='schedules.order'),
        ),
    ]
