import json


sources = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
targets = [2, 3, 4, 5, 6, 7, 8, 9, 10, 1]
weights = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]


def lambda_handler(event, context):
    name = event['name']
    message = f'Hello, {name}!'
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({'message': message})
    }
