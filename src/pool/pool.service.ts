import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import { generate } from 'otp-generator';
import { EmailService } from 'src/emails/emails.service';
import { PoolMembersRepository } from 'src/pool-members/pool-members.repository';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreatePoolDto } from './dto/create-pool.dto';
import { InviteResponse } from './dto/invite-response.dto';
import { UpdatePoolDto } from './dto/update-pool.dto';
import { PoolRepository } from './pool.repository';

@Injectable()
export class PoolService {
  constructor(
    private poolRepository: PoolRepository,
    private prismaService: PrismaService,
    private emailService: EmailService,
    private poolMembersRepository: PoolMembersRepository,
  ) {}

  async create(createPoolDto: CreatePoolDto, userId: string) {
    try {
      // generate invitation code
      const inviteCode = Number(
        generate(6, {
          digits: true,
          upperCaseAlphabets: true,
          specialChars: false,
          lowerCaseAlphabets: false,
        }),
      );
      createPoolDto.inviteCode = inviteCode;
      createPoolDto.createdBy = userId;
      const pool = await this.poolRepository.createPool(createPoolDto);
      return pool;
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async updatePool(id: string, userId: string, updatePool: UpdatePoolDto) {
    try {
      const findPool = await this.poolRepository.findOnePool(id);
      if (findPool.createdBy !== userId) {
        throw new BadRequestException("Pool doesn't belong to you");
      }
      return await this.poolRepository.updateOnePool(id, updatePool);
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // endpoint to create pool invitation code
  async poolInvitationCode(poolId: string, userId: string) {
    try {
      const findPool = await this.poolRepository.findOnePool(poolId);
      if (findPool.createdBy !== userId) {
        throw new BadRequestException("Pool doesn't belong to you");
      }
      const inviteCode = Number(
        generate(4, {
          digits: true,
          upperCaseAlphabets: false,
          specialChars: false,
          lowerCaseAlphabets: false,
        }),
      );
      const updatePool = await this.poolRepository.updateOnePool(poolId, {
        inviteCode,
      });
      return { message: 'Invitation code created', data: updatePool };
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // endpoint to approve/reject user (ADMIN)
  async respondToJoin(inviteResponse: InviteResponse) {
    try {
      const { msisdn, poolId, status } = inviteResponse;
      // get pool membership
      const poolMembership =
        await this.poolMembersRepository.findPoolMembership(msisdn, poolId);

      const user = poolMembership.member;
      const pool = poolMembership.pool;

      if (status === 'ACCEPTED') {
      }

      // update (accept or reject)
      // if update => add user to pool
      //    update user model
      //    update poolMembership
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  // activate and start pool when all users are available
  async activatePool(poolId: string) {
    try {
      const findPool = await this.poolRepository.findOnePool(poolId);
      const invitedMembers = findPool.poolMembers?.length;
      const currentMembers = findPool.numberOfParticipants?.length;
      if (invitedMembers != currentMembers)
        return new BadRequestException('Not enough users to activate the pool');

      return { message: 'Pool activated' };
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async findOnePool(id: string) {
    try {
      return await this.poolRepository.findOnePool(id);
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  async findAllPool(id: string) {
    try {
      return await this.poolRepository.findAllPool(id);
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  update(id: number, updatePoolDto: UpdatePoolDto) {
    return `This action updates a #${id} pool`;
  }

  async deleteOnePool(id: string) {
    try {
      return await this.poolRepository.deleteOnePool(id);
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async deleteAllPool() {
    return await this.poolRepository.deleteAllPool();
  }
  async joinPool(code: number, msisdn: string) {
    const findPool = await this.poolRepository.findByInviteCode(code);
  }
}
