import { Injectable } from '@nestjs/common';
import * as dotenv from 'dotenv';
import fetch from 'node-fetch';

dotenv.config();

@Injectable()
export class SmsService {
  async sendSms(to: string, message: string): Promise<any> {
    const url = 'https://lamsms.lafricamobile.com/api';

    const payload = {
      accountid: process.env.LAFRICAMOBILE_ACCOUNT_ID!,
      password: process.env.LAFRICAMOBILE_PASSWORD!,
      sender: process.env.LAFRICAMOBILE_SENDER || 'API_LAMSMS',
      ret_id: 'Push_1',
      ret_url:
        process.env.LAFRICAMOBILE_RET_URL || 'https://mon-site.com/reception',
      priority: '2',
      text: message,
      to: [
        {
          ret_id_1: to,
        },
      ],
    };

    const headers = {
      'Content-Type': 'application/json',
    };

    const response = await fetch(url, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error(`Erreur lors de l'envoi du SMS: ${response.statusText}`);
    }

    const data = await response.json();
    return data;
  }
}
