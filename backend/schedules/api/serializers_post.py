from rest_framework import serializers
from schedules import models as schedule_models


class ScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = schedule_models.Schedule
        fields = '__all__'
