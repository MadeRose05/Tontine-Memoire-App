import { IsDefined, IsEmail, IsNumber, IsPositive, IsString, Max } from 'class-validator';

export class VerifyUserDto {
  @IsString()
  @IsDefined({ message: 'please enter email' })
  msisdn: string;

  @IsDefined({ message: 'please enter an otp' })
  @IsNumber()
  @IsPositive()
  @Max(9999, { message: 'OTP must have 4 digits' })
  otp: number;
}
