import { RequestMethod, ValidationPipe, VersioningType } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { config } from 'dotenv';
import { AppModule } from './app.module';

config();

const PORT = process.env.PORT || 3000;

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  // Swagger Doc configuration
  const config = new DocumentBuilder()
    .setTitle('Tontine Documentation')
    .setDescription('Backend API Documentation')
    .setVersion('1.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Veuillez insérer le token au format Bearer <votre_token>',
      },
      'Authorization',
    )
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  // global validation
  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  );
  /**
   * Setting up global prefix
   */

  /**
   * Enabling api versioning
   */
  app.enableVersioning({ type: VersioningType.URI });

  //Starting server
  await app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}🔥`);
  });
}
bootstrap();
