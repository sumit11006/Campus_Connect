# UI/UX Design Guidelines

## 1. Design Principles

1. **Hierarchy over decoration**: Important information should visually dominate.
2. **Whitespace**: Use spacing to separate information instead of excessive borders.
3. **One visual language**: All screens must feel like the same application.
4. **Consistency**: Use identical typography, radii, buttons, icons, and colors.
5. **Content first**: Do not add decorative elements that make the app harder to use.
6. **Mobile-first**: Flutter UI must work comfortably on normal phone sizes.
7. **Accessibility**: Maintain readable text, sufficient contrast, large touch targets, and clear states.

## 2. Visual Direction: Premium Modern Campus
The UI should feel:
- Modern & Premium
- Clean & Trustworthy
- Student-friendly
- Slightly energetic

*Avoid making it look like a banking app, an ERP, or a generic Bootstrap dashboard.*

## 3. Component Blueprints

### Flutter Shared Components
- `AppHeader`: Minimalist, avatar integration.
- `AppCard`: Reusable layout with `Large` border radius and `Subtle` shadow.
- `PrimaryButton`: Pill-shaped, high-contrast gradient/solid fill.
- `StatusBadge`: Small radius, Semantic colors.

### React Admin Components
- `AdminSidebar`: Glass-card transparency, clean active states.
- `StatCard`: Consistent metric typography.
- `DataTable`: Ample row padding (16px), subtle border separators instead of harsh lines.
- `Modal`: Floating shadow, backdrop blur.

## 4. Interaction Patterns
- Micro-animations for button presses.
- Smooth transitions for page routing.
- Shimmer effects for loading states instead of blocking spinners.
- Contextual empty states with illustrations rather than blank screens.
