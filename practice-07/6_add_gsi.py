'''
    You must replace <FMI_1> with the attribute that describes the type of the given DynamoDB record
'''

import boto3
from boto3.dynamodb.conditions import Key

def update_table():

    DDB = boto3.client('dynamodb', region_name='us-east-1')

    params = {
        'TableName': 'Organizations',
        'AttributeDefinitions': [
            {'AttributeName': '<FMI_1>', 'AttributeType': 'S'}
        ],
        'GlobalSecondaryIndexUpdates': [
            {
                'Create': {
                    'IndexName': '<FMI_1>_GSI',
                    'KeySchema': [
                        {
                            'AttributeName': '<FMI_1>',
                            'KeyType': 'HASH'
                        }
                    ],
                        'Projection': {
                        'ProjectionType': 'ALL'
                    },
                        'ProvisionedThroughput': {
                        'ReadCapacityUnits': 1,
                        'WriteCapacityUnits': 1
                    }
                }
            }
        ]
    }

    table = DDB.update_table(**params)
    print ('Done')
    

if __name__ == '__main__':
    update_table()

