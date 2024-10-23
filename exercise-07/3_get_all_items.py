'''
    You must replace <FMI_1> with the table name
'''
import time
import boto3

def get_all_items():
    import boto3

    DDB = boto3.resource('dynamodb', region_name='us-east-1')

    table = DDB.Table('<FMI_1>')
    start = time.time()
    response = table.scan()
    data = response['Items']
    
    while response.get('LastEvaluatedKey'):
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        data.extend(response['Items'])
    end = time.time()
    print (f"execution time: {end - start}s")
    
if __name__ == '__main__':
    get_all_items()

