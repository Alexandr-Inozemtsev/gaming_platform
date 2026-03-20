// Назначение файла: реализовать локализацию RU/EN по ключам, включая plural-формы и базовое форматирование чисел/валют.
// Роль в проекте: быть единым i18n-слоем Flutter MVP, чтобы UI не содержал «жёстких» строк и корректно переключал язык на лету.
// Основные функции: хранение словаря переводов, выбор plural-форм, форматирование чисел и валют без внешних зависимостей.
// Связи с другими файлами: используется в apps/mobile/lib/main.dart через AppState.t()/tp()/formatNumber()/formatCurrency().
// Важно при изменении: любые новые ключи добавлять сразу для ru/en; plural-ключи поддерживать в формате <key>.one/.few/.many/.other.

class AppStrings {
  static const supported = ['ru', 'en'];
  static const defaultLang = 'ru';

  static const Map<String, Map<String, String>> _v = {
    'ru': {
      'app.title': 'TabletopPlatform',
      'tab.home': 'Главная',
      'tab.catalog': 'Каталог',
      'tab.room': 'Комната',
      'tab.create': 'Редактор',
      'tab.store': 'Магазин',
      'tab.profile': 'Профиль',
      'tab.settings': 'Настройки',
      'home.continue': 'Продолжить: Матч #1',
      'home.play': 'Играть',
      'home.createRoom': 'Создать комнату',
      'home.join': 'Войти',
      'home.botEasy': 'Лёгкий',
      'home.botNormal': 'Нормальный',
      'home.teaser': 'Тизер магазина: новые скины',
      'auth.login': 'Войти',
      'auth.register': 'Регистрация',
      'auth.email': 'Email',
      'auth.password': 'Пароль',
      'catalog.title': 'Игры',
      'room.title': 'Игровая комната',
      'room.yourTurn': 'Твой ход',
      'room.report': 'Пожаловаться',
      'room.switch': 'Сменить',
      'room.dice': 'Кости',
      'room.videoStatus': 'Статус видео',
      'room.reportSent': 'Репорт отправлен',
      'video.title': 'Видео-оверлей',
      'video.openOverlay': 'Открыть видео',
      'video.cameraOn': 'Камера: вкл',
      'video.cameraOff': 'Камера: выкл',
      'video.micOn': 'Микрофон: вкл',
      'video.micOff': 'Микрофон: выкл',
      'video.hangup': 'Завершить',
      'video.permissionGranted': 'Разрешения камеры/микрофона выданы только для приватной комнаты',
      'store.games': 'Игры',
      'store.skins': 'Скины',
      'store.buy': 'Купить (sandbox)',
      'store.inventory': 'Инвентарь',
      'store.try': 'Примерить',
      'store.apply': 'Применить',
      'store.new': 'НОВИНКА',
      'store.ruByWarn': 'Платёжный канал зависит от дистрибуции',
      'editor.title': 'Редактор вариантов',
      'editor.myVariants': 'Мои варианты',
      'editor.boardSize': 'Размер поля',
      'editor.winCondition': 'Условие победы',
      'editor.scoring': 'Множитель очков',
      'editor.turnTimer': 'Таймер хода (сек)',
      'editor.validate': 'Проверить',
      'editor.test': 'Тест-матч',
      'editor.publish': 'Публикация',
      'editor.createDraft': 'Создать драфт',
      'editor.linkReady': 'Приватная ссылка готова',
      'editor.joinVariant': 'Войти по ссылке',
      'editor.variantMeta': 'поле={board}, победа={win}',
      'profile.title': 'Профиль',
      'profile.guest': 'гость',
      'profile.adminAnalytics': 'Админ → Аналитика → [Таблица событий]',
      'profile.refreshAnalytics': 'Обновить аналитику',
      'profile.matches7d': 'Матчи за 7 дней',
      'profile.moderationFlow': 'Админ: [Репорты] -> [Кейс] -> [Мут/Бан]',
      'profile.casePrefix': 'Кейс',
      'profile.caseStatus': 'статус',
      'profile.caseReason': 'причина',
      'profile.dauPrefix': 'DAU',
      'profile.auditEntries.one': '{count} запись аудита',
      'profile.auditEntries.few': '{count} записи аудита',
      'profile.auditEntries.many': '{count} записей аудита',
      'profile.auditEntries.other': '{count} записи аудита',
      'settings.title': 'Настройки',
      'settings.lang': 'Язык',
      'settings.privacy': 'Приватность',
      'settings.block': 'Чёрный список',
      'settings.report': 'Пожаловаться',
      'settings.summary': '[НАСТРОЙКИ] Приватность • Чёрный список • Репорт'
    },
    'en': {
      'app.title': 'TabletopPlatform',
      'tab.home': 'Home',
      'tab.catalog': 'Catalog',
      'tab.room': 'Room',
      'tab.create': 'Create',
      'tab.store': 'Store',
      'tab.profile': 'Profile',
      'tab.settings': 'Settings',
      'home.continue': 'Continue: Match #1',
      'home.play': 'Play',
      'home.createRoom': 'Create Room',
      'home.join': 'Join',
      'home.botEasy': 'Easy',
      'home.botNormal': 'Normal',
      'home.teaser': 'Store teaser: new skins',
      'auth.login': 'Login',
      'auth.register': 'Register',
      'auth.email': 'Email',
      'auth.password': 'Password',
      'catalog.title': 'Games',
      'room.title': 'Game Room',
      'room.yourTurn': 'Your turn',
      'room.report': 'Report',
      'room.switch': 'Switch',
      'room.dice': 'Dice',
      'room.videoStatus': 'Video status',
      'room.reportSent': 'Report sent',
      'video.title': 'Video Overlay',
      'video.openOverlay': 'Open video',
      'video.cameraOn': 'Camera: on',
      'video.cameraOff': 'Camera: off',
      'video.micOn': 'Mic: on',
      'video.micOff': 'Mic: off',
      'video.hangup': 'Hang up',
      'video.permissionGranted': 'Camera/mic permissions granted for private room only',
      'store.games': 'Games',
      'store.skins': 'Skins',
      'store.buy': 'Buy (sandbox)',
      'store.inventory': 'Inventory',
      'store.try': 'Try',
      'store.apply': 'Apply',
      'store.new': 'NEW',
      'store.ruByWarn': 'Payment channel depends on distribution',
      'editor.title': 'Variant editor',
      'editor.myVariants': 'My variants',
      'editor.boardSize': 'Board size',
      'editor.winCondition': 'Win condition',
      'editor.scoring': 'Scoring multiplier',
      'editor.turnTimer': 'Turn timer (sec)',
      'editor.validate': 'Validate',
      'editor.test': 'Test-play',
      'editor.publish': 'Publish',
      'editor.createDraft': 'Create draft',
      'editor.linkReady': 'Private link is ready',
      'editor.joinVariant': 'Join by link',
      'editor.variantMeta': 'board={board}, win={win}',
      'profile.title': 'Profile',
      'profile.guest': 'guest',
      'profile.adminAnalytics': 'Admin → Analytics → [Events table]',
      'profile.refreshAnalytics': 'Refresh analytics',
      'profile.matches7d': 'Matches (7d)',
      'profile.moderationFlow': 'Admin: [Reports] -> [Case] -> [Mute/Ban]',
      'profile.casePrefix': 'Case',
      'profile.caseStatus': 'status',
      'profile.caseReason': 'reason',
      'profile.dauPrefix': 'DAU',
      'profile.auditEntries.one': '{count} audit entry',
      'profile.auditEntries.few': '{count} audit entries',
      'profile.auditEntries.many': '{count} audit entries',
      'profile.auditEntries.other': '{count} audit entries',
      'settings.title': 'Settings',
      'settings.lang': 'Language',
      'settings.privacy': 'Privacy',
      'settings.block': 'Block list',
      'settings.report': 'Report',
      'settings.summary': '[SETTINGS] Privacy • Block list • Report'
    }
  };

  static String t(String lang, String key) => _v[lang]?[key] ?? _v['en']![key] ?? key;

  static String tr(String lang, String key, Map<String, String> values) {
    var text = t(lang, key);
    for (final entry in values.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  static String tp(String lang, String key, int count) {
    final rule = _pluralRule(lang, count);
    final pattern = t(lang, '$key.$rule');
    return pattern.replaceAll('{count}', formatNumber(lang, count));
  }

  static String formatNumber(String lang, num value) {
    final hasFraction = value % 1 != 0;
    final decimals = hasFraction ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
    final parts = decimals.split('.');
    final whole = parts.first;
    final fraction = parts.length > 1 ? parts[1] : null;

    final grouped = _groupThousands(whole, lang == 'ru' ? ' ' : ',');
    if (fraction == null) return grouped;
    return '${grouped}${lang == "ru" ? "," : "."}$fraction';
  }

  static String formatCurrency(String lang, num value) {
    final formatted = formatNumber(lang, value);
    return lang == 'ru' ? '$formatted ₽' : '\$$formatted';
  }

  static String _groupThousands(String digits, String separator) {
    final buffer = StringBuffer();
    var counter = 0;
    for (var i = digits.length - 1; i >= 0; i -= 1) {
      buffer.write(digits[i]);
      counter += 1;
      if (counter % 3 == 0 && i != 0) buffer.write(separator);
    }
    return buffer.toString().split('').reversed.join();
  }

  static String _pluralRule(String lang, int count) {
    if (lang == 'ru') {
      final mod10 = count % 10;
      final mod100 = count % 100;
      if (mod10 == 1 && mod100 != 11) return 'one';
      if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'few';
      return 'many';
    }
    return count == 1 ? 'one' : 'other';
  }
}
