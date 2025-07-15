import {
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class PoolMembersRepository {
  constructor(private prismaService: PrismaService) {}

  async findPoolMembership(msisdn: string, tontineId: string): Promise<any> {
    try {
      const poolMembership = await this.prismaService.invitation.findFirst({
        where: {
          msisdn,
          tontineId,
        },
       
      });
      if (!poolMembership)
       throw new NotFoundException({ message: 'Pool membership not found' });

      return poolMembership;
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  async createMembership(round:number,userId:string,tontineId:string) {
    return await this.prismaService.participants.create({
      data: {
        round,
        tontineId,
        userId
      }
    })
  }
}
