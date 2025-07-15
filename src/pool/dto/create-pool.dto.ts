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
export class ParticipantDto {
  @ApiProperty({
    description: 'Numéro de téléphone du participant',
    example: '770000000',
  })
  @IsString()
  @IsNotEmpty()
  msisdn: string;

  @ApiProperty({ description: 'Nom du participant', example: 'Jean' })
  @IsString()
  @IsNotEmpty()
  nom: string;

  @ApiProperty({ description: 'Tour du participant', example: 1 })
  @IsInt()
  @IsNotEmpty()
  round: number;
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
  inviteCode: string;
  @ApiProperty({
    description: 'Liste des participants',
    type: [ParticipantDto],
  })
  @IsArray()
  participants: ParticipantDto[];
  @IsOptional()
  createdBy: string;
}
