import os
import boto3
import logging
import datetime
import json
import urllib.request
import urllib.parse

logging.basicConfig(format='%(levelname)s: %(asctime)s: %(message)s')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


iam = boto3.client('iam')
utcnow = datetime.datetime.now(datetime.timezone.utc)
ENVIRONMENT = os.getenv('ENVIRONMENT', '')
DEFAULT_SLACK_USER = 'tamas@fyld.ai'


def get_users():
    user_list_url = 'https://slack.com/api/users.list'
    headers = {'Content-type': 'application/x-www-form-urlencoded'}
    values = {'token': os.getenv('SLACK_BOT_ACCESS_TOKEN', '')}
    data = urllib.parse.urlencode(values)
    data = data.encode('ascii')

    req = urllib.request.Request(user_list_url, data, headers)
    with urllib.request.urlopen(req) as response:
        if response.status != 200:
            raise Exception(
                f'Error while retrieving user list '
                f'from Slack: {response.read().decode()}'
            )
        return json.loads(response.read().decode())['members']


def send_message(user_id, message):
    post_message_url = 'https://slack.com/api/chat.postMessage'
    headers = {'Content-type': 'application/x-www-form-urlencoded'}
    values = {
        'token': os.getenv('SLACK_BOT_ACCESS_TOKEN', ''),
        'channel': user_id, 'text': message,
    }
    data = urllib.parse.urlencode(values)
    data = data.encode('ascii')
    req = urllib.request.Request(
        post_message_url, data, headers, method='POST'
    )
    with urllib.request.urlopen(req) as response:
        if response.status != 200:
            raise Exception(
                f'Error notifying user via Slack: {response.read().decode()}'
            )


def rotate_key(username, expired_key):
    logger.warning(
        f'{(utcnow - expired_key["CreateDate"]).days} days old '
        f'active access key found for user {username}. Rotating!'
    )

    # Deactivate old key
    iam.update_access_key(
        UserName=username,
        AccessKeyId=expired_key["AccessKeyId"],
        Status='Inactive'
    )
    # iam.delete_access_key(
    #     UserName=username,
    #     AccessKeyId=expired_key["AccessKeyId"],
    # )

    # Generate new key
    new_key = iam.create_access_key(
        UserName=username,
    )['AccessKey']

    # Activate new key
    iam.update_access_key(
        UserName=username,
        AccessKeyId=new_key["AccessKeyId"],
        Status='Active'
    )
    return new_key


def delete_key(username, key_to_delete):
    logger.warning(
        f'{(utcnow - key_to_delete["CreateDate"]).days} days old '
        f'access key found for user {username}. Deleting!'
    )
    iam.delete_access_key(
        UserName=username,
        AccessKeyId=key_to_delete["AccessKeyId"],
    )


def generate_slack_message(new_key):
    return (
        f'New access key created for {new_key["UserName"]} on {ENVIRONMENT}!\n'
        f'AccessKeyId: {new_key["AccessKeyId"]}\n'
        f'SecretAccessKey: {new_key["SecretAccessKey"]}\n\n'
        f'To set your new access key, run:\n`aws-vault remove sitestream-identity`\nthen\n`aws-vault add sitestream-identity`\nand enter your new credentials.'
    )


def handle(event, context):
    """
    Rotates IAM Access keys every 90 days.
    """

    logger.info(json.dumps(event))

    users = iam.list_users()['Users']

    slack_users = get_users()
    slack_users_email_lookup = {
        user['profile'].get('email'): user['id']
        for user in slack_users
    }

    for username in [x['UserName'] for x in users]:
        user_keys = iam.list_access_keys(
            UserName=username
        )['AccessKeyMetadata']
        for key in user_keys:
            logger.info(
                f'Verifying key {key["AccessKeyId"]} for user {username}'
            )

            if (
                (utcnow - key['CreateDate']).days >= 80 and
                key['Status'] == 'Active'
            ):
                new_key = rotate_key(username, key)

                slack_id = slack_users_email_lookup.get(username)
                if slack_id:
                    send_message(
                        user_id=slack_id,
                        message=generate_slack_message(new_key),
                    )
                else:
                    send_message(
                        user_id=slack_users_email_lookup.get(
                            DEFAULT_SLACK_USER
                        ),
                        message=generate_slack_message(new_key),
                    )
            # Enforce deleting keys older than 90 days
            elif (utcnow - key['CreateDate']).days >= 90:
                delete_key(username, key)

    return {
        'message': 'Rotate IAM key',
        'event': event
    }
