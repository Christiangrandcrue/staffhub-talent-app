import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/application.dart';
import '../providers/data_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Мои отклики', style: AppTextStyles.heading1),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<DataProvider>().loadApplications(),
                color: AppColors.primaryPurple,
                child: Consumer<DataProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingApplications && provider.applications.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryPurple),
                      );
                    }

                    if (provider.applications.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: provider.applications.length,
                      itemBuilder: (context, index) {
                        return _ApplicationCard(
                          application: provider.applications[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Пока нет откликов', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Откликайтесь на вакансии,\nони появятся здесь',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Application application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.jobTitle,
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.venueName,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(application.city, style: AppTextStyles.bodySmall),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(application.eventDate, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 16, color: AppColors.primaryPurple),
              const SizedBox(width: 4),
              Text(
                '${application.ratePerHour} ${application.rateCurrency}/hr',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;

    switch (application.status) {
      case ApplicationStatus.pending:
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case ApplicationStatus.shortlisted:
        color = AppColors.info;
        icon = Icons.star_outline;
        break;
      case ApplicationStatus.approved:
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        break;
      case ApplicationStatus.confirmed:
        color = AppColors.success;
        icon = Icons.verified;
        break;
      case ApplicationStatus.rejected:
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        break;
      case ApplicationStatus.withdrawn:
        color = AppColors.textMuted;
        icon = Icons.undo;
        break;
    }

    return StatusChip(
      text: application.status.displayName,
      color: color,
      icon: icon,
    );
  }
}
