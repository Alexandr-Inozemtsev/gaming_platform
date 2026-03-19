// Назначение файла: реализовать минимальную i18n-словарную локализацию для RU/EN без внешних пакетов.
// Роль в проекте: обеспечивать переключение языка в Settings и единый доступ к текстам экранов MVP.
// Основные функции: хранить переводы, выдавать строку по ключу, содержать набор поддерживаемых языков.
// Связи с другими файлами: используется в main.dart и всех экранах через AppState.t().
// Важно при изменении: добавлять новые ключи одновременно для всех языков, чтобы избежать пустых подписей.

class AppStrings {
  static const supported = ['ru', 'en'];

  static const Map<String, Map<String, String>> _v = {
    'ru': {
      'tab.home': 'Главная',
      'tab.catalog': 'Каталог',
      'tab.room': 'Комната',
      'tab.store': 'Магазин',
      'tab.profile': 'Профиль',
      'tab.settings': 'Настройки',
      'home.continue': 'Продолжить: Матч #1',
      'home.play': 'Играть',
      'home.createRoom': 'Создать комнату',
      'home.teaser': 'Store teaser: new skins',
      'auth.login': 'Войти',
      'auth.register': 'Регистрация',
      'auth.email': 'Email',
      'auth.password': 'Пароль',
      'catalog.title': 'Игры',
      'room.title': 'Игровая комната',
      'room.yourTurn': 'Твой ход',
      'store.games': 'Игры',
      'store.skins': 'Скины',
      'store.buy': 'Купить (sandbox)',
      'store.inventory': 'Инвентарь',
      'store.try': 'Примерить',
      'store.apply': 'Применить',
      'store.ruByWarn': 'платежный канал зависит от дистрибуции',
      'profile.title': 'Профиль',
      'settings.title': 'Настройки',
      'settings.lang': 'Язык',
      'settings.privacy': 'Privacy',
      'settings.block': 'Block list',
      'settings.report': 'Report'
    },
    'en': {
      'tab.home': 'Home',
      'tab.catalog': 'Catalog',
      'tab.room': 'Room',
      'tab.store': 'Store',
      'tab.profile': 'Profile',
      'tab.settings': 'Settings',
      'home.continue': 'Continue: Match #1',
      'home.play': 'Play',
      'home.createRoom': 'Create Room',
      'home.teaser': 'Store teaser: new skins',
      'auth.login': 'Login',
      'auth.register': 'Register',
      'auth.email': 'Email',
      'auth.password': 'Password',
      'catalog.title': 'Games',
      'room.title': 'Game Room',
      'room.yourTurn': 'Your turn',
      'store.games': 'Games',
      'store.skins': 'Skins',
      'store.buy': 'Buy (sandbox)',
      'store.inventory': 'Inventory',
      'store.try': 'Try',
      'store.apply': 'Apply',
      'store.ruByWarn': 'payment channel depends on distribution',
      'profile.title': 'Profile',
      'settings.title': 'Settings',
      'settings.lang': 'Language',
      'settings.privacy': 'Privacy',
      'settings.block': 'Block list',
      'settings.report': 'Report'
    }
  };

  static String t(String lang, String key) => _v[lang]?[key] ?? _v['en']![key] ?? key;
}
