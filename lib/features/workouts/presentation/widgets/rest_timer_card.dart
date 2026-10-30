import 'package:flutter/material.dart';
import 'package:spotter/core/date_formatter.dart';

class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    super.key,
    required this.remaining,
    required this.total,
    required this.onSkip,
    this.upNext,
  });

  final Duration remaining;
  final Duration total;
  final VoidCallback onSkip;
  final String? upNext;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final totalSeconds = total.inSeconds;
    final remainingSeconds = remaining.inSeconds.clamp(0, totalSeconds);
    final progress = totalSeconds == 0 ? 0.0 : remainingSeconds / totalSeconds;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.primary.withAlpha(90)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'RESTING',
              style: text.labelSmall!.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 148,
              height: 148,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 148,
                    height: 148,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: cs.primaryContainer,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormatter.duration(remaining),
                        style: text.headlineLarge!.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'OF ${DateFormatter.duration(total)}',
                        style: text.labelSmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (upNext != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'UP NEXT',
                      style: text.labelSmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        upNext!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.skip_next),
              label: const Text('SKIP REST'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
