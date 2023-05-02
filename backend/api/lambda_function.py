import json

pr = [0.,0.13494152,0.11470029,0.09749525,0.08287096,0.07044032,0.05987427,0.05089313,0.04325916,0.18677036,0.15875473]

def lambda_handler(event, context):
    node = event.get('node')

    if node:
        response = {'nodes':{node:pr[node]},'edges' : {}}
    else:
        response = {'nodes': {'node': [9, 10, 1, 2, 3], 'pagerank': pr}, 'edges': {'sources': [1, 2, 9, 10], 'targets': [2, 3, 10, 1], 'weights': [1, 1, 1, 1]}}

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': response
    }
