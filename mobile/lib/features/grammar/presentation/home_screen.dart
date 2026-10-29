import 'package:flutter/material.dart';

import '../data/grammar_concept.dart';
import '../data/grammar_concept_repository.dart';
import '../../learning/data/learning_path_api.dart';
import '../../learning/data/learning_path_models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    this.learningPathApi,
    this.accessToken,
    this.onOpenProfile,
    this.onOpenLesson,
    this.onStartAssessment,
  });

  final GrammarConceptRepository repository;
  final LearningPathApi? learningPathApi;
  final String? accessToken;
  final VoidCallback? onOpenProfile;
  final ValueChanged<GrammarConcept>? onOpenLesson;
  final VoidCallback? onStartAssessment;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<LearningPathItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = _loadItems();
  }

  Future<List<LearningPathItem>> _loadItems() async {
    final api = widget.learningPathApi;
    final token = widget.accessToken;
    if (api != null && token != null) return (await api.fetchPath(token)).items;
    return (await widget.repository.fetchConcepts())
        .map(LearningPathItem.fromConcept)
        .toList(growable: false);
  }

  Future<void> _retry() async {
    final request = _loadItems();
    setState(() {
      _items = request;
    });
    try {
      await request;
    } catch (_) {
      // FutureBuilder renders the request's error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _retry(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
                sliver: SliverList.list(children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 23),
                      ),
                      const SizedBox(width: 11),
                      Text('polyglot', style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      )),
                      const Spacer(),
                      if (widget.onOpenProfile != null)
                        IconButton(
                          tooltip: 'Profilim',
                          onPressed: widget.onOpenProfile,
                          icon: const Icon(Icons.account_circle_outlined),
                        ),
                      IconButton(
                        tooltip: 'Öğrenme yolunu yenile',
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F1E9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('İNGİLİZCE YOLCULUĞUN', style: textTheme.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        )),
                        const SizedBox(height: 10),
                        Text('Küçük adımlar.\nGerçek ilerleme.', style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                          letterSpacing: -0.8,
                        )),
                        const SizedBox(height: 10),
                        Text('İngilizce temellerini adım adım öğren.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF53645B),
                              height: 1.45,
                            )),
                      ],
                    ),
                  ),
                  if (widget.onStartAssessment != null) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onStartAssessment,
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Seviyeni belirle'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ÖĞRENME YOLU', style: textTheme.labelMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            )),
                            const SizedBox(height: 5),
                            Text('Dil bilgisi temelleri', style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.35,
                            )),
                          ],
                        ),
                      ),
                      const Icon(Icons.route_rounded, color: Color(0xFF719084)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  FutureBuilder<List<LearningPathItem>>(
                    future: _items,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _LoadingState();
                      }
                      if (snapshot.hasError) return _ErrorState(onRetry: _retry);
                      final items = snapshot.data ?? const [];
                      if (items.isEmpty) return const _EmptyState();
                      return Column(
                        children: items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ConceptCard(
                            item: item,
                            onTap: item.hasLesson && widget.onOpenLesson != null
                                ? () => widget.onOpenLesson!(item.toGrammarConcept())
                                : null,
                          ),
                        )).toList(growable: false),
                      );
                    },
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({required this.item, this.onTap});

  final LearningPathItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item.orderIndex.toString().padLeft(2, '0'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                )),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(item.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3EE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(item.cefrLevel,
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(item.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF657168),
                      height: 1.4,
                    )),
                  const SizedBox(height: 7),
                  Row(children: [
                    Expanded(child: Text(
                      item.recommended ? 'Sıradaki önerilen konu' : _statusLabel(item.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: item.recommended ? theme.colorScheme.primary : const Color(0xFF657168),
                        fontWeight: item.recommended ? FontWeight.w800 : FontWeight.w500,
                      ),
                    )),
                    if (item.masteryScore != null)
                      Text('${(item.masteryScore! * 100).round()}%',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ]),
                  if (item.masteryScore != null) ...[
                    const SizedBox(height: 5),
                    LinearProgressIndicator(value: item.masteryScore, minHeight: 5),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary),
            ] else if (!item.hasLesson) ...[
              const SizedBox(width: 8),
              Text('Yakında', style: theme.textTheme.labelSmall),
            ],
          ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'YETERLİ' => 'Tamamlandı',
    'TEKRAR_ZAMANI' => 'Tekrar zamanı',
    'GELİŞİYOR' => 'Gelişiyor',
    _ => 'Henüz başlanmadı',
  };
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.cloud_off_rounded, color: Color(0xFF9B5148)),
        const SizedBox(height: 10),
        Text('Öğrenme yolu yüklenemedi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Text('İnternet bağlantını kontrol edip tekrar dene.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF657168))),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: onRetry, child: const Text('Tekrar dene')),
      ]),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(children: [
        const Icon(Icons.menu_book_rounded, size: 30, color: Color(0xFF719084)),
        const SizedBox(height: 8),
        Text('Öğrenme yolun hazırlanıyor',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Dil bilgisi konuları hazır olduğunda burada görünecek.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF657168))),
      ]),
    ),
  );
}
