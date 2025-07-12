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
}
