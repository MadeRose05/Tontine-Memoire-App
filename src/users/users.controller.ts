import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  ForbiddenException,
  Get,
  NotFoundException,
  Param,
  ParseEnumPipe,
  Patch,
  Post,
  Query,
  UnauthorizedException,
  UseGuards,
  ValidationPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBody,
  ApiParam,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { isAlphanumeric, isEmail } from 'class-validator';
import { comparePwd, generateToken } from 'src/helpers/security';
import { AppResponse } from 'src/utils/_http_response';
import { CreateProfileDto } from './dto/create-profile.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { LoginUserDto } from './dto/login-user.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { VerifyUserDto } from './dto/verify-user.dto';
import { AuthUser } from './users.decorator';
import { UsersService } from './users.service';
@ApiTags('users')
@ApiBearerAuth('Authorization')
@Controller({ path: 'users' })
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // @Post('create')
  // async create(
  //   @Body(new ValidationPipe()) createUserDto: CreateUserDto,
  // ): Promise<AppResponse> {
  //   //Checking if the email already exists
  //   const isExist = await this.usersService.findByMsisdn(createUserDto.msisdn);

  //   if (isExist) {
  //     throw new BadRequestException('msisdn already exists');
  //   }

  //   //Creating a new user
  //   const data = await this.usersService.create(createUserDto);

  //   return {
  //     message: 'User created successfully',
  //     data,
  //   };
  // }

  @Post('login')
  @ApiOperation({ summary: 'Login user' })
  @ApiBody({ type: LoginUserDto })
  async login(
    @Body(new ValidationPipe()) loginUserDto: LoginUserDto,
  ): Promise<AppResponse> {
    //Checking user email exists
    let user = await this.usersService.findByMsisdn(loginUserDto.msisdn);
    if (!user) {
      throw new UnauthorizedException('Invalid msisdn or pin');
    }
    //Verify user password
    if (!(await comparePwd(loginUserDto.pin, user.pin))) {
      throw new BadRequestException('Invalid credentials, wrong pin');
    }

    //Generating auth token
    const token = generateToken(user.id, user.msisdn);
    //Responding user and token
    return {
      message: 'User logged in successfully',
      data: {
        user,
        token,
      },
    };
  }

  @Get(":msisdn")
  @ApiParam({
    name: 'msisdn',
  })
  @ApiOperation({ summary: 'get user' })
  async findbymsisdn(@Param('msisdn') msisdn: string): Promise<AppResponse> {
    if (!msisdn) {
      throw new BadRequestException('msisdn is required');
    }
    let user = await this.usersService.findByMsisdn(msisdn);
    if (!user) {
      user = await this.usersService.create({
        msisdn: msisdn,
        pin: '1234',
        name: 'test',
      });
      return {
        message: 'success',
        data: { user, newUser: true },
      };
    }
    return {
      message: 'succes',
      data: { user, newUser: false },
    };
  }

  @Get()
  async findAll(): Promise<AppResponse> {
    const users = await this.usersService.findAll();
    return {
      message: 'Users retrieved successfully',
      count: users.length,
      data: users,
    };
  }

  // @Get('profile')
  // async findProfiles(@Query('q') username: string): Promise<AppResponse> {
  //   if (!username && !isAlphanumeric(username)) {
  //     throw new BadRequestException(
  //       !username ? 'search query required' : 'invalid username',
  //     );
  //   }
  //   const profiles = await this.usersService.getProfiles(username);
  //   return {
  //     message: 'Users retrieved successfully',
  //     count: profiles.length,
  //     data: profiles,
  //   };
  // }

  // @Get(':id')
  // async findOne(
  //   @Param('id') id: string,
  //   @AuthUser() userId: string,
  // ): Promise<AppResponse> {
  //   if (userId !== id) {
  //     throw new UnauthorizedException(
  //       'Invalid user id, you can view only your own info',
  //     );
  //   }
  //   return {
  //     message: 'User retrieved successfully',
  //     data: await this.usersService.findOne(id),
  //   };
  // }

  // @Patch('profile')
  // async update(
  //   @Body() updateProfileDto: UpdateProfileDto,
  //   @AuthUser() userId: string,
  // ): Promise<AppResponse> {
  //   const data = await this.usersService.updateProfile(
  //     userId,
  //     updateProfileDto,
  //   );
  //   return { message: 'Profile updated successfully', data };
  // }

  // ----------------------------------------------------------------

  // @Post('profile')
  // async createProfile(
  //   @Body() createProfileDto: CreateProfileDto,
  //   @AuthUser() userId: string,
  // ): Promise<AppResponse> {
  //   const profile = await this.usersService.createProfile(
  //     createProfileDto,
  //     userId,
  //   );
  //   return {
  //     message: 'User profile created successfully',
  //     data: profile,
  //   };
  // }
}
