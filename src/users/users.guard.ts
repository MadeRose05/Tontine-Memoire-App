import {
  BadRequestException,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { verifyToken } from 'src/helpers/security';

// Jwt Guard
@Injectable()
export class AuthGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    if (!token) {
      new UnauthorizedException('Unauthorized action');
    }
    try {
      const payload = verifyToken(token);
      request['user'] = payload;
    } catch (error) {
      throw new UnauthorizedException('Unauthorized action');
    }
    return true;
  }

  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers['authorization']?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}





//Checking role
function checkRole(req: Request) {
  if (!req.headers['authorization']) {
    throw new ForbiddenException('User not logged in');
  }

  try {
    const { userId, role } = verifyToken(
      req.headers['authorization'].split(' ')[1],
    );
    if (userId && role === checkRole) {
      return true;
    } else {
      throw new UnauthorizedException(
        "Unauthorized action, you're not an admin",
      );
    }
  } catch (error) {
    if (error.status === 401) {
      throw error;
    }
    throw new BadRequestException(
      'Invalid or expired auth token detected, login again',
    );
  }
}
