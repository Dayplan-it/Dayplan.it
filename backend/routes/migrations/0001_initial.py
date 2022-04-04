# Generated by Django 4.0.3 on 2022-04-04 17:48

import colorfield.fields
import django.contrib.gis.db.models.fields
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Place',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('starts_at', models.TimeField()),
                ('ends_at', models.TimeField()),
                ('duration', models.DurationField()),
                ('place_name', models.CharField(max_length=50)),
                ('place_id', models.CharField(max_length=50)),
                ('place_type', models.CharField(max_length=50)),
                ('place_geom', django.contrib.gis.db.models.fields.PointField(srid=4326)),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='Route',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('starts_at', models.TimeField()),
                ('ends_at', models.TimeField()),
                ('duration', models.DurationField()),
                ('distance', models.FloatField()),
                ('start_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('end_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('poly_line', django.contrib.gis.db.models.fields.GeometryField(srid=4326)),
                ('start_addr', models.TextField()),
                ('start_name', models.CharField(max_length=50)),
                ('end_addr', models.TextField()),
                ('end_name', models.CharField(max_length=50)),
                ('end_place', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='routes_end', to='routes.place')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='Step',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('duration', models.DurationField()),
                ('distance', models.FloatField()),
                ('start_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('end_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('poly_line', django.contrib.gis.db.models.fields.GeometryField(srid=4326)),
                ('serial', models.IntegerField()),
                ('instruction', models.TextField()),
                ('travel_mode', models.CharField(choices=[('TR', 'Transit'), ('WK', 'Walking'), ('DR', 'Driving')], max_length=2)),
                ('route', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='steps', to='routes.route')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='WalkingDetail',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('duration', models.DurationField()),
                ('distance', models.FloatField()),
                ('start_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('end_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('poly_line', django.contrib.gis.db.models.fields.GeometryField(srid=4326)),
                ('serial', models.IntegerField()),
                ('walking_step', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='walking_details', to='routes.step')),
            ],
            options={
                'abstract': False,
            },
        ),
        migrations.CreateModel(
            name='TransitDetail',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('transit_type', models.CharField(choices=[('BUS', 'Bus'), ('SUB', 'Subway')], max_length=3)),
                ('transit_name', models.CharField(max_length=10)),
                ('departure_stop_name', models.CharField(max_length=50)),
                ('departure_stop_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('departure_time', models.TimeField()),
                ('arrival_stop_name', models.CharField(max_length=50)),
                ('arrival_stop_loc', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('arrival_time', models.TimeField()),
                ('num_stops', models.IntegerField()),
                ('transit_color', colorfield.fields.ColorField(default='#FFFFFF', image_field=None, max_length=18, samples=None)),
                ('transit_step', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='transit_detail', to='routes.step')),
            ],
            options={
                'abstract': False,
            },
        ),
    ]
