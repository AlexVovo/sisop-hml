# rhcICI

## Ambiente de homologação

A branch `homologacao` usa um projeto Firebase independente. Ela não reutiliza
o Firebase de produção e falha ao iniciar se a configuração de homologação não
for informada.

1. Crie outro projeto no Firebase Console.
2. Nesse projeto, habilite Authentication e Cloud Firestore e cadastre os apps
   necessários (Web, Android e/ou iOS).
3. Copie `config/homologacao.example.json` para
   `config/homologacao.json` e substitua os valores pelos dados do novo projeto.
   O arquivo real é ignorado pelo Git.
4. Execute ou gere o aplicativo passando a configuração:

```bash
flutter run -d chrome --dart-define-from-file=config/homologacao.json
flutter build web --dart-define-from-file=config/homologacao.json
```

As contas do Authentication, documentos do Firestore, regras e índices também
devem ser criados no projeto de homologação; eles não são compartilhados com o
projeto de produção.

Nesta branch, os identificadores móveis são `com.example.registroici.hml` no
Android e no iOS. Isso permite instalar homologação e produção no mesmo aparelho
sem compartilhar a configuração nativa do Firebase.

Os serviços auxiliares de envio de e-mail exigem a variável de ambiente
`RESEND_API_KEY`; chaves privadas não devem ser armazenadas no repositório.
