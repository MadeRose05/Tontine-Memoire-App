import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
} from '@nestjs/common';
import { generate } from 'otp-generator';
import { EmailService } from 'src/emails/emails.service';
import { PoolMembersRepository } from 'src/pool-members/pool-members.repository';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreatePoolDto } from './dto/create-pool.dto';
import { InviteResponse } from './dto/invite-response.dto';
import { UpdatePoolDto } from './dto/update-pool.dto';
import { PoolRepository } from './pool.repository';
import { CotisationDto, RappelCotisationDto } from './dto/cotisation.dto';
import { SmsService } from 'src/sms/sms.service';

@Injectable()
export class PoolService {
  private logger = Logger;
  constructor(
    private poolRepository: PoolRepository,
    private prismaService: PrismaService,
    private smsService: SmsService,
    private poolMembersRepository: PoolMembersRepository,
  ) {}

  async create(createPoolDto: CreatePoolDto, userId: string) {
    try {
      // generate invitation code
      const inviteCode = String(
        generate(6, {
          digits: true,
          upperCaseAlphabets: true,
          specialChars: false,
          lowerCaseAlphabets: false,
        }),
      );
      createPoolDto.inviteCode = inviteCode;
      createPoolDto.createdBy = userId;
      return await this.poolRepository.createPool(createPoolDto);
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
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
      if (!poolMembership) {
        return new HttpException(
          'Tontine membership not found',
          HttpStatus.NOT_FOUND,
        );
      }
      this.logger.log('invitation', poolMembership);
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
  async cotisationRapel(data: RappelCotisationDto) {
    data.numbers.map(async (msisdn) => {
      await this.smsService.sendSms(msisdn, data.message);
    });
    return {
      message: 'sms envoyé avec succès',
    };
  }
  async findOnePool(id: string) {
    return await this.poolRepository.findOnePool(id);
  }
  async findAllPool(id: string) {
    try {
      return await this.poolRepository.findAllPool(id);
    } catch (error) {
      return new HttpException(error.message, HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
  async getUserTontinesByMsisdn(msisdn: string) {
    // Récupère l'utilisateur via son msisdn
    const user = await this.prismaService.user.findUnique({
      where: { msisdn },
      select: {
        id: true,
        createdTontine: {
          include: {
            participants: {
              include: {
                user: true,
                Transaction: true,
              },
            },
            Transaction: true,
            wallet: true,
          },
        },
        Participants: {
          include: {
            tontine: {
              include: {
                participants: {
                  include: {
                    user: true,
                    Transaction: true,
                  },
                },
                Transaction: true,
                wallet: true,
              },
            },
          },
        },
      },
    });

    if (!user) {
      throw new Error('Utilisateur non trouvé');
    }

    // Tontines qu'il a créées
    const createdTontines = user.createdTontine;

    // Tontines auxquelles il participe (extraites de Participants)
    const participantTontines = user.Participants.map((p) => p.tontine);

    // Fusionner et éviter les doublons (au cas où il est à la fois créateur et participant)
    const allTontinesMap = new Map();

    for (const t of [...createdTontines, ...participantTontines]) {
      allTontinesMap.set(t.id, t);
    }

    const allTontines = Array.from(allTontinesMap.values());

    return allTontines;
  }
  async sendCotisation(userMsisdn: string, data: CotisationDto): Promise<any> {
    const user = await this.prismaService.user.findUnique({
      where: { msisdn: userMsisdn },
    });

    if (!user) {
      throw new BadRequestException('Utilisateur non trouvé');
    }

    const tontine = await this.prismaService.tontine.findUnique({
      where: { id: data.tontineId },
      include: {
        participants: true,
      },
    });

    if (!tontine) {
      throw new BadRequestException('Tontine introuvable');
    }

    const isParticipant = tontine.participants.find(
      (p) => p.userId === user.id,
    );

    if (!isParticipant) {
      throw new BadRequestException('Vous ne participez pas à cette tontine');
    }

    // Optionnel : vérifier que l'utilisateur n'a pas déjà cotisé ce mois-ci
    const today = new Date();
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const existingCotisation = await this.prismaService.transaction.findFirst({
      where: {
        senderId: isParticipant.id,
        tontineId: tontine.id,
        tour: data.tour,
      },
    });

    if (existingCotisation) {
      throw new BadRequestException('Vous avez déjà cotisé pour ce tour');
    }

    // Créer la transaction
    const cotisation = await this.prismaService.transaction.create({
      data: {
        senderId: isParticipant.id,
        tontineId: tontine.id,
        amount: tontine.cotisation,
        tour: data.tour,
      },
    });
    await this.prismaService.wallets.update({
      where: { tontineId: tontine.id },
      data: {
        amount: { increment: tontine.cotisation },
      },
    });

    return {
      message: 'Cotisation envoyée avec succès',
      data: cotisation,
    };
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
  async joinPool(code: string, msisdn: string) {
    const findPool = await this.poolRepository.findByInviteCode(code);
    if (!findPool) {
      return new BadRequestException('Tontine not found');
    }
    console.log('tontine', findPool);
    const invitation = await this.poolMembersRepository.findPoolMembership(
      msisdn,
      findPool.id,
    );

    console.log('invitation', invitation);
    const user = await this.prismaService.user.update({
      where: { msisdn },
      data: {
        name: invitation?.nom,
      },
    });
    if (!user) {
      throw new BadRequestException('User not found');
    }
    return this.poolMembersRepository.createMembership(
      invitation.round,
      user.id,
      findPool.id,
    );
  }
}
