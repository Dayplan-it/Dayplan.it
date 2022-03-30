from django.db import models
from django.contrib.gis.db import models as geom_models
from colorfield.fields import ColorField
from core import models as core_models


class Route(core_models.TravelCoreModel):

    """ Route Model Definition """

    '''
    전체적인 경로에 대한 정보를 담는 릴레이션
    상세한 경로는 Step 릴레이션에 담기며, Route은 여러개의 Step을 가지게 됨
    '''

    start_addr = models.TextField(null=False)
    start_name = models.CharField(null=False, max_length=20)

    end_addr = models.TextField(null=False)
    end_name = models.CharField(null=False, max_length=20)

    schedule_order = models.ForeignKey(
        "schedules.Order", related_name="routes", on_delete=models.CASCADE)

    def __str__(self):
        return f'{self.schedule_order.schedule.user.username}의 {self.schedule_order.schedule.date} {self.schedule_order.serial}번째 일정 - {self.start_name}에서 {self.end_name}으로'


class Step(core_models.TravelModel):

    """ Route_Step Model Definition """

    '''
    상세 경로 릴레이션
    도보이동, 버스, 지하철 등의 상세 이동 경로를 담게 되며
    각 Step이 모여 Route가 됨

    도보이동의 경우 "WalkingDetail", 대중교통 이동의 경우 "TransitDetail"을 가짐
    '''

    route = models.ForeignKey(
        "Route", related_name="steps", on_delete=models.CASCADE)

    TRANSIT = 'TR'
    WALKING = 'WK'
    DRIVING = 'DR'
    TRAVEL_MODE_CHOICES = [
        (TRANSIT, 'Transit'),
        (WALKING, 'Walking'),
        (DRIVING, 'Driving')
    ]
    travel_mode = models.CharField(
        null=False, max_length=2, choices=TRAVEL_MODE_CHOICES)

    def __str__(self):
        return f'RouteId {self.route.id} Serial {self.serial} - {self.travel_mode}'


class WalkingDetail(core_models.TravelModel):

    """ Route_Walking Model Definition """

    walking_step = models.ForeignKey(
        "Step", related_name="walking_details", on_delete=models.CASCADE)

    def __str__(self):
        return f'StepId {self.walking_step.id} Serial {self.serial} Walking Details'


class TransitDetail(core_models.TimeStampedModel):

    """ Route_TransitDetail Model Definition """

    step = models.ForeignKey(
        "Step", related_name="transit_details", on_delete=models.CASCADE)

    BUS = 'BUS'
    SUBWAY = 'SUB'
    TRANSIT_TYPE_CHOICES = [
        (BUS, 'Bus'),
        (SUBWAY, 'Subway')
    ]
    transit_type = models.CharField(
        null=False, max_length=3, choices=TRANSIT_TYPE_CHOICES)
    transit_name = models.CharField(
        null=False, max_length=10)  # 1330-44(번 버스), 2호선 등등

    departure_stop_name = models.CharField(null=False, max_length=50)
    departure_stop_loc = geom_models.PointField(
        null=False, srid=900913)  # Google Maps Global Mercator
    departure_time = models.TimeField(null=False)

    arrival_stop_name = models.CharField(null=False, max_length=50)
    arrival_stop_loc = geom_models.PointField(
        null=False, srid=900913)  # Google Maps Global Mercator
    arrival_time = models.TimeField(null=False)

    num_stops = models.IntegerField(null=False)

    transit_color = ColorField(null=False)
    # Google Maps Directions API에서 각 라인별 색을 줌

    def __str__(self):
        return f'StepId {self.step.id} - {self.transit_type} {self.transit_name}, {self.num_stops} stops'


class Place(core_models.StartEndTimeModel):

    """ Place Model Definition """

    order = models.ForeignKey(
        "schedules.Order", related_name="places", on_delete=models.CASCADE)

    place_name = models.CharField(null=False, max_length=50)
    place_id = models.CharField(null=False, max_length=50)
    place_geom = geom_models.PointField(
        null=False, srid=900913)  # Google Maps Global Mercator

    def __str__(self):
        return self.place_id
