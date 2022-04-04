from routes.api.serializers import RouteSerializer, StepSerializer, WalkingDetailSerializer, TransitDetailSerializer


def find_route(order):
    return RouteSerializer(order.route).data


def find_steps(order):
    route = order.route
    step_list = []

    for iter_step in route.steps.iterator():
        step = StepSerializer(iter_step).data

        if step["travel_mode"] == "WK":
            step["walking_detail"] = []
            for walking_detail in iter_step.walking_details.iterator():
                step["walking_detail"].append(
                    WalkingDetailSerializer(walking_detail).data)
        elif step["travel_mode"] == "TR":
            step["transit_detail"] = TransitDetailSerializer(
                iter_step.transit_detail).data

        # elif step["travel_mode"] == "DR":
        # 추후 필요하다면 운전 경로 관련 기능을 추가

        step_list.append(step)

    return step_list
