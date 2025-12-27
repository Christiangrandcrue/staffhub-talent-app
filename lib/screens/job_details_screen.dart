import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/jobs_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().loadJobDetails(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<JobsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.selectedJob == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              );
            }

            final job = provider.selectedJob;
            if (job == null) {
              return _buildErrorState();
            }

            return CustomScrollView(
              slivers: [
                _buildAppBar(job.title),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rate & Earnings card
                      GlassCard(
                        isHighlighted: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                '${job.ratePerHour} ${job.rateCurrency}',
                                'Ставка/час',
                                Icons.payments_outlined,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              color: AppColors.glassBorder,
                            ),
                            Expanded(
                              child: _buildStatItem(
                                '${job.totalEarning} ${job.rateCurrency}',
                                'Всего за смену',
                                Icons.account_balance_wallet_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main info
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.work_outline, 'Роль', job.roleType),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.location_on_outlined, 'Место', job.venueName),
                            if (job.venueAddress != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Text(
                                  job.venueAddress!,
                                  style: AppTextStyles.bodySmall,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.place_outlined, 'Город', job.city),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.calendar_today_outlined, 'Дата', job.eventDate),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.access_time,
                              'Время',
                              '${job.startTime} - ${job.endTime} (${job.durationHours}ч)',
                            ),
                          ],
                        ),
                      ),

                      // Description
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Описание', style: AppTextStyles.heading3),
                            const SizedBox(height: 8),
                            Text(job.description, style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ),

                      // Requirements
                      if (job.dressCode != null || job.specialRequirements != null)
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Требования', style: AppTextStyles.heading3),
                              const SizedBox(height: 12),
                              if (job.dressCode != null)
                                _buildInfoRow(Icons.checkroom, 'Дресс-код', job.dressCode!),
                              if (job.specialRequirements != null) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.info_outline,
                                  'Особые требования',
                                  job.specialRequirements!,
                                ),
                              ],
                              if (job.languagesRequired.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.translate,
                                  'Языки',
                                  job.languagesRequired.map((l) => l.toUpperCase()).join(', '),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // Contact
                      if (job.contactPerson != null || job.contactPhone != null)
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Координатор', style: AppTextStyles.heading3),
                              const SizedBox(height: 12),
                              if (job.contactPerson != null)
                                _buildInfoRow(Icons.person_outline, 'Имя', job.contactPerson!),
                              if (job.contactPhone != null) ...[
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: () => _callPhone(job.contactPhone!),
                                  child: _buildInfoRow(
                                    Icons.phone_outlined,
                                    'Телефон',
                                    job.contactPhone!,
                                    linkColor: AppColors.primaryPurple,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // Tags
                      GlassCard(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (job.requiresEmiratesId)
                              StatusChip(
                                text: 'Emirates ID',
                                color: AppColors.secondaryAmber,
                                icon: Icons.badge,
                              ),
                            StatusChip(
                              text: '${job.slotsAvailable}/${job.slotsTotal} мест',
                              color: job.slotsAvailable > 0
                                  ? AppColors.success
                                  : AppColors.error,
                              icon: Icons.people,
                            ),
                            ...job.skillsRequired.map(
                              (skill) => StatusChip(
                                text: skill,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<JobsProvider>(
        builder: (context, provider, _) {
          final job = provider.selectedJob;
          if (job == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            child: SafeArea(
              child: job.hasApplied
                  ? const StatusChip(
                      text: 'Вы уже откликнулись',
                      color: AppColors.success,
                      icon: Icons.check_circle,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            text: 'Не могу',
                            isPrimary: false,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GlassButton(
                            text: 'Откликнуться',
                            icon: Icons.send,
                            onPressed: () => _applyForJob(job.id),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(String title) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.glassLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: AppTextStyles.heading3.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 16),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryPurple, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(color: AppColors.primaryPurple),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? linkColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: linkColor,
                  decoration: linkColor != null ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Не удалось загрузить вакансию', style: AppTextStyles.heading3),
          const SizedBox(height: 24),
          GlassButton(
            text: 'Назад',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _applyForJob(int jobId) async {
    final provider = context.read<JobsProvider>();
    final success = await provider.applyForJob(jobId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Отклик отправлен!' : provider.error ?? 'Ошибка'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
