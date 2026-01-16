import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget réutilisable pour afficher l'avatar de profil.
/// Optimisé avec const constructor et gestion du cache d'images.
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.radius,
    this.backgroundColor,
  });

  static const _defaultImage = AssetImage('assets/images/profile.png');

  @override
  Widget build(BuildContext context) {
    final hasValidUrl = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      backgroundImage: hasValidUrl
          ? CachedNetworkImageProvider(
              imageUrl!,
              cacheKey: imageUrl,
            )
          : _defaultImage as ImageProvider,
    );
  }
}
