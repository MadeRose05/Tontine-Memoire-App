import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsArray,
  IsDateString,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export enum TimeType {
  DAYS = 'Day',
  WEEKS = 'Week',
  MONTHS = 'Month',
}

export class CreatePoolDto {
  @ApiProperty({
    description: 'Nom de la tontine',
    example: 'string',
  })
  @IsString()
  @IsNotEmpty()
  nom: string;
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description: string;
  @ApiProperty()
  @IsInt()
  @IsNotEmpty()
  totalRound: number;
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  @IsEnum(TimeType)
  frequence: TimeType;
  @ApiProperty()
  @IsNumber()
  @IsNotEmpty()
  @Min(1)
  cotisation: number;
  @ApiProperty()
  @IsDateString()
  @IsNotEmpty()
  startDate: string;

  @IsOptional()
  inviteCode: number;
  @ApiProperty()
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  participants: string[];
  @IsOptional()
  createdBy: string;
}
