import json
from os import environ

import boto3


def get_email_list(ssm_param_name: str) -> list[str]:
    ssm_client = boto3.client('ssm')
    try:
        ssm_parameter_resp = ssm_client.get_parameter(
            Name=ssm_param_name
        )
        print(f"Data is '{ssm_parameter_resp}'")
    except ssm_client.exceptions.ParameterNotFound:
        return []

    return ssm_parameter_resp['Parameter']['Value'].split(',')


def lambda_handler(event: dict, context):
    ssm_param_name = environ.get("EMAIL_LIST_SSM_PARAMETER", "")
    if not ssm_param_name:
        print("Environment variable 'EMAIL_LIST_SSM_PARAMETER' is not found")
        return None

    source_email_address = environ.get("SOURCE_EMAIL_ADDRESS", "")
    if not source_email_address:
        print("Environment variable 'SOURCE_EMAIL_ADDRESS' is not found")
        return None

    record_list = event.get("Records", None)
    if not record_list:
        return None

    email_list = get_email_list(ssm_param_name)
    if not email_list:
        return None
    print(f"Email list is {email_list}")

    for record in record_list:
        print(f"Record: {record}")

        if record["EventSource"] != "aws:sns":
            continue

        ses_client = boto3.client('ses')
        response = ses_client.send_email(
            Source=source_email_address,
            Destination={
                'ToAddresses': email_list
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': 'UTF-8',
                        'Data': json.dumps(record, indent=4),
                    },
                },
                'Subject': {
                    'Charset': 'UTF-8',
                    'Data': "Instance state is changed",
                },
            }
        )
        print(f"SES Response: {response}")
        print(f"Email sent to {email_list}")
