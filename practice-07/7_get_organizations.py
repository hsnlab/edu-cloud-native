'''
    You must replace <FMI_1> with the name of the index which supports querying by Type
'''
import time
import boto3
from boto3.dynamodb.conditions import Key
from boto3.dynamodb.conditions import Key, Attr, And


def get_organizations_scan():
    import boto3

    DDB = boto3.resource('dynamodb', region_name='us-east-1')

    table = DDB.Table('Organizations')
    start = time.time()
    response = table.scan(FilterExpression=Attr('Type').eq('organization'), IndexName="<FMI_1>")
    data = response['Items']
    
    while response.get('LastEvaluatedKey'):
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    end = time.time()
    print (f"execution time: {end - start}s")
    print(f"found {len(data)} organizations")
    
def get_organizations_query():
    import boto3

    DDB = boto3.client('dynamodb', region_name='us-east-1')

    start = time.time()
    response = DDB.query(TableName='Organizations',
        IndexName='<FMI_1>',
        ExpressionAttributeValues={
            ':org': {
                'S': 'organization',
            }
        },
        ExpressionAttributeNames={
            "#type": "Type"
        },
        KeyConditionExpression='#type = :org')

    data = response['Items']
    
    end = time.time()
    print (f"execution time: {end - start}s")
    print(f"found {len(data)} organization")
    
if __name__ == '__main__':
    print("GET organizations using scan")
    get_organizations_scan()
    print("GET organizations using query")
    get_organizations_query()


"""
Copyright @2021 [Amazon Web Services] [AWS]
    
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
