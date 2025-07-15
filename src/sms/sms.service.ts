import { Injectable } from '@nestjs/common';
import * as dotenv from 'dotenv';
import * as nodemailer from 'nodemailer';
import fetch from 'node-fetch';

dotenv.config();

@Injectable()
export class SmsService {
  async getAccessToken(): Promise<string> {
    const url = 'https://api.orange.com/oauth/v3/token';
    const headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      Authorization: `Basic ${process.env.SMS_HEADER!}`,
    };
    const body = new URLSearchParams();
    body.append('grant_type', 'client_credentials');

    const response = await fetch(url, {
      method: 'POST',
      headers,
      body,
    });

    if (!response.ok) {
      throw new Error(
        `Erreur lors de la récupération du token: ${response.statusText}`,
      );
    }

    const data = await response.json();
    return data.access_token;
  }

  async sendSms(to: string, message: string): Promise<any> {
    const accessToken = await this.getAccessToken();
    const senderAddress = process.env.SMS_SENDER_ADDRESS || 'tel:+2250779400916';
    const url = `https://api.orange.com/smsmessaging/v1/outbound/${encodeURIComponent(senderAddress)}/requests`;

    const headers = {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`,
    };

    const body = JSON.stringify({
      outboundSMSMessageRequest: {
        address: `tel:+${to}`,
        senderAddress: senderAddress,
        outboundSMSTextMessage: {
          message: message,
        },
      },
    });

    const response = await fetch(url, {
      method: 'POST',
      headers,
      body,
    });

    if (!response.ok) {
      throw new Error(
        `Erreur lors de l'envoi du SMS: ${response.statusText}`,
      );
    }

    return await response.json();
  }
}
