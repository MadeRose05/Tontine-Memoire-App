import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsString } from 'class-validator';

export class CotisationDto {
  @ApiProperty()
  @IsNumber()
  tour: number;
  @ApiProperty()
  @IsString()
  tontineId: string;
}
