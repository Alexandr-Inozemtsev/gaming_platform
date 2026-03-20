/**
 * Назначение файла: сформировать TypeScript-точку входа API-пакета и перечень модулей MVP.
 * Роль в проекте: документировать состав backend-ядра и упростить навигацию по кодовой базе.
 * Основные функции: экспортировать список модулей Auth/Users/Catalog/Matches/Store/Moderation/Analytics.
 * Связи с другими файлами: связанный runtime находится в app.mjs и server.mjs, дескрипторы — в src/modules/*.module.ts.
 * Важно при изменении: поддерживать список модулей в актуальном состоянии при изменении API-домена.
 */

import { MODULE_DESCRIPTOR as AuthModule } from './modules/auth.module';
import { MODULE_DESCRIPTOR as UsersModule } from './modules/users.module';
import { MODULE_DESCRIPTOR as CatalogModule } from './modules/catalog.module';
import { MODULE_DESCRIPTOR as MatchesModule } from './modules/matches.module';
import { MODULE_DESCRIPTOR as StoreModule } from './modules/store.module';
import { MODULE_DESCRIPTOR as ModerationModule } from './modules/moderation.module';
import { MODULE_DESCRIPTOR as AnalyticsModule } from './modules/analytics.module';

export const ApiModules = [
  AuthModule,
  UsersModule,
  CatalogModule,
  MatchesModule,
  StoreModule,
  ModerationModule,
  AnalyticsModule
];
