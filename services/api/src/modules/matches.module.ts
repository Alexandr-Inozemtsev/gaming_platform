/**
 * Назначение файла: объявить модуль backend-ядра MVP в стиле NestJS-подобной структуры.
 * Роль в проекте: фиксировать границы ответственности конкретного доменного модуля API.
 * Основные функции: хранить имя модуля и краткое описание зоны ответственности.
 * Связи с другими файлами: используется как структурный ориентир рядом с runtime-логикой в app.mjs.
 * Важно при изменении: поддерживать согласованность имени модуля с документацией и endpoint-контрактами.
 */

export interface ModuleDescriptor {
  name: string;
  responsibility: string;
}

export const MODULE_DESCRIPTOR: ModuleDescriptor = {
  name: 'MatchesModule',
  responsibility: 'matches domain for MVP API'
};
