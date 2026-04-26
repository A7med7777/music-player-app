import 'package:flutter/material.dart';
import 'package:music_player_app/core/theme/app_tokens.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      width: double.infinity,
      color: tokens.colorSurfaceVariant,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing16,
        vertical: tokens.spacing8,
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: tokens.colorOnSurfaceVariant,
            semanticLabel: message,
          ),
          SizedBox(width: tokens.spacing8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: tokens.colorOnSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
