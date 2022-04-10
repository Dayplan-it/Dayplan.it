import polyline
from django.db import models
from django.contrib.gis.db import models as geom_models
from django.conf import settings
from colorfield.fields import ColorField
from core import models as core_models


class Route(core_models.TravelCoreModel):

    """ Route Model Definition """

    '''
    전체적인 경로에 대한 정보를 담는 릴레이션
    상세한 경로는 Step 릴레이션에 담기며, Route은 여러개의 Step을 가지게 됨
    '''

    # start_addr = models.TextField(null=False)
    start_name = models.CharField(null=False, max_length=50)
    start_place = models.ForeignKey(
        "Place", related_name="routes_start", on_delete=models.CASCADE)

    # end_addr = models.TextField(null=False)
    end_name = models.CharField(null=False, max_length=50)
    end_place = models.ForeignKey(
        "Place", related_name="routes_end", on_delete=models.CASCADE)

    schedule_order = models.ForeignKey(
        "schedules.Order", related_name="route", on_delete=models.CASCADE)

    def __str__(self):
        return f'{self.schedule_order.schedule.user.username}의 {self.schedule_order.schedule.date} {self.schedule_order.serial + 1}번째 일정 - {self.start_name}에서 {self.end_name}으로 {self.duration}간 이동'

    def lineStr2polyLine(self):
        return polyline.encode(self.poly_line)


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

    instruction = models.TextField()

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

    def lineStr2polyLine(self):
        return polyline.encode(self.poly_line)


"""
    이하  WalkingDetail 모델은 sub-Step 모델 중 하나였으나
    모델에서 제외하기로 함
"""

# class WalkingDetail(core_models.TravelModel):

#     """ Route_Walking Model Definition """

#     walking_step = models.ForeignKey(
#         "Step", related_name="walking_details", on_delete=models.CASCADE)

#     def __str__(self):
#         return f'StepId {self.walking_step.id} Serial {self.serial} Walking Details'

#     def lineStr2polyLine(self):
#         try:
#             polyline_encoded = polyline.encode(self.poly_line)
#         except:
#             """
#             이상하게 Line이 아니고 Point가 들어가 있는 경우가 있는데
#             Point일경우 polyline encoding이 안돼서 예외처리로 무시하도록 함

#             Point인데 duration이 있는 경우도 아주 드물게 있는 것 같은데
#             이 오류는 아마 seed_routes에서 아직 찾지 못한 버그가 있기때문이 아닐까 추측함

#             추후 FrontEnd 작업하면서 원인을 찾아봐야 할듯
#             """
#             return
#         return polyline_encoded


class TransitDetail(core_models.TimeStampedModel):

    """ Route_TransitDetail Model Definition """

    transit_step = models.ForeignKey(
        "Step", related_name="transit_detail", on_delete=models.CASCADE)

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
        null=False, srid=settings.SRID)
    departure_time = models.TimeField(null=False)

    arrival_stop_name = models.CharField(null=False, max_length=50)
    arrival_stop_loc = geom_models.PointField(
        null=False, srid=settings.SRID)
    arrival_time = models.TimeField(null=False)

    num_stops = models.IntegerField(null=False)

    transit_color = ColorField(null=False)
    # Google Maps Directions API에서 각 라인별 색을 줌

    def __str__(self):
        return f'StepId {self.step.id} - {self.transit_type} {self.transit_name}, {self.num_stops} stops'


class Place(core_models.StartEndTimeModel):

    """ Place Model Definition """

    schedule_order = models.ForeignKey(
        "schedules.Order", related_name="place", on_delete=models.CASCADE)

    place_name = models.CharField(null=False, max_length=50)
    place_id = models.CharField(null=False, max_length=50)
    place_type = models.CharField(
        null=False, max_length=50)  # 추후 choices를 정할 예정
    place_geom = geom_models.PointField(
        null=False, srid=settings.SRID)

    def __str__(self):
        return f'{self.schedule_order.schedule.user.username}의 {self.schedule_order.schedule.date} {self.schedule_order.serial + 1}번째 일정 - {self.place_name}에서 {self.starts_at}부터 {self.ends_at}까지 {self.duration}동안 일정'
