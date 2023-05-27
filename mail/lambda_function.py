import os
import boto3
import logging
import json
import urllib.request
from collections import OrderedDict
import pprint
from email import policy
from email.parser import BytesParser

s3_client = boto3.client('s3')
ses_client = boto3.client('ses')
logger = logging.getLogger()
logger.setLevel(logging.INFO)
s3_bucket = os.environ['S3_BUCKET']
webhook_url = os.environ['SLACK_WEBHOOK_URL']
#forward_to = os.environ['FORWARD_TO']

def post_slack(from_address, subject, message):
    send_data = {
        'text': 'From: {}\nSubject: {}\n\n{}'.format(from_address, subject, message)
    }
    

    send_text = json.dumps(send_data)
    request = urllib.request.Request(
        webhook_url, 
        data=send_text.encode('utf-8'), 
        method="POST"
    )
    with urllib.request.urlopen(request) as response:
        response_body = response.read().decode('utf-8')

def lambda_handler(event, context):
    logger.info(event)
    message_id=event['Records'][0]['ses']['mail']['messageId']
    response = s3_client.get_object(
        Bucket = s3_bucket,
        Key    = message_id
    )
    # Emlデータ取得
    raw_message = response['Body'].read()
    
    # メールの本文のみを抽出
    msg = BytesParser(policy=policy.default).parsebytes(raw_message)
    body = ''
    if msg.is_multipart():
        for part in msg.iter_parts():
            if part.get_content_type() == 'text/plain':
                body = part.get_content()
    else:
        body = msg.get_content()
    subject = msg['Subject']
    from_address = msg['From']
    
    post_slack(from_address, subject, body)