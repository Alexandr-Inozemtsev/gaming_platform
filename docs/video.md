# Video P1: WebRTC + signaling + TURN/STUN

## Назначение
Документ описывает реализацию видеофункций Prompt I для приватных комнат: signaling через realtime, UX overlay и конфигурацию STUN/TURN.

## Что реализовано
- Realtime gateway поддерживает signaling-события:
  - `video.offer`
  - `video.answer`
  - `video.iceCandidate`
- Для signaling добавлены проверки:
  - пользователь должен быть участником комнаты;
  - при `VIDEO_POLICY=invite_only` пользователь и target должны быть в invite-списке комнаты;
  - включен rate limiting signaling (`40` событий в минуту на `roomId:userId`).
- API при создании приватного матча вызывает `configurePrivateRoom(matchId, players)`.
- Mobile добавляет `Video Overlay` с кнопками `Cam`, `Mic`, `Hang up`.
- Камера и микрофон выключены по умолчанию, включение только в рамках приватной комнаты вручную через overlay.

## Конфигурация среды
Поддерживаются переменные окружения Flutter (`--dart-define`):
- `STUN_URLS`
- `TURN_URLS`
- `TURN_USERNAME`
- `TURN_CREDENTIAL`

Если `STUN_URLS` и `TURN_URLS` пусты — UI показывает понятное предупреждение.

## Варианты TURN/STUN провайдеров
- Self-hosted: `coturn`.
- Managed: Twilio Network Traversal, Xirsys, Metered, Cloudflare Realtime TURN.

## Пример RTCIceServer-конфигурации
```json
{
  "iceServers": [
    { "urls": ["stun:stun.l.google.com:19302"] },
    {
      "urls": ["turn:turn.example.com:3478?transport=udp", "turns:turn.example.com:5349"],
      "username": "${TURN_USERNAME}",
      "credential": "${TURN_CREDENTIAL}"
    }
  ]
}
```

## Ограничения текущей реализации
- В мобильном MVP signaling интегрирован как transport events, без полноценного media pipeline.
- Для production нужны: реальный `flutter_webrtc`, управление устройствами, согласование кодеков и QoS-мониторинг.
