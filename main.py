import os
from dotenv import load_dotenv
from nredarwin.webservice import DarwinLdbSession
import json

load_dotenv()
locations = [{
    "location":"Garswood",
    "crs": "GSW"
}]

darwin_key = os.getenv('DARWIN_WEBSERVICE_API_KEY')
darwin_sesh = DarwinLdbSession(
    wsdl="https://lite.realtime.nationalrail.co.uk/OpenLDBWS/wsdl.aspx", api_key=darwin_key)


'''
Train Service dir produces:

'destination_text', 'destinations', 'estimated_arrival', 'estimated_departure', 'eta', 'etd', 
'field_mapping', 'is_circular_route', 'operator_code', 'operator_name', 'origin_text', 'origins', 
'platform', 'scheduled_arrival', 'scheduled_departure', 'service_id', 'sta', 'std']
'''

def get_service_information(station):
    services = []
    board = darwin_sesh.get_station_board(station, destination_crs="LIV")
    for service in board.train_services:
        print(f'{service.platform} - {service.destination_text} - {service.std} - {service.etd}')
        service_id = service.service_id
        service_deets = darwin_sesh.get_service_details(service_id)
        service_dict = {
            'destination':service.destination_text,
            'platform':service.platform,
            'calling_at':[cp.location_name for cp in service_deets.subsequent_calling_points],
            'std':service.std,
            'eta':service.etd            
        }
        services.append(service_dict)
    return services


def build_json(station):
    service_info = {
        "location": {
            "name":"Garswood",
            "crs":"GSW"
        },
        "services":get_service_information(station)
    }
    return service_info


def main():
    service_json = build_json('GSW')
    with open('trains.json', 'w') as f:
        json.dump(service_json, f, indent=2)

main()