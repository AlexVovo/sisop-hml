import os
import resend
from typing import Dict
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

resend.api_key = os.environ["RESEND_API_KEY"]

app = FastAPI()

# Configurar CORS
origins = [
    "http://localhost:60180",  # Substitua pela URL do seu frontend, se necessário
    "http://127.0.0.1:8000",   # Para permitir acesso local
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],  # Permite todos os métodos
    allow_headers=["*"],  # Permite todos os cabeçalhos
)

@app.post("/send-email")
def send_mail(email_to: str) -> Dict:
    params: resend.Emails.SendParams = {
        "from": "onboarding@resend.dev",
        "to": "alexavilanew@gmail.com",
        "subject": "Hello World",
        "html": "<strong>it works!</strong>",
    }
    email = resend.Emails.send(params)
    return {"message": "Email sent successfully!", "email_id": email.id}
