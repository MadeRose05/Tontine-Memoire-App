import * as dotenv from 'dotenv';
import * as nodemailer from 'nodemailer';
import { deleteOtpTask } from './delete_otp';

dotenv.config();

const FROM_EMAIL: string = process.env.SENDER_MAIL!;
const FROM_MAIL_PASSWORD: string = process.env.SENDER_MAIL_PASSWORD!;

const sendEmail = ({
  msisdn,
  name,
  otp,
}: {
  msisdn: string;
  name: string;
  otp: number;
}) => {
  const TO_EMAIL: string = msisdn;
  //Creating transporter
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: FROM_EMAIL,
      pass: FROM_MAIL_PASSWORD,
    },
  });

  // Define the message to be sent
  const mailMessage = {
    from: `"TONTINO App" <${FROM_EMAIL}>`,
    to: TO_EMAIL,
    subject: `Verify Account -  ${name}`,
    html: `
            <div style="padding: 10px 0;">
                <h3> ${name} thank you for registering on our application! </h3> 
                <h4> Enter OTP below to verify your email </h4>
                <a style="border-radius: 5px;font-size:20px; margin-bottom: 10px; text-decoration: none; color: white; padding: 10px 20px; cursor: pointer; background: #008D41;"> 
                ${otp} </a>
                <p> And please note that this will expire in two hours </p>
            </div>
            `,
  };
  // Send the message using the created transport object
  
};

export { sendEmail };
