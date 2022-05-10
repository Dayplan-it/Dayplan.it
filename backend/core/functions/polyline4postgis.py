import polyline  # Google의 PolyLine을 Decode할 때 사용


class PolylineDecoderForPostGIS():

    """
    Google PolyLine을 PostGIS에 맞는 형식으로 decode해줍니다.
    `.get()`을 붙여서 사용해주세요.
    """

    def __init__(self, polyline_before_decode):
        self.polyline_decoded = polyline.decode(polyline_before_decode)

    def get(self):
        return [(point[0], point[1]) for point in self.polyline_decoded]
