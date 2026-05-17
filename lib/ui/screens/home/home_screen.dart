import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uscitecalabria/logic/providers/transaction_provider.dart';
import 'package:uscitecalabria/logic/providers/subject_provider.dart';
import 'package:uscitecalabria/logic/providers/group_provider.dart';
import 'package:uscitecalabria/logic/providers/entry_provider.dart';
import 'package:uscitecalabria/utils/constants.dart';
import 'package:uscitecalabria/ui/widgets/app_drawer.dart';
import 'package:uscitecalabria/data/models/transaction.dart';
import 'package:uscitecalabria/data/models/subject.dart';
import 'package:uscitecalabria/data/models/group.dart';
import 'package:uscitecalabria/data/models/entry.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _showBalanceCard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _showBalanceCard = true);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _computeSubjectBalance(List<AppTransaction> transactions, Subject subject) {
    final subjectTransactions = transactions.where((t) {
      if (t.type == TransactionType.transfer) {
        return t.fromSubjectId == subject.id || t.toSubjectId == subject.id;
      }
      return t.subjectId == subject.id;
    }).toList();
    final income = subjectTransactions.where((t) => t.type == TransactionType.income).fold(0.0, (acc, t) => acc + t.amount);
    final expense = subjectTransactions.where((t) => t.type == TransactionType.expense).fold(0.0, (acc, t) => acc + t.amount);
    final transferIn = subjectTransactions.where((t) => t.type == TransactionType.transfer && t.toSubjectId == subject.id).fold(0.0, (acc, t) => acc + t.amount);
    final transferOut = subjectTransactions.where((t) => t.type == TransactionType.transfer && t.fromSubjectId == subject.id).fold(0.0, (acc, t) => acc + t.amount);
    return income - expense + transferIn - transferOut;
  }

  double _computeTotalBalance(List<AppTransaction> transactions, List<Subject> subjects) {
    return subjects.fold<double>(0.0, (acc, s) => acc + _computeSubjectBalance(transactions, s));
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);
    final groupsAsync = ref.watch(groupsProvider);
    final entriesAsync = ref.watch(entriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Errore: $e')),
        data: (subjects) => transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Errore: $e')),
          data: (transactions) => groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Errore: $e')),
            data: (groups) => entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Errore: $e')),
              data: (entries) {
                final latest = transactions.take(5).toList();
                final totalBalance = _computeTotalBalance(transactions, subjects);

                // Calcoli continuativi per la card ultime transazioni
                final income = transactions.where((t) => t.type == TransactionType.income).fold(0.0, (acc, t) => acc + t.amount);
                final expense = transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (acc, t) => acc + t.amount);
                final anticipi = transactions.where((t) => t.type == TransactionType.anticipi).fold(0.0, (acc, t) => acc + t.amount);
                final balance = income - expense;

                return Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: subjects.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Nessun soggetto. Aggiungine uno!',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    )
                                  : GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.85,
                                      ),
                                      itemCount: subjects.length,
                                      itemBuilder: (context, index) {
                                        final s = subjects[index];
                                        final subjectBalance = _computeSubjectBalance(transactions, s);
                                        final txCount = transactions.where((t) {
                                          if (t.type == TransactionType.transfer) {
                                            return t.fromSubjectId == s.id || t.toSubjectId == s.id;
                                          }
                                          return t.subjectId == s.id;
                                        }).length;

                                        final delay = (index * 100).clamp(0, 500);
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: 1),
                                          duration: Duration(milliseconds: 300 + delay),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: 0.8 + (0.2 * value),
                                              child: Opacity(
                                                opacity: value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: _buildSubjectCard(context, s, subjectBalance, txCount),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 12),
                            _buildTotalBalanceCard(context, totalBalance),
                            const SizedBox(height: 12),
                            Expanded(
                              flex: 3,
                              child: _buildLatestTransactionsCard(
                                context,
                                latest,
                                transactions,
                                subjects,
                                entries,
                                groups,
                                income,
                                expense,
                                anticipi,
                                balance,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestTransactionsCard(
    BuildContext context,
    List<AppTransaction> latest,
    List<AppTransaction> allTransactions,
    List<Subject> subjects,
    List<Entry> entries,
    List<Group> groups,
    double income,
    double expense,
    double anticipi,
    double balance,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => context.push('/all-transactions'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Riepilogo',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: latest.isEmpty
                      ? Center(
                          child: Text(
                            'Nessuna',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: latest.length,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, index) {
                            final t = latest[index];

                            Color amountColor;
                            IconData icon;
                            if (t.type == TransactionType.transfer) {
                              icon = Icons.swap_horiz;
                              amountColor = AppColors.transferColor;
                            } else if (t.type == TransactionType.anticipi) {
                              icon = Icons.payment;
                              amountColor = AppColors.anticipiColor;
                            } else {
                              icon = t.type == TransactionType.income ? Icons.trending_up : Icons.trending_down;
                              amountColor = t.type == TransactionType.income ? AppColors.incomeColor : AppColors.expenseColor;
                            }

                            final dateStr = DateFormat('dd/MM/yyyy').format(t.date);

                            String subjectName;
                            if (t.type == TransactionType.transfer) {
                              final from = subjects.where((s) => s.id == t.fromSubjectId).firstOrNull;
                              final to = subjects.where((s) => s.id == t.toSubjectId).firstOrNull;
                              subjectName = '${from?.name ?? "?"} → ${to?.name ?? "?"}';
                            } else {
                              final s = subjects.where((s) => s.id == t.subjectId).firstOrNull;
                              subjectName = s?.name ?? '?';
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(icon, color: amountColor, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            dateStr,
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              subjectName,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '€ ${t.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: amountColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (t.type != TransactionType.transfer) ...[
                                        const SizedBox(height: 2),
                                        _buildHomeEntryGroupRow(context, t, entries, groups),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeEntryGroupRow(BuildContext context, AppTransaction t, List<Entry> entries, List<Group> groups) {
    if (t.type == TransactionType.transfer) return const SizedBox.shrink();

    final entry = entries.where((e) => e.id == t.entryId).firstOrNull;
    if (entry == null) {
      return Text(
        'Voce eliminata',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final group = groups.where((g) => g.id == entry.groupId).firstOrNull;
    if (group == null) {
      return Text(
        entry.name,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        Text(entry.name, style: Theme.of(context).textTheme.bodySmall),
        Text(' - ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(
            group.name,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, Subject subject, double balance, int txCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/subjects/${subject.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                child: Icon(_getIconData(subject.icon), color: Theme.of(context).colorScheme.primary, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                subject.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '€ ${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: balance >= 0 ? AppColors.incomeColor : AppColors.expenseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                '$txCount movimenti',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'person_outline':
        return Icons.person_outline;
      default:
        return Icons.person;
    }
  }

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance) {
    final balanceColor = totalBalance >= 0 ? AppColors.incomeColor : AppColors.expenseColor;

    return AnimatedSlide(
      offset: _showBalanceCard ? Offset.zero : const Offset(0, 0.2),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _showBalanceCard ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: totalBalance.abs()),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Text(
                    '€ ${totalBalance >= 0 ? value.toStringAsFixed(2) : (-value).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
