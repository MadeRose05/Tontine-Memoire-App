import {
  IsAlpha,
  IsDefined,
  IsEmail,
  IsPhoneNumber,
  IsStrongPassword,
  Length,
} from 'class-validator';

export class CreateUserDto {
  //User account info
  @IsEmail()
  @IsDefined({ message: 'please enter email' })
  name: string;

  @Length(5, 15)
  @IsDefined({ message: 'password required' })
  @IsStrongPassword(undefined, { message: 'please enter a strong password' })
  pin: string;

  @IsDefined({ message: 'phone number required' })
  @IsPhoneNumber('RW', {
    message: 'please enter a valid phone number',
  })
  msisdn: string;
 
}
