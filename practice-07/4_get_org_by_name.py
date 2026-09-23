'''
    You must replace <FMI_1> with the name of the table attribute that specifies the exact name of the organization
    You must replace <FMI_2> with the value of the partition key used for identifying the organization whose name we pass to the `get_one_item` function in the `org_name` function attribute
    You must replace <FMI_3> with the value of the sort key used for identifying the organization (refer to the table items you explored previously)
'''

import boto3, json
import time
from boto3.dynamodb.conditions import Key

def get_one_item_using_scan(org_name):
    DDB = boto3.resource('dynamodb', region_name='us-east-1')
    table = DDB.Table('Organizations')
    start = time.time()
    response = table.scan(FilterExpression=Key('<FMI_1>').eq(org_name))
    data = response['Items']

    while response.get('LastEvaluatedKey'):
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    end = time.time()
    print (f"execution time: {end - start}s")
    print (data[0])

def get_one_item(org_name):

    DDB = boto3.client('dynamodb', region_name='us-east-1')

    PK = "<FMI_2>"
    SK = "<FMI_3>"
    start = time.time()
    response = DDB.get_item(TableName='Organizations',
        Key={
         'PK': {'S': PK},
         'SK': {'S': SK}
         }
        )

    data = response['Item']
      
    end = time.time()
    print (f"execution time: {end - start}s")
    print (data)
 
if __name__ == '__main__':
    org_name = "10_ORG"
    print("GET one item using get_item")
    get_one_item(org_name)
    print("GET one item using scan")
    get_one_item_using_scan(org_name)
