'''
    You must replace <FMI_1> with a sort key value to return all users of the organization
'''
import time
import boto3
from boto3.dynamodb.conditions import Key
from boto3.dynamodb.conditions import Key, Attr, And


def get_users_by_org_scan():
    import boto3

    DDB = boto3.resource('dynamodb', region_name='us-east-1')

    table = DDB.Table('Organizations')
    start = time.time()
    response = table.scan(FilterExpression=And(Attr('PK').eq('ORG#10_ORG'), Attr('Type').eq('user')))
    data = response['Items']
    
    while response.get('LastEvaluatedKey'):
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    end = time.time()
    print (f"execution time: {end - start}s")
    print(f"found {len(data)} users")
    
def get_users_by_org_query():
    import boto3

    DDB = boto3.client('dynamodb', region_name='us-east-1')

    start = time.time()
    response = DDB.query(TableName='Organizations',
        ExpressionAttributeValues={
            ':org10': {
                'S': 'ORG#10_ORG',
            },
            ':user': {
                'S': '<FMI_1>'
            }
        },
        KeyConditionExpression='PK = :org10 AND begins_with(SK, :user)')

    data = response['Items']
    
    end = time.time()
    print (f"execution time: {end - start}s")
    print(f"found {len(data)} users")
    
if __name__ == '__main__':
    print("GET users of ORG10 using scan")
    get_users_by_org_scan()
    print("GET users of ORG10 using query")
    get_users_by_org_query()
