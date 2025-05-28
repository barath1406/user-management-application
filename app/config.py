import boto3
import json
import os
import logging

# Flask secret key for session signing - should be a strong random value in production
aws_region = os.environ.get('AWS_REGION')
SECRET_KEY = os.environ.get('FLASK_SECRET_KEY')
if not SECRET_KEY:
    raise ValueError("No FLASK_SECRET_KEY set for Flask application")

AWS_SECRET_KEY = os.environ.get('AWS_SECRET_KEY')
if not AWS_SECRET_KEY:
    raise ValueError("No AWS_SECRET_KEY set for AWS Secrets Manager")

MAX_CONTENT_LENGTH = 16 * 1024 * 1024

# Session cookie security settings
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'

session = boto3.session.Session()

secrets_client = session.client(
        service_name='secretsmanager',
        region_name=aws_region,
    )

def get_db_credentials():
    try:
        response = secrets_client.get_secret_value(SecretId=AWS_SECRET_KEY)
        if response['ResponseMetadata'] and response['ResponseMetadata']['HTTPStatusCode'] == 200:
            return json.loads(response['SecretString'])
    except Exception as exception:
        logging.error(f'Error getting secret: {exception}')
    return None

if __name__ == "__main__":
    print(get_db_credentials())
