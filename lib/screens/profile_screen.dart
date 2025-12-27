import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final profile = auth.profile;
            if (profile == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Profile header
                  _buildProfileHeader(profile.photoUrl, profile.fullName),
                  
                  const SizedBox(height: 24),
                  
                  // Rating with reviews
                  _buildRatingCard(profile.avgRating, profile.totalRatings),
                  
                  // Reviews history
                  Consumer<DataProvider>(
                    builder: (context, data, _) {
                      if (data.ratings != null && data.ratings!['ratings'] != null) {
                        final reviews = data.ratings!['ratings'] as List? ?? [];
                        if (reviews.isNotEmpty) {
                          return _buildReviewsCard(reviews.take(3).toList());
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  
                  // Info cards
                  _buildInfoCard(
                    title: 'Основная информация',
                    items: [
                      _InfoItem(Icons.email_outlined, 'Email', auth.user?.email ?? ''),
                      if (profile.city != null)
                        _InfoItem(Icons.location_on_outlined, 'Город', '${profile.city}, ${profile.country ?? "UAE"}'),
                      if (profile.nationality != null)
                        _InfoItem(Icons.flag_outlined, 'Национальность', profile.nationality!),
                    ],
                  ),
                  
                  _buildInfoCard(
                    title: 'Параметры',
                    items: [
                      if (profile.heightCm != null)
                        _InfoItem(Icons.height, 'Рост', '${profile.heightCm} см'),
                      if (profile.weightKg != null)
                        _InfoItem(Icons.monitor_weight_outlined, 'Вес', '${profile.weightKg} кг'),
                      if (profile.experienceYears != null)
                        _InfoItem(Icons.work_history_outlined, 'Опыт', '${profile.experienceYears} лет'),
                    ],
                  ),
                  
                  if (profile.languages.isNotEmpty)
                    _buildTagsCard('Языки', profile.languages),
                  
                  if (profile.skills.isNotEmpty)
                    _buildTagsCard('Навыки', profile.skills),
                  
                  // Emirates ID status
                  _buildEmiratesIdCard(profile.emiratesIdValid, profile.emiratesIdExpiry),
                  
                  // Rate range
                  if (profile.hourlyRateMin != null || profile.hourlyRateMax != null)
                    _buildRateCard(profile.hourlyRateMin, profile.hourlyRateMax),
                  
                  const SizedBox(height: 16),
                  
                  // Edit button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassButton(
                      text: 'Редактировать профиль',
                      isPrimary: false,
                      icon: Icons.edit_outlined,
                      onPressed: () => _openWebPortal(),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Logout button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GlassButton(
                      text: 'Выйти',
                      isPrimary: false,
                      icon: Icons.logout,
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String? photoUrl, String name) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryPurple,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.person, size: 60, color: AppColors.textMuted),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.person, size: 60, color: AppColors.textMuted),
                    ),
                  )
                : Container(
                    color: AppColors.surface,
                    child: const Icon(Icons.person, size: 60, color: AppColors.textMuted),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: AppTextStyles.heading1),
      ],
    );
  }

  Widget _buildRatingCard(double rating, int totalRatings) {
    return GlassCard(
      isHighlighted: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < rating.floor()
                          ? Icons.star
                          : (index < rating ? Icons.star_half : Icons.star_border),
                      color: AppColors.secondaryAmber,
                      size: 28,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${rating.toStringAsFixed(1)} ($totalRatings отзывов)',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<_InfoItem> items}) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: AppTextStyles.bodySmall),
                      Text(item.value, style: AppTextStyles.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTagsCard(String title, List<String> tags) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryPurple),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiratesIdCard(bool isValid, String? expiryDate) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isValid ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isValid ? Icons.verified : Icons.warning_amber,
              color: isValid ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Emirates ID', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(
                  isValid
                      ? (expiryDate != null ? 'Действителен до $expiryDate' : 'Действителен')
                      : 'Не загружен или просрочен',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isValid ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(int? min, int? max) {
    final rateText = min != null && max != null
        ? '$min - $max AED/hr'
        : '${min ?? max} AED/hr';

    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payments_outlined, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Желаемая ставка', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(rateText, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsCard(List reviews) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_outlined, size: 20, color: AppColors.secondaryAmber),
              const SizedBox(width: 8),
              Text('Отзывы менеджеров', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.map((review) => _buildReviewItem(review)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    final score = review['score'] ?? 0;
    final comment = review['comment'] ?? '';
    final role = review['role'] ?? '';
    final eventTitle = review['event_title'] ?? '';
    final createdAt = review['created_at'] ?? '';

    String formattedDate = '';
    try {
      final date = DateTime.parse(createdAt);
      formattedDate = '${date.day}.${date.month}.${date.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < score ? Icons.star : Icons.star_border,
                  color: AppColors.secondaryAmber,
                  size: 16,
                );
              }),
              const Spacer(),
              Text(formattedDate, style: AppTextStyles.bodySmall),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"$comment"',
              style: AppTextStyles.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (eventTitle.isNotEmpty || role.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              [if (role.isNotEmpty) role, if (eventTitle.isNotEmpty) eventTitle].join(' • '),
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openWebPortal() async {
    final uri = Uri.parse('https://me.synthnova.me');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Выход', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Выйти', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem(this.icon, this.label, this.value);
}
