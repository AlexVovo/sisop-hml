const express = require('express');
const { Resend } = require('resend');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const resend = new Resend(process.env.RESEND_API_KEY);

app.post('/send-email', async (req, res) => {
  const { to } = req.body;

  console.log('Request received to send email to:', to);

  try {
    const response = await resend.emails.send({
      from: 'onboarding@ici.ong',
      to: [to],
      subject: 'Hello World',
      html: '<p>It works!</p>',
    });

    console.log('Email sent successfully:', response);
    res.status(200).send({ message: 'Email sent successfully!', response });
  } catch (error) {
    console.error('Error sending email:', error);
    res.status(500).send({ message: 'Failed to send email', error });
  }
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
