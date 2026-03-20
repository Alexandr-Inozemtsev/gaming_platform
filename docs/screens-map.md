# Назначение: screen-by-screen карта MVP с иерархией, состояниями и адаптивом.

1. **Onboarding/Welcome**: hero + value + CTA/secondary/guest; на compact герой упрощается в статичную иллюстрацию.
2. **Sign In/Sign Up**: компактная форма слева, subdued tabletop accent справа; ошибки и loading inline.
3. **Home**: featured banner, continue, invites/friends, create room CTA; secondary блоки collapse в narrow.
4. **Catalog**: search + filters + tabs + cards + empty/loading; фильтры в overlay sheet на compact.
5. **Game Detail**: cover/meta/description/rules collapse + CTA cluster.
6. **Lobby/Room**: player slots, ready, invite code, chat preview, reconnect states.
7. **Gameplay**: board area + HUD + timer + score + action bar + collapsible side panel.
8. **Player Hand/Action Detail**: scrollable tray, selected/invalid states, confirm/cancel.
9. **Profile**: summary/stats/favorites/achievements/progress.
10. **Settings**: rows/toggles/segmented controls/account actions.
11. **System states**: loading/error/empty/reconnect/offline/no-friends/no-rooms/no-results/interrupted/server-down.

Для каждого экрана действует правило: gameplay-priority composition в landscape; вторичные панели уходят в sheet/overlay при нехватке ширины.
