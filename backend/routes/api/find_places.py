from routes.api.serializers import PlaceSerializer


def find_place(order):
    return PlaceSerializer(order.place).data
