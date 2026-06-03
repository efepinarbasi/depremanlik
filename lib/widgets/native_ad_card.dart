import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Native Ad Card - haber listesine haber kartlarıyla aynı tasarımda gömülür.
/// Her instance kendi reklam yüklemesini yönetir.
///
/// TEST AD UNIT ID kullanılmaktadır.
/// Production'da gerçek native ad unit ID ile değiştir:
/// Android: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  // Test Native Ad Unit ID (Google resmi test ID)
  static const String _adUnitId = 'ca-app-pub-3940256099942544/2247696110';

  NativeAd? _nativeAd;
  bool _isLoaded = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    _nativeAd = NativeAd(
      adUnitId: _adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd yüklenemedi: $error');
          ad.dispose();
          if (mounted) {
            setState(() => _hasFailed = true);
          }
        },
      ),
      request: const AdRequest(),
      // Medium template → haber kartıyla uyumlu boyut
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: const Color(0xFFFFFFFF),
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.redAccent,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF191C1D),
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 15.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF45474D),
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF45474D),
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    // Reklam yüklenemezse hiç yer kaplanmasın
    if (_hasFailed) return const SizedBox.shrink();

    // Yüklenirken iskelet göster
    if (!_isLoaded || _nativeAd == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 120, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 80, color: Colors.grey.shade200),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            height: 320,
            child: AdWidget(ad: _nativeAd!),
          ),
          // "Reklam" etiketi (şeffaflık için)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Reklam',
                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
