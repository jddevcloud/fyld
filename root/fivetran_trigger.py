import json
import logging
import urllib.request

logging.basicConfig(format='%(levelname)s: %(asctime)s: %(message)s')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


board_ids = (
    "6176b412882a5e7321fcfb8f", # FYLD Product Development Board
    "605097901307ff22829808ff", # Engineering - External - FYLD
    "61f26458c32ef93d47f418de", # Product Intelligence Team
)
request_types = ("boards","cards","lists","actions","labels")
tables = {}
schema = {}

for req in request_types:
    tables[req] = []
    schema[req] = {"primary_key": ["id"]}

def make_request(url, api_key, token):
    headers = {"Authorization":"OAuth oauth_consumer_key=\"{0}\", oauth_token=\"{1}\"".format(api_key, token)}
    req = urllib.request.Request(url, headers=headers)

    with urllib.request.urlopen(req) as response:
        resp =response.read()
    return json.loads(resp)

def handle(event, context):
    logger.info(json.dumps(event))

    root_url = "https://api.trello.com/1"
    resource = "members/me/boards"

    # GET THE CREDENTIALS FROM THE TRIGGERING EVENT
    api_key = event['secrets']['api_key']
    token = event['secrets']['token']

    url = "{0}/{1}".format(root_url, resource)
    
    # REQUEST DATA FROM API
    response_text = make_request(url, api_key, token)
    # ITERATE THROUGH
    results = response_text
    
    for result in results:
        tables['boards'].append(result)
    
    for board in board_ids:
        for req in request_types[1:]:
            url = "{0}/boards/{1}/{2}".format(root_url, board, req)

            # REQUEST DATA FROM API
            response_text = make_request(url, api_key, token)

            # ITERATE THROUGH
            results = response_text

            for result in results:

                # BUILD LISTS FOR EACH TABLE
                tables[req].append(result)

    # ASSEMBLE THE TABLES FOR INSERT
    state = tables['boards'][-1]['id']
    insert = tables

    return {
        "state": state,
        "schema": schema,
        "insert": insert,
        "hasMore": False
    }
