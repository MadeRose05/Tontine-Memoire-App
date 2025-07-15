import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import { UseGuards } from '@nestjs/common/decorators/core/use-guards.decorator';
import { AuthUser } from 'src/users/users.decorator';
import { AuthGuard } from 'src/users/users.guard';
import { CreatePoolDto } from './dto/create-pool.dto';
import { UpdatePoolDto } from './dto/update-pool.dto';
import { PoolService } from './pool.service';
import { ApiTags,ApiOperation,ApiBody, ApiParam, ApiBearerAuth } from '@nestjs/swagger';

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
  create(@Body() createPoolDto: CreatePoolDto, @AuthUser() id: string) {
    return this.poolService.create(createPoolDto, id);
  }

  @Get()
  findAll(@AuthUser() userId: string) {
    return this.poolService.findAllPool(userId);
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
    @AuthUser() msisdn: string,
    @Param('code') code: string,
  ) {
    return await this.poolService.joinPool(code, msisdn);
  }

  @Delete()
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.poolService.deleteOnePool(id);
  }
}
