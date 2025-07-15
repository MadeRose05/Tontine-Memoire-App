import { Module } from '@nestjs/common';
import { EmailService } from 'src/emails/emails.service';
import { PoolMembersModule } from 'src/pool-members/pool-members.module';
import { PrismaModule } from 'src/prisma/prisma.module';
import { UsersModule } from 'src/users/users.module';
import { WalletModule } from 'src/wallet/wallet.module';
import { PoolController } from './pool.controller';
import { PoolRepository } from './pool.repository';
import { PoolService } from './pool.service';
import { SmsService } from 'src/sms/sms.service';

@Module({
  controllers: [PoolController],
  providers: [PoolService, PoolRepository, EmailService, SmsService],
  imports: [PrismaModule, WalletModule, UsersModule, PoolMembersModule],
})
export class PoolModule {}
