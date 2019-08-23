import requests
import sys,os
import base64
import sys
import datetime
import time
import urllib
import jwt

auth0_secret = os.environ['PSAMA_CLIENT_SECRET']
expire_time = 2
psamaURL="http://wildfly:8080/pic-sure-auth-service"
signature = base64.b64decode(auth0_secret.replace("_","/").replace("-","+"))
token = jwt.encode({
    'sub': "temporary_picsure_admin",
    "exp": int(time.time())+(expire_time*60*60),
    "iat": int(time.time())
    },
    auth0_secret,algorithm='HS256')
print(token.decode('utf-8'))

def addApplication(app_name, app_description, app_url=''):
  print('Adding application')

  requestBody = [{"uuid":"","name":"${app_name}","description":"${app_description}","url":"${app_url}"}]
  r = requests.post(psamaURL+'/application', json=requestBody)
  print("addApplication() response status: {}".format(r.status_code))

def addPrivilege(privilege_name, privilege_description):
  print('Adding privilege')

def assignPrivilegeToApplication(privilege_name, application_name):
  print('Assign privilege to application')

addApplication('IRCT','IRCT data access API interface')
#addApplication('PICSURE','PICSURE multiple datasource API interface','/picsureui')

# Configure i2b2/tranSmart authorization
#addApplication('TRANSMART','i2b2/tranSmart web application','/transmart')
#addPrivilege('TM_ADMIN')
#assignPrivilegeToApplication('TM_ADMIN','TRANSMART')
#addPrivilege('TM_STUDY_OWNER')
#addPrivilege('TM_DATASET_EXPLORER')
#addPrivilege('TM_USER')
#addRole('TM_ADMIN')
#addRole('TM_LEVEL1')
#addRole('TM_LEVEL2')
