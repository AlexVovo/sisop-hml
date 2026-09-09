from flask import Flask, request, jsonify
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)  # Habilita CORS para todos os domínios

@app.route('/upload_pdf', methods=['POST'])
def upload_pdf():
    token = request.form['token']
    ultimoId = request.form['ultimoId']
    file = request.files['file']
    
    fields = {
        'token': token,
        'content': 'file',
        'action': 'import',
        'record': ultimoId,
        'field': 'pdfdoexame',
        'event': 'event_1_arm_1',
        'returnFormat': 'json'
    }

    file_obj = file.read()
    r = requests.post('https://redcap.ufcspa.edu.br/api/', data=fields, files={'file': ('file.pdf', file_obj)})
    
    response = {
        'status_code': r.status_code,
        'response_text': r.text
    }
    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True)
