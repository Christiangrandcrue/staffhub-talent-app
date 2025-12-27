import 'package:flutter/material.dart';
import '../models/job.dart';
import '../utils/constants.dart';
import 'glass_card.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      isHighlighted: job.isFeatured,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (job.isFeatured)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.secondaryAmber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryAmber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      job.title,
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildRateBox(),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Venue & Location
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${job.venueName}, ${job.city}',
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Date & Time
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                job.eventDate,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${job.startTime} - ${job.endTime}',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Tags
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTag(job.roleType, AppColors.primaryPurple),
              if (job.requiresEmiratesId)
                _buildTag('Emirates ID', AppColors.secondaryAmber),
              ...job.languagesRequired.take(2).map(
                (lang) => _buildTag(lang.toUpperCase(), AppColors.info),
              ),
              if (job.slotsAvailable > 0)
                _buildTag('${job.slotsAvailable} spots', AppColors.success),
            ],
          ),
          
          // Apply button if not applied
          if (!job.hasApplied && onApply != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GlassButton(
                text: 'Откликнуться',
                onPressed: onApply,
                icon: Icons.send,
              ),
            ),
          ],
          
          if (job.hasApplied) ...[
            const SizedBox(height: 12),
            const StatusChip(
              text: 'Вы откликнулись',
              color: AppColors.success,
              icon: Icons.check_circle_outline,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRateBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple.withValues(alpha: 0.3),
            AppColors.primaryPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPurple.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${job.ratePerHour}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          Text(
            '${job.rateCurrency}/hr',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
