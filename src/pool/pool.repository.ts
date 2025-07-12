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

    try {
      return await this.prismaService.tontine.create({
        data: {
          ...body,
          wallet: {
            create: {
              amount: 0,
            },
          },
        },
      });
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

 

  async findOnePool(id: string): Promise<any | Tontine> {
    try {
      const data = await this.prismaService.tontine.findUnique({
        where: { id },
        include: { wallet: true, participants: true, owner: true },
      });
      if (!data) return new NotFoundException({ message: 'Pool not found' });

      return data;
    } catch (error) {
      return new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  async findByInviteCode(code: number): Promise<any> {
    try {
      const data = await this.prismaService.tontine.findFirst({
        where: {
          inviteCode: code,
        },
      });
      if (!data)
        return new NotFoundException({
          message: `tontine with invite code ${code} code not found`,
        });

      return data;
    } catch (error) {
      return new HttpException(error.message, HttpStatus.NOT_FOUND);
    }
  }

  async findAllPool() {
    try {
      return await this.prismaService.tontine.findMany({
        include: { wallet: true, participants: true, owner: true },
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
