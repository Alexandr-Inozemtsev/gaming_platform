# Назначение: motion language, tokens и группы анимаций для продукта.

## Motion principles
Коротко, чисто, тактильно, ненавязчиво. Gameplay-feedback может быть выразительнее, но без шума.

## Motion tokens
- duration/fast 120ms
- duration/base 180ms
- duration/slow 320ms
- duration/medium 240ms
- ease/standard (easeOutCubic)
- ease/emphasized (easeInOutCubicEmphasized)
- ease/exit (easeInCubic)

## Animation groups
- Micro: button press, chip select, tab switch, input focus, toggle, segmented, accordion.
- Screen transitions: fade/slide, modal in/out, sheet reveal, panel collapse/expand, overlay.
- Gameplay: active turn pulse, timer urgency, card lift/placement, token bounce, score increment, reward reveal.
- System: skeleton shimmer, reconnect slide-in, offline pulse, retry feedback, idle empty-state motion.

## Формат реализации
- Flutter: AnimatedContainer, AnimatedSwitcher, TweenAnimationBuilder, AnimationController.
- Для сложных иллюстраций: Lottie/SVG animation с ограничением FPS и battery impact.
