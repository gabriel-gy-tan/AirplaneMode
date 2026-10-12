import 'package:airplanemode/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all themes build', () {
    expect(AppTheme.persona3().useMaterial3, isTrue);
    expect(AppTheme.aero().useMaterial3, isTrue);
    expect(AppTheme.phantom().useMaterial3, isTrue);
    expect(
      AppTheme.persona3().extension<ThemeExtras>()?.name,
      AppThemeName.persona3,
    );
    expect(
      AppTheme.aero().extension<ThemeExtras>()?.name,
      AppThemeName.aero,
    );
    expect(
      AppTheme.phantom().extension<ThemeExtras>()?.name,
      AppThemeName.phantom,
    );
  });
}
