import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/document.dart';
import '../providers/data_provider.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadDocuments();
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
              child: Text('Документы', style: AppTextStyles.heading1),
            ),
            _buildSummary(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<DataProvider>().loadDocuments(),
                color: AppColors.primaryPurple,
                child: Consumer<DataProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoadingDocuments && provider.documents.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primaryPurple),
                      );
                    }

                    if (provider.documents.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: provider.documents.length,
                      itemBuilder: (context, index) {
                        return _DocumentCard(document: provider.documents[index]);
                      },
                    );
                  },
                ),
              ),
            ),
            _buildWebPortalButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Consumer<DataProvider>(
      builder: (context, provider, _) {
        return GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '${provider.validDocumentsCount}',
                'Действительных',
                AppColors.success,
                Icons.check_circle_outline,
              ),
              Container(width: 1, height: 40, color: AppColors.glassBorder),
              _buildSummaryItem(
                '${provider.expiringDocumentsCount}',
                'Истекают',
                AppColors.warning,
                Icons.warning_amber_outlined,
              ),
              Container(width: 1, height: 40, color: AppColors.glassBorder),
              _buildSummaryItem(
                '${provider.expiredDocumentsCount}',
                'Просрочено',
                AppColors.error,
                Icons.error_outline,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String count, String label, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              count,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 80, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Нет документов', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Загрузите документы через веб-портал',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWebPortalButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassButton(
        text: 'Обновить через веб-портал',
        isPrimary: false,
        icon: Icons.open_in_new,
        onPressed: () async {
          final uri = Uri.parse('https://me.synthnova.me');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final TalentDocument document;

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                document.documentType.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.documentType.displayName,
                  style: AppTextStyles.heading3,
                ),
                if (document.documentNumber != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    document.documentNumber!,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
                if (document.expiryDate != null) ...[
                  const SizedBox(height: 8),
                  _buildExpiryInfo(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusIcon(),
        ],
      ),
    );
  }

  Widget _buildExpiryInfo() {
    final days = document.daysUntilExpiry;
    String text;
    Color color;

    if (days == null) {
      return const SizedBox.shrink();
    } else if (days <= 0) {
      text = 'Просрочен';
      color = AppColors.error;
    } else if (days <= 7) {
      text = 'Истекает через $days дн.';
      color = AppColors.error;
    } else if (days <= 30) {
      text = 'Истекает через $days дн.';
      color = AppColors.warning;
    } else {
      text = 'До ${document.expiryDate}';
      color = AppColors.success;
    }

    return Row(
      children: [
        Icon(Icons.event, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (document.status) {
      case DocumentStatus.valid:
        if (document.isExpiringSoon) {
          icon = Icons.warning_amber;
          color = AppColors.warning;
        } else {
          icon = Icons.check_circle;
          color = AppColors.success;
        }
        break;
      case DocumentStatus.expired:
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      case DocumentStatus.pending:
        icon = Icons.hourglass_empty;
        color = AppColors.warning;
        break;
      case DocumentStatus.rejected:
        icon = Icons.block;
        color = AppColors.error;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getStatusColor() {
    if (document.isExpired) return AppColors.error;
    if (document.isExpiringSoon) return AppColors.warning;
    if (document.status == DocumentStatus.valid) return AppColors.success;
    return AppColors.textMuted;
  }
}
