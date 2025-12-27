import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobs_provider.dart';
import '../utils/constants.dart';
import '../widgets/job_card.dart';
import '../widgets/glass_card.dart';
import '../main.dart';
import 'job_details_screen.dart';
import 'notifications_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _scrollController = ScrollController();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobsProvider>().loadJobs(refresh: true);
      _loadUnreadCount();
    });
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await apiService.getUnreadNotificationsCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<JobsProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadJobs();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCityFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<JobsProvider>().loadJobs(refresh: true),
                color: AppColors.primaryPurple,
                backgroundColor: AppColors.surface,
                child: Consumer<JobsProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.jobs.isEmpty) {
                      return _buildLoadingState();
                    }

                    if (provider.error != null && provider.jobs.isEmpty) {
                      return _buildErrorState(provider.error!);
                    }

                    if (provider.jobs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: provider.jobs.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == provider.jobs.length) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          );
                        }

                        final job = provider.jobs[index];
                        return JobCard(
                          job: job,
                          onTap: () => _openJobDetails(job.id),
                          onApply: job.hasApplied
                              ? null
                              : () => _applyForJob(job.id),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryPurple,
                  AppColors.primaryPurple.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('StaffHub', style: AppTextStyles.heading3),
                Text('Доступные вакансии', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          _buildNotificationBell(),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        _loadUnreadCount();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.glassLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityFilter() {
    return Consumer<JobsProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip('All', provider),
              const SizedBox(width: 8),
              _buildFilterChip('Dubai', provider),
              const SizedBox(width: 8),
              _buildFilterChip('Abu Dhabi', provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String city, JobsProvider provider) {
    final isSelected = provider.cityFilter == city;
    return GestureDetector(
      onTap: () => provider.setCityFilter(city),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurple
              : AppColors.glassLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.glassBorder,
          ),
        ),
        child: Text(
          city,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primaryPurple),
          const SizedBox(height: 16),
          Text('Загрузка вакансий...', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Ошибка загрузки', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(error, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GlassButton(
              text: 'Повторить',
              onPressed: () => context.read<JobsProvider>().loadJobs(refresh: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Нет доступных вакансий', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Новые вакансии появятся здесь',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openJobDetails(int jobId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(jobId: jobId),
      ),
    );
  }

  Future<void> _applyForJob(int jobId) async {
    final provider = context.read<JobsProvider>();
    final success = await provider.applyForJob(jobId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Отклик отправлен!' : provider.error ?? 'Ошибка',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
