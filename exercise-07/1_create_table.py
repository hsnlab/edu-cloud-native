'''
    You must replace <FMI_1> with the table name
    You must replace <FMI_2> with the tyoe of the sort key (RANGE)
'''


import boto3

def create_table():

    DDB = boto3.resource('dynamodb', region_name='us-east-1')

    params = {
        'TableName': '<FMI_1>',
        'KeySchema': [
            {'AttributeName': 'PK', 'KeyType': 'HASH'}, # partition key
            {'AttributeName': 'SK', 'KeyType': '<FMI_2>'} # sort key
        ],
        'AttributeDefinitions': [
            {'AttributeName': 'PK', 'AttributeType': 'S'},
            {'AttributeName': 'SK', 'AttributeType': 'S'}
        ],
        'ProvisionedThroughput': {
            'ReadCapacityUnits': 1,
            'WriteCapacityUnits': 1
        }
    }
    table = DDB.create_table(**params)
    table.wait_until_exists()
    print ("Done")
    

if __name__ == '__main__':
    create_table()


