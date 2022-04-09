from rest_framework import serializers
from routes import models as route_models


class RouteSerializer(serializers.ModelSerializer):
    class Meta:
        model = route_models.Route
        fields = '__all__'


class PlaceSerializer(serializers.ModelSerializer):
    class Meta:
        model = route_models.Place
        fields = '__all__'


class StepSerializer(serializers.ModelSerializer):
    class Meta:
        model = route_models.Step
        fields = '__all__'


class TransitDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = route_models.TransitDetail
        fields = '__all__'
