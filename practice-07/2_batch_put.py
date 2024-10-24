'''
    You must replace <FMI_1> with the table name
'''

import boto3, json


def batch_put():
    DDB = boto3.resource('dynamodb', region_name='us-east-1')
    table = DDB.Table('<FMI_1>')
    with table.batch_writer() as batch:
        for i in range(20): # upload 20 organizations
            org_name = f"{i}_ORG"
            batch.put_item(Item={
                'PK': f'ORG#{org_name}',
                'SK': 'METADATA',
                'Type': 'organization',
                'OrgName': org_name
            })
            
            for j in range(100): # add 100 users to each organization
                user_name = f"{i}_USER#{j}"
                batch.put_item(Item={
                    'PK': f'ORG#{org_name}',
                    'SK': f'USER#{user_name}',
                    'Type': 'user',
                    'UserName': user_name
                })

   
if __name__ == '__main__':
    batch_put()#

