import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsNumber, IsString } from 'class-validator';

export class CotisationDto {
  @ApiProperty()
  @IsNumber()
  tour: number;
  @ApiProperty()
  @IsString()
  tontineId: string;
}
export class RappelCotisationDto {
  @ApiProperty()
  @IsString()
  message: string;
  @ApiProperty()
    @IsArray()
  @IsString({each:true})
  numbers: string[];
}
