import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { PoolMembersService } from './pool-members.service';
import { CreatePoolMemberDto } from './dto/create-pool-member.dto';
import { UpdatePoolMemberDto } from './dto/update-pool-member.dto';
import { ApiBody, ApiOperation, ApiTags } from '@nestjs/swagger';

@Controller({ path: 'participant' })
@ApiTags('Participants')
export class PoolMembersController {
  constructor(private readonly poolMembersService: PoolMembersService) {}

  // @Post()
  // @ApiOperation({ summary: 'create participant' })
  // @ApiBody({ type: CreatePoolMemberDto })
  // create(@Body() createPoolMemberDto: CreatePoolMemberDto) {
  //   return this.poolMembersService.create(createPoolMemberDto);
  // }

  @Get()
  findAll() {
    return this.poolMembersService.findAll();
  }
  @ApiOperation({ summary: 'get participant by id' })
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.poolMembersService.findOne(+id);
  }

  // @Patch(':id')
  // update(
  //   @Param('id') id: string,
  //   @Body() updatePoolMemberDto: UpdatePoolMemberDto,
  // ) {
  //   return this.poolMembersService.update(+id, updatePoolMemberDto);
  // }

  @Delete(':id')
  @ApiOperation({ summary: 'delete participant' })
  remove(@Param('id') id: string) {
    return this.poolMembersService.remove(+id);
  }
}
