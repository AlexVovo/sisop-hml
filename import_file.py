#!/usr/bin/env python

from config import config
import requests

file = 'E:/registroici_SRSOP/teste.txt'


fields = {
    'token': config['39AE91C50C41DA5112941F3EA9FCC1CB'],
    'content': 'file',
    'action': 'import',
    'record': 'hcpa04',
    'field': 'pdfdoexame',
    'event': 'event_1_arm_1',
    'returnFormat': 'json'
    # 'file': (pycurl.FORM_FILE, file)
}

# fields['returnFormat'] = 'json';

file_obj = open(file_path, 'rb')
r = requests.post(config['https://redcap.ufcspa.edu.br/api/'],data=fields,files={'file':file_obj})
file_obj.close()

print('HTTP Status: ' + str(r.status_code))
print(r.text)