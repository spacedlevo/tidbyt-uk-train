load("render.star", "render")
load("time.star", "time")
load("http.star", "http")

json_url = "http://localhost:8000/trains.json"


def get_json():
    rep = http.get(json_url)
    data = rep.json()
    return data


def main():
    timezone = "Europe/London"
    predictions = get_json()["services"]
    print(predictions)
    rows = []
    for prediction in predictions:
        print(prediction)
        platform = prediction["platform"]
        r = renderSched(prediction, platform, timezone)
        if r:
            rows.extend(r)
            rows.append(render.Box(height=1, width=64, color="#ccffff"))
    return render.Root(
        child=render.Column(children=rows, main_align="start")
    )

def renderSched(prediction, route, timezone):
    print(prediction)
    tm = prediction["eta"]
    if not tm:
        return []
    # t = time.parse_time(tm).in_location(timezone)
    # arr = t - time.now().in_location(timezone)
    arr = 30
    # if arr.minutes < 0:
    #     return []
    dest = prediction["destination"].upper()
    return [render.Row(
        main_align="space_between",
        children=[
            render.Stack(
                children=[
                    render.Circle(
                        diameter=12, color="#ffc72c",
                        child=render.Text(content=prediction["platform"], color="#000", font="CG-pixel-3x5-mono")
                    )
                ]
            ),
            render.Box(width=2, height=5),
            render.Column(
                main_align="start",
                cross_align="left",
                children=[
                    render.Marquee(
                        width=50,
                        child=render.Text(
                            content="{} - {}".format(prediction["std"], dest),
                            height=8,
                            offset=-1,
                            font="Dina_r400-6"
                        )
                    ),
                    render.Text(
                        content="{}".format(prediction["eta"]),
                        height=8,
                        offset=-1,
                        font="Dina_r400-6",
                        color="#ffd11a"
                    )
                ]
            )
        ],
        cross_align="center"
    )]    