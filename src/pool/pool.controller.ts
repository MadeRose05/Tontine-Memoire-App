import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { UseGuards } from '@nestjs/common/decorators/core/use-guards.decorator';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { AuthUser, AuthUserMsisdn } from 'src/users/users.decorator';
import { AuthGuard } from 'src/users/users.guard';
import { CotisationDto, RappelCotisationDto } from './dto/cotisation.dto';
import { CreatePoolDto } from './dto/create-pool.dto';
import { UpdatePoolDto } from './dto/update-pool.dto';
import { PoolService } from './pool.service';

@Controller({
  path: 'tontine',
})
@ApiBearerAuth('Authorization')
@ApiTags('tontines')
@UseGuards(AuthGuard)
export class PoolController {
  constructor(private readonly poolService: PoolService) {}

  @Post()
  @ApiOperation({ summary: 'create tontine' })
  @ApiBody({ type: CreatePoolDto })
  async create(@Body() createPoolDto: CreatePoolDto, @AuthUser() id: string) {
    return await this.poolService.create(createPoolDto, id);
  }

  @Get()
  async findAll(@AuthUserMsisdn() msisdn: string) {
    console.log('msisdn', msisdn);
    return await this.poolService.getUserTontinesByMsisdn(msisdn);
  }

  @Get(':code')
  async findOne(@Param('code') code: string) {
    return await this.poolService.findOnePool(code);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'update tontine' })
  @ApiBody({ type: UpdatePoolDto })
  updatePool(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updatePoolDto: UpdatePoolDto,
    @AuthUser() userId: string,
  ) {
    return this.poolService.updatePool(id, userId, updatePoolDto);
  }

  // @Post('/inviteCode/:id')
  // generateInviteCode(
  //   @Param('id', ParseUUIDPipe) id: string,
  //   @AuthUser() userId: string,
  // ) {
  //   return this.poolService.poolInvitationCode(id, userId);
  // }

  @Post('/join/:code')
  @ApiOperation({ summary: 'Join tontine' })
  @ApiParam({
    name: 'code',
  })
  async requestJoinPool(
    @AuthUserMsisdn() msisdn: string,
    @Param('code') code: string,
  ) {
    return await this.poolService.joinPool(code, msisdn);
  }
  @Post('/cotisation')
  @ApiOperation({ summary: 'envoyer sa cotisation' })
  async sendCollecte(
    @AuthUserMsisdn() msisdn: string,
    @Body() data: CotisationDto,
  ) {
    return await this.poolService.sendCotisation(msisdn, data);
  }
  @Post('/rappel')
  @ApiOperation({ summary: 'envoyer un sms de rappel' })
  async sendRappel(
    @Body() data: RappelCotisationDto,
  ) {
    return await this.poolService.cotisationRapel( data);
  }

  @Delete()
  @ApiParam({
    name: 'id',
  })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.poolService.deleteOnePool(id);
  }
}
