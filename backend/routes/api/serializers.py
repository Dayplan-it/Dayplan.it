from rest_framework import serializers
from drf_extra_fields.geo_fields import PointField
from routes import models as route_models


class RouteSerializer(serializers.ModelSerializer):
    polyline = serializers.CharField(source='lineStr2polyLine')

    class Meta:
        model = route_models.Route
        fields = [
            'starts_at',
            'ends_at',
            'duration',
            'distance',
            'polyline',
        ]


class PlaceSerializer(serializers.ModelSerializer):
    point = PointField(source='place_geom')

    class Meta:
        model = route_models.Place
        fields = [
            'starts_at',
            'ends_at',
            'duration',
            'place_name',
            'place_type',
            'point',
            'place_id',
        ]


class StepSerializer(serializers.ModelSerializer):
    polyline = serializers.CharField(source='lineStr2polyLine')

    class Meta:
        model = route_models.Step
        fields = [
            'travel_mode',
            'duration',
            'distance',
            'instruction',
            'polyline',
        ]


# class WalkingDetailSerializer(serializers.ModelSerializer):
#     polyline = serializers.CharField(source='lineStr2polyLine')

#     class Meta:
#         model = route_models.WalkingDetail
#         fields = [
#             'duration',
#             'distance',
#             'polyline',
#         ]


class TransitDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = route_models.TransitDetail
        fields = [
            'transit_type',
            'transit_name',
            'departure_stop_name',
            'departure_time',
            'arrival_stop_name',
            'arrival_time',
            'num_stops',
            'transit_color',
        ]
