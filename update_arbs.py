import json
import os

keys = {
    'en': {
        "filterMagnitudeTitle": "Notification Filter",
        "filterMagnitudeDesc": "Show earthquakes above magnitude:",
        "filterRadiusTitle": "Coverage Radius",
        "filterRadiusDesc": "Alert me for earthquakes within:",
        "preferencesTitle": "Preferences",
        "darkModeTitle": "Dark Mode (Lunar Theme)",
        "soundTitle": "Sound Notifications",
        "emergencyContactsTitle": "Emergency Contacts",
        "emergencyContactsDesc": "Phone numbers to notify during an SOS event",
        "contactHint": "Contact Phone"
    },
    'tr': {
        "filterMagnitudeTitle": "Bildirim Filtresi",
        "filterMagnitudeDesc": "Şu şiddet ve üzeri depremleri göster:",
        "filterRadiusTitle": "Tarama Yarıçapı",
        "filterRadiusDesc": "Bana şu mesafedeki depremleri bildir:",
        "preferencesTitle": "Tercihler",
        "darkModeTitle": "Karanlık Mod (Lunar Tema)",
        "soundTitle": "Sesli Bildirimler",
        "emergencyContactsTitle": "Acil Durum Kişileri",
        "emergencyContactsDesc": "Acil durumda SMS gönderilecek numaralar",
        "contactHint": "Kişi Numarası"
    },
    'ja': {
        "filterMagnitudeTitle": "通知フィルター",
        "filterMagnitudeDesc": "表示する最小マグニチュード:",
        "filterRadiusTitle": "対象範囲 (半径)",
        "filterRadiusDesc": "通知する距離:",
        "preferencesTitle": "設定",
        "darkModeTitle": "ダークモード",
        "soundTitle": "サウンド通知",
        "emergencyContactsTitle": "緊急連絡先",
        "emergencyContactsDesc": "緊急時に通知する電話番号",
        "contactHint": "連絡先電話番号"
    },
    'de': {
        "filterMagnitudeTitle": "Benachrichtigungsfilter",
        "filterMagnitudeDesc": "Zeige Erdbeben ab Magnitude:",
        "filterRadiusTitle": "Erfassungsradius",
        "filterRadiusDesc": "Benachrichtigen bei Erdbeben innerhalb:",
        "preferencesTitle": "Präferenzen",
        "darkModeTitle": "Dunkelmodus",
        "soundTitle": "Tonbenachrichtigungen",
        "emergencyContactsTitle": "Notfallkontakte",
        "emergencyContactsDesc": "Telefonnummern für SOS-Ereignisse",
        "contactHint": "Kontakt Telefon"
    },
    'es': {
        "filterMagnitudeTitle": "Filtro de Notificación",
        "filterMagnitudeDesc": "Mostrar terremotos mayores a:",
        "filterRadiusTitle": "Radio de Cobertura",
        "filterRadiusDesc": "Alertarme de terremotos dentro de:",
        "preferencesTitle": "Preferencias",
        "darkModeTitle": "Modo Oscuro",
        "soundTitle": "Notificaciones de Sonido",
        "emergencyContactsTitle": "Contactos de Emergencia",
        "emergencyContactsDesc": "Números para notificar durante un SOS",
        "contactHint": "Teléfono de Contacto"
    },
    'fr': {
        "filterMagnitudeTitle": "Filtre de Notification",
        "filterMagnitudeDesc": "Afficher les séismes supérieurs à:",
        "filterRadiusTitle": "Rayon de Couverture",
        "filterRadiusDesc": "M'alerter dans un rayon de:",
        "preferencesTitle": "Préférences",
        "darkModeTitle": "Mode Sombre",
        "soundTitle": "Notifications Sonores",
        "emergencyContactsTitle": "Contacts d'Urgence",
        "emergencyContactsDesc": "Numéros à notifier en cas de SOS",
        "contactHint": "Téléphone de Contact"
    },
    'ru': {
        "filterMagnitudeTitle": "Фильтр Уведомлений",
        "filterMagnitudeDesc": "Показывать землетрясения от:",
        "filterRadiusTitle": "Радиус Охвата",
        "filterRadiusDesc": "Уведомлять в радиусе:",
        "preferencesTitle": "Настройки",
        "darkModeTitle": "Темный Режим",
        "soundTitle": "Звуковые Уведомления",
        "emergencyContactsTitle": "Экстренные Контакты",
        "emergencyContactsDesc": "Номера для уведомления при SOS",
        "contactHint": "Телефон Контакта"
    }
}

l10n_dir = r"c:\Users\ridva\deprem_anlik_app\lib\l10n"

for code, d in keys.items():
    file_path = os.path.join(l10n_dir, f"app_{code}.arb")
    if os.path.exists(file_path):
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for k, v in d.items():
            if k not in data:
                data[k] = v
                
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

print("ARB FILES UPDATED")
