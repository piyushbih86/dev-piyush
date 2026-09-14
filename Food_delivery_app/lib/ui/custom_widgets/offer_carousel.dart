import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/model/quest.dart';
import 'package:khaanado/ui/custom_widgets/motion.dart';

class OfferCarousel extends StatefulWidget {
  const OfferCarousel({super.key, required this.offers, this.onTap});

  final List<OfferBanner> offers;
  final ValueChanged<OfferBanner>? onTap;

  @override
  State<OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<OfferCarousel> {
  final _page = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      _ensureTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  void _ensureTimer() {
    if (_timer != null || widget.offers.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || widget.offers.isEmpty) return;
      if (!TickerMode.of(context)) return;
      _index = (_index + 1) % widget.offers.length;
      _page.animateToPage(
        _index,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _page,
            itemCount: widget.offers.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final offer = widget.offers[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: PressableScale(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onTap?.call(offer);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [offer.start, offer.end],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: offer.end.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: ColorConstants.cream,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  offer.subtitle,
                                  style: TextStyle(
                                    color: ColorConstants.cream
                                        .withValues(alpha: 0.82),
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.28),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    offer.code,
                                    style: const TextStyle(
                                      color: ColorConstants.gold,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            offer.icon,
                            size: 42,
                            color: ColorConstants.cream.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.offers.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 4,
                width: i == _index ? 16 : 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? ColorConstants.gold
                      : ColorConstants.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
