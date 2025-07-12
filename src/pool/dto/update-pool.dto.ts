import {
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { TimeType } from './create-pool.dto';
import { ApiProperty } from '@nestjs/swagger';

export class UpdatePoolDto {
  @ApiProperty()
  @IsString()
  @IsOptional()
  nom: string;
  @ApiProperty()
  @IsString()
  @IsOptional()
  description: string;

    @IsInt()
    @IsOptional()
    totalRound: number;
  @ApiProperty()
    @IsString()
    @IsOptional()
    @IsEnum(TimeType)
    frequence: TimeType;
  @ApiProperty()
    @IsNumber()
    @IsOptional()
    @Min(3)
    cotisation: number;
  @ApiProperty()
    @IsDateString()
    @IsOptional()
    startDate: string;
  
 
  // @IsDateString()


 
}
