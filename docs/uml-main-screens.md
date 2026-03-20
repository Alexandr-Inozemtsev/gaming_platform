# Назначение: UML-диаграмма экранов и компонентов мобильного клиента (ориентир по ветке main).

```mermaid
graph TD
    App[TabletopApp / MainShell]

    App --> Auth[Auth Screen]
    App --> Home[HomeScreen]
    App --> Catalog[CatalogScreen]
    App --> Room[RoomScreen / Gameplay]
    App --> Profile[ProfileScreen]
    App --> Settings[SettingsScreen]

    subgraph SharedUI[Shared UI Layer]
      Tokens[theme/tokens.dart]
      Controls[shared/ui/controls.dart]
      UIKit[shared/ui/ui_kit.dart]
      States[shared/ui/system_states.dart]
      AssetPack[runtime_asset_pack.dart]
    end

    Home --> H1[FeaturedGameBanner]
    Home --> H2[AppPanel]
    Home --> H3[AppButton group]
    Home --> H4[Runtime asset hint]

    Catalog --> C1[TopBar]
    Catalog --> C2[AppChoiceTab / filters]
    Catalog --> C3[GameCard list]
    Catalog --> C4[EmptyState]

    Room --> R1[PlayerSlot x2]
    Room --> R2[InviteCodeBadge]
    Room --> R3[TileBoardWidget | RollWriteBoardWidget]
    Room --> R4[TurnIndicator]
    Room --> R5[TimerIndicator]
    Room --> R6[ActionBar]
    Room --> R7[HandTray]
    Room --> R8[VideoOverlayWidget]

    Settings --> S1[TopBar]
    Settings --> S2[SettingsRow list]
    Settings --> S3[Language chips]

    Profile --> P1[Stat cards / summary blocks]

    Auth --> A1[AppTextInput]
    Auth --> A2[Primary/Secondary buttons]

    App --> SharedUI
    SharedUI --> Tokens
    SharedUI --> Controls
    SharedUI --> UIKit
    SharedUI --> States
    SharedUI --> AssetPack
```
