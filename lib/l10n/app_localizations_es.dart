// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SeismoAlert';

  @override
  String get live => 'En vivo';

  @override
  String get history => 'Historial';

  @override
  String get news => 'Noticias';

  @override
  String get location => 'Ubicación';

  @override
  String get radius => 'Radio';

  @override
  String get lastYear => 'El año pasado';

  @override
  String get noData => 'No se encontraron datos.';

  @override
  String get error => 'Ocurrió un error.';

  @override
  String get selectLocation => 'Seleccionar ubicación';

  @override
  String get distance => 'Distancia';

  @override
  String get depth => 'Profundidad';

  @override
  String get liveEarthquakes => 'Sismos en vivo';

  @override
  String newsCount(int count) {
    return '$count noticias';
  }

  @override
  String records(int count) {
    return '$count registros - radio 100km';
  }

  @override
  String kmAway(String distance) {
    return 'a $distance km';
  }

  @override
  String get pastEarthquakes => 'Sismos pasados';

  @override
  String get earthquakeNews => 'Noticias Sísmicas';

  @override
  String get areaSafe => 'Área segura';

  @override
  String get seismicAlert => 'Alerta sísmica';

  @override
  String get noSeismicActivity =>
      'No se detectó actividad sísmica significativa en su vecindad.';

  @override
  String get significantActivity =>
      'Actividad sísmica significativa detectada cerca.';

  @override
  String get languageSettings => 'Configuraciones de idioma';

  @override
  String get mapTab => 'Mapa';

  @override
  String get activityTab => 'Actividad';

  @override
  String get savedTab => 'Guardado';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String get developmentInProgress => 'En desarrollo';

  @override
  String get guideTitle => 'Guía de Supervivencia';

  @override
  String get guide1Title => '1. AGACHARSE, CUBRIRSE, SUJETARSE';

  @override
  String get guide1Desc =>
      'Apóyese en las manos y rodillas. Cúbrase la cabeza y el cuello. Sujétese a un mueble resistente hasta que pase el temblor.';

  @override
  String get guide2Title => '2. QUEDARSE ADENTRO';

  @override
  String get guide2Desc =>
      'No salga corriendo durante el terremoto. La mayoría de las lesiones ocurren por intentar salir precipitadamente.';

  @override
  String get guide3Title => '3. ALEJARSE DE LOS CRISTALES';

  @override
  String get guide3Desc =>
      'Manténgase alejado de ventanas, cristales, puertas exteriores y muros, o elementos que puedan caer.';

  @override
  String get guide4Title => '4. SI QUEDA ATRAPADO';

  @override
  String get guide4Desc =>
      'No encienda fósforos. Cúbrase la boca con ropa. Golpee un tubo o pared para que los rescatistas puedan encontrarlo.';

  @override
  String get filterMagnitudeTitle => 'Filtro de Notificación';

  @override
  String get filterMagnitudeDesc => 'Mostrar terremotos mayores a:';

  @override
  String get filterRadiusTitle => 'Radio de Cobertura';

  @override
  String get filterRadiusDesc => 'Alertarme de terremotos dentro de:';

  @override
  String get preferencesTitle => 'Preferencias';

  @override
  String get darkModeTitle => 'Modo Oscuro';

  @override
  String get soundTitle => 'Notificaciones de Sonido';

  @override
  String get emergencyContactsTitle => 'Contactos de Emergencia';

  @override
  String get emergencyContactsDesc => 'Números para notificar durante un SOS';

  @override
  String get contactHint => 'Teléfono de Contacto';
}
