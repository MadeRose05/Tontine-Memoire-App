import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Profile,  TempOTP, User } from '@prisma/client';
import { deleteImageTask, uploadImage } from 'src/helpers/cloudinary/upload';
import { deleteOtpTask } from 'src/helpers/otp/delete_otp';
import { otpCron } from 'src/helpers/otp/generate_otp';
import { sendEmail } from 'src/helpers/otp/send_email';
import { hashPwd } from 'src/helpers/security';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateProfileDto } from './dto/create-profile.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prismaService: PrismaService) {}

  async create(createUserDto: CreateUserDto) {
    try {
      const pwd = await hashPwd(createUserDto.pin);
      const user = await this.prismaService.user.create({
        data: {
          msisdn: createUserDto.msisdn,
          pin: pwd,
          name:createUserDto.name
         
        },
      });
     
      return user;
    } catch (error) {
      throw new BadRequestException(
        error.meta?.target[0] === 'email'
          ? 'User with this email already exists'
          : 'Internal server error ' + error.toString(),
      );
    }
  }

  async findAll() {
    return await this.prismaService.user.findMany({
      
      orderBy: { createdAt: 'desc' },
     
    });
  }

  // async sendOTP(data: { email: string; otp: number }): Promise<TempOTP> {
  //   try {
  //     return await this.prismaService.tempOTP.create({ data });
  //   } catch (error) {
  //     return null;
  //   }
  // }

  async deleteOTP(msisdn: string): Promise<boolean> {
    try {
      await this.prismaService.tempOTP.delete({ where: { msisdn } });
      return true;
    } catch (error) {
      return false;
    }
  }

  async verifyOTP(data: { msisdn: string; otp: number }): Promise<User> {
    try {
      const otp = await this.prismaService.tempOTP.findFirst({ where: data });
      if (!otp) {
        throw new NotFoundException('OTP not found or expired');
      }

      const updated = await this.prismaService.user.findFirst({
       
        where: { msisdn: data.msisdn },
      });
      if (!updated) {
        throw new BadRequestException(
          'Account verification failed, user might not exist or internal server error',
        );
      }
      deleteOtpTask(updated.msisdn, 'now').start();
      return updated;
    } catch (error) {
      if (
        error.response?.statusCode === 404 ||
        error.response?.statusCode === 400
      ) {
        throw error;
      }
      throw new HttpException(
        error.meta?.cause ||
          error.meta?.field_name ||
          'Verification failed, something went wrong on server',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  async resendOTP(msisdn: string) {
    try {
      const user = await this.prismaService.user.findFirst({
        where: { msisdn, },
        include: {
          tempOTP: { select: { otp: true } },
        },
      });
      if (user?.tempOTP?.otp) {
        sendEmail({
          msisdn,
          name: user.name,
          otp: user.tempOTP.otp,
        });
      } else {
        if (!user) {
          throw new NotFoundException(
            'Resend failed, account already verified or does no longer exist',
          );
        }
       
      }
    } catch (error) {
      if (
        error.response?.statusCode === 404 ||
        error.response?.statusCode === 400
      ) {
        throw error;
      }
      throw new HttpException(
        error.meta?.cause ||
          error.meta?.field_name ||
          'Verification failed, something went wrong on server',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  async findOne(id: string) {
    try {
      const user = await this.prismaService.user.findUniqueOrThrow({
        where: { id },
        select: {
          msisdn: true,
          createdAt: true,
        },
      });
      return user;
    } catch (error) {
      if (error.code === 'P2025') {
        throw new NotFoundException(
          'User account no longer exist in our system',
        );
      }
    }
  }

  async findByMsisdn(msisdn: string): Promise<User> {
    return await this.prismaService.user.findFirst({
      where: { msisdn },
     
    });
  }



  // ----------------------------------------------------------------

  async createProfile(
    profile: CreateProfileDto,
    userId: string,
  ): Promise<Profile> {
    const img = await uploadImage(profile.image);
    try {
      const createdProfile = await this.prismaService.profile.create({
        data: {
          username: profile.username,
          image: img,
          userId: userId,
          about: profile.about,
        },
      });
      return createdProfile;
    } catch (error) {
      //Deleting image when we are unable to create profile
      deleteImageTask(profile.username, img).start();
      throw new BadRequestException(
        error.meta?.field_name
          ? 'user does not exist'
          : error.meta?.target[0] === 'username'
          ? 'Username taken try another one'
          : error.meta?.target[0] === 'userId'
          ? 'You already have a profile'
          : 'Internal server error ' + error.toString(),
      );
    }
  }

  async getProfiles(username: string): Promise<Profile[]> {
    return await this.prismaService.profile.findMany({
      where: { username: { equals: username, mode: 'insensitive' } },
    });
  }

  async updateProfile(id: string, updateUserDto: UpdateProfileDto) {
    const exist = await this.prismaService.profile.findUnique({
      where: { userId: id },
    });
    if (!exist) {
      throw new NotFoundException('Profile does not exist');
    }
    // if (updateUserDto.username) {
    //   const usernameExist = await this.prismaService.profile.findUnique({
    //     where: { username: updateUserDto.username },
    //   });
    //   if (usernameExist && updateUserDto.username !== exist.username) {
    //     throw new NotFoundException('Username already taken');
    //   }
    // }

    try {
      let { username, image, about } = updateUserDto;
      if (image) {
        image = await uploadImage(image);
      } else {
        image = undefined;
      }

      const updated = await this.prismaService.profile.update({
        where: { userId: id },
        data: { about, username, image },
      });

      if (image && exist.image) {
        deleteImageTask(exist.username, exist.image).start();
      }

      return updated;
    } catch (error) {
      throw new BadRequestException(error.meta?.cause || error.message);
    }
  }

 
  // ----------------------------------------------------------------
}
