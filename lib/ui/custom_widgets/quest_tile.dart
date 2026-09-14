import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/constants/string_constants.dart';
import 'package:khaanado/model/quest.dart';
import 'package:khaanado/ui/custom_widgets/daily_reset_ticker.dart';

class QuestTile extends StatefulWidget {
  const QuestTile({
    super.key,
    required this.quest,
    required this.onClaim,
    this.compact = false,
    this.celebrate = false,
    this.onCelebrateDone,
  });

  final QuestProgress quest;
  final VoidCallback onClaim;
  final bool compact;
  final bool celebrate;
  final VoidCallback? onCelebrateDone;

  static const compactWidth = 236.0;
  static const compactHeight = 112.0;

  @override
  State<QuestTile> createState() => _QuestTileState();
}

class _QuestTileState extends State<QuestTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: widget.celebrate ? 0 : 1,
    );
    if (widget.celebrate && widget.quest.claimed) {
      _play();
    }
  }

  @override
  void didUpdateWidget(QuestTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final justClaimed = !oldWidget.quest.claimed && widget.quest.claimed;
    final shouldReplay = widget.celebrate && !oldWidget.celebrate;
    if ((justClaimed || shouldReplay) && !_playing) {
      _play();
    }
  }

  Future<void> _play() async {
    _playing = true;
    HapticFeedback.mediumImpact();
    await _burst.forward(from: 0);
    widget.onCelebrateDone?.call();
    if (mounted) setState(() => _playing = false);
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _burst,
      builder: (context, child) {
        final t = _playing
            ? Curves.easeOut.transform(_burst.value.clamp(0.0, 1.0))
            : 0.0;
        return Transform.scale(
          scale: 1 + (t * 0.03),
          child: child,
        );
      },
      child: widget.compact ? _compactCard() : _fullCard(),
    );
  }

  Widget _compactCard() {
    final def = widget.quest.definition;
    final claimed = widget.quest.claimed;
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.0,
      child: SizedBox(
        width: QuestTile.compactWidth,
        height: QuestTile.compactHeight,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: ColorConstants.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.quest.canClaim || _playing
                  ? ColorConstants.accent.withValues(alpha: 0.5)
                  : ColorConstants.cardBorder,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _icon(def.icon, 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      def.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.1,
                        color: ColorConstants.textPrimary,
                      ),
                    ),
                  ),
                    const SizedBox(width: 8),
                    _rewardChip(def.reward, claimed: claimed),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  def.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ColorConstants.textSecondary,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              _bar(claimed),
              const SizedBox(height: 8),
              _compactFooter(claimed, def.target),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fullCard() {
    final def = widget.quest.definition;
    final claimed = widget.quest.claimed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorConstants.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.quest.canClaim || _playing
              ? ColorConstants.accent.withValues(alpha: 0.55)
              : ColorConstants.cardBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _icon(def.icon, 36),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: ColorConstants.textPrimary,
                      ),
                    ),
                    Text(
                      def.subtitle,
                      style: TextStyle(
                        color: ColorConstants.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _rewardChip(def.reward, claimed: claimed),
            ],
          ),
          const SizedBox(height: 12),
          _bar(claimed),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${widget.quest.displayProgress}/${def.target}',
                style: TextStyle(
                  color: ColorConstants.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              _status(claimed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactFooter(bool claimed, int target) {
    final count = Text(
      '${widget.quest.displayProgress}/$target',
      style: TextStyle(
        color: claimed ? ColorConstants.success : ColorConstants.textMuted,
        fontSize: 11,
        height: 1.0,
        fontWeight: FontWeight.w600,
      ),
    );
    if (claimed) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 13,
            color: ColorConstants.success,
          ),
          const SizedBox(width: 4),
          count,
        ],
      );
    }
    return Row(
      children: [
        count,
        const Spacer(),
        Flexible(child: _status(false, compact: true)),
      ],
    );
  }

  Widget _icon(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ColorConstants.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: ColorConstants.accent, size: size * 0.52),
    );
  }

  Widget _rewardChip(int reward, {bool claimed = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: claimed
            ? ColorConstants.success.withValues(alpha: 0.16)
            : ColorConstants.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '+$reward',
        style: TextStyle(
          color: claimed ? ColorConstants.success : ColorConstants.accent,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          height: 1.1,
        ),
      ),
    );
  }

  Widget _bar(bool claimed) {
    final t = claimed ? 1.0 : widget.quest.fraction.clamp(0.0, 1.0);
    return SizedBox(
      height: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth * t
              : 0.0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              color: ColorConstants.surface,
              alignment: Alignment.centerLeft,
              child: Container(
                width: width,
                height: 4,
                color: claimed
                    ? ColorConstants.success
                    : ColorConstants.accent,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _status(bool claimed, {bool compact = false}) {
    if (claimed) {
      if (!compact && widget.quest.definition.isDaily) {
        return const DailyResetTicker(compact: true);
      }
      return Text(
        StringConstants.claimed,
        style: TextStyle(
          color: ColorConstants.success,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 1.0,
        ),
      );
    }
    if (!widget.quest.canClaim) return const SizedBox.shrink();
    return GestureDetector(
      onTap: widget.onClaim,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 2 : 3,
        ),
        decoration: BoxDecoration(
          gradient: ColorConstants.buttonGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          StringConstants.claim,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
