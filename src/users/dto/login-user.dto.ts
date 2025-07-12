import { ApiProperty } from '@nestjs/swagger';
import { IsDefined, IsEmail, IsString, IsStrongPassword, Length } from 'class-validator';

export class LoginUserDto {
  @ApiProperty()
  @IsString()
  @IsDefined({ message: 'please enter email' })
  msisdn: string;

  @ApiProperty()
  @IsDefined({ message: 'pin required' })
  pin: string;
}
