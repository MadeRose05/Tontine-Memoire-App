import { HttpException, HttpStatus, NotFoundException } from '@nestjs/common';
import { Injectable } from '@nestjs/common/decorators';
import { Tontine } from '@prisma/client';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreatePoolDto } from './dto/create-pool.dto';

@Injectable()
export class PoolRepository {
  constructor(private prismaService: PrismaService) {}

  async createPool(createPool: CreatePoolDto) {
    const body = {
      nom: createPool.nom,
      cotisation: createPool.cotisation,
      description: createPool.description,
      startDate: createPool.startDate,
      frequence: createPool.frequence,
      totalRound: createPool.totalRound,
      inviteCode:createPool.inviteCode,
      createdBy:createPool.createdBy,
    }
    const participants = createPool.participants
    const owener = await this.prismaService.user.findFirst({
      where: { id: createPool.createdBy },
    })
    let owenerRound = participants.find((user) => user.msisdn == owener.msisdn);
    if (!owenerRound) return new NotFoundException({ message: 'owner not found in participants list' });

 
    try {
      const pool = await this.prismaService.tontine.create({
        data: {
          ...body,
          wallet: {
            create: {
              amount: 0,
            },
          },
        },
      });
      participants.map(async(user) => {
        if (user.msisdn != owener.msisdn) {
          await this.prismaService.invitation.create({
            data: {
              ...user,
              tontineId: pool.id,
            },
          });
       }
      });
      let owenerRound = participants.find(user => user.msisdn == owener.msisdn)
      await this.prismaService.participants.create({
        data: {
          
          tontineId: pool.id,
          userId: body.createdBy,
          round:owenerRound.round
        }
      })
      return pool;
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async updateOnePool(id: string, data: any) {
    try {
      return await this.prismaService.tontine.update({
        where: { id },
        data,
      });
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

 

  async findOnePool(code: string): Promise<any | Tontine> {
    try {
      const data = await this.prismaService.tontine.findFirst({
        where: {  inviteCode:code},
        include: {
          wallet: true,
          participants: {
            include: {
              user: {
                select: {
                  id: true,
                  msisdn: true,
                  name: true,
                },
              },
            },
          },
          owner: {
            select: {
              id: true,
              msisdn: true,
              name: true,
            },
          },
        },
      });
      if (!data) throw new NotFoundException({
        message: `tontine with invite code ${code} code not found`,
      });

      return data;
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  async findByInviteCode(code: string): Promise<any> {
    try {
      const data = await this.prismaService.tontine.findFirst({
        where: {
          inviteCode: code,
        },
      });
      if (!data)
        throw new NotFoundException({
          message: `tontine with invite code ${code} code not found`,
        });

      return data;
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  async findAllPool(id:string) {
    try {
      return await this.prismaService.tontine.findMany({
        where: { createdBy: id },
        include: {
          wallet: true,
          participants: {
            include: {
              user: {
                select: {
                  id: true,
                  msisdn: true,
                  name: true,
                },
              },
            },
          },
          owner: {
            select: {
              id: true,
              msisdn: true,
              name: true,
            },
          },
        },
      });
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async deleteOnePool(id: string) {
    try {
      return await this.prismaService.tontine.delete({ where: { id } });
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

  async deleteAllPool() {
    try {
      return await this.prismaService.tontine.deleteMany();
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}
