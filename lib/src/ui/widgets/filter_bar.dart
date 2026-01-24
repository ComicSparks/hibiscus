// 过滤条件栏

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:signals/signals_flutter.dart';
import 'package:hibiscus/src/state/search_state.dart';

/// 过滤选项数据（从网页提取）
class FilterOptions {
  // 影片类型
  static const List<MapEntry<String?, String>> genres = [
    MapEntry(null, '全部'),
    MapEntry('裏番', '裏番'),
    MapEntry('泡麵番', '泡麵番'),
    MapEntry('Motion Anime', 'Motion Anime'),
    MapEntry('3DCG', '3DCG'),
    MapEntry('2.5D', '2.5D'),
    MapEntry('2D動畫', '2D動畫'),
    MapEntry('AI生成', 'AI生成'),
    MapEntry('MMD', 'MMD'),
    MapEntry('Cosplay', 'Cosplay'),
  ];
  
  // 排序方式
  static const List<MapEntry<String?, String>> sorts = [
    MapEntry(null, '排序方式'),
    MapEntry('最新上市', '最新上市'),
    MapEntry('最新上傳', '最新上傳'),
    MapEntry('本日排行', '本日排行'),
    MapEntry('本週排行', '本週排行'),
    MapEntry('本月排行', '本月排行'),
    MapEntry('觀看次數', '觀看次數'),
    MapEntry('讚好比例', '讚好比例'),
    MapEntry('時長最長', '時長最長'),
    MapEntry('他們在看', '他們在看'),
  ];
  
  // 发布日期
  static const List<MapEntry<String?, String>> dates = [
    MapEntry(null, '全部'),
    MapEntry('過去 24 小時', '過去 24 小時'),
    MapEntry('過去 2 天', '過去 2 天'),
    MapEntry('過去 1 週', '過去 1 週'),
    MapEntry('過去 1 個月', '過去 1 個月'),
    MapEntry('過去 3 個月', '過去 3 個月'),
    MapEntry('過去 1 年', '過去 1 年'),
  ];
  
  // 年份选项（动态生成）
  static List<MapEntry<String?, String>> get years {
    final currentYear = DateTime.now().year;
    return [
      const MapEntry(null, '全部年份'),
      for (var year = currentYear; year >= 1990; year--)
        MapEntry('$year 年', '$year 年'),
    ];
  }
  
  // 月份选项
  static const List<MapEntry<String?, String>> months = [
    MapEntry(null, '全部月份'),
    MapEntry('1 月', '1 月'),
    MapEntry('2 月', '2 月'),
    MapEntry('3 月', '3 月'),
    MapEntry('4 月', '4 月'),
    MapEntry('5 月', '5 月'),
    MapEntry('6 月', '6 月'),
    MapEntry('7 月', '7 月'),
    MapEntry('8 月', '8 月'),
    MapEntry('9 月', '9 月'),
    MapEntry('10 月', '10 月'),
    MapEntry('11 月', '11 月'),
    MapEntry('12 月', '12 月'),
  ];
  
  // 时长
  static const List<MapEntry<String?, String>> durations = [
    MapEntry(null, '全部'),
    MapEntry('1 分鐘 +', '1 分鐘 +'),
    MapEntry('5 分鐘 +', '5 分鐘 +'),
    MapEntry('10 分鐘 +', '10 分鐘 +'),
    MapEntry('20 分鐘 +', '20 分鐘 +'),
    MapEntry('30 分鐘 +', '30 分鐘 +'),
    MapEntry('60 分鐘 +', '60 分鐘 +'),
    MapEntry('0 - 10 分鐘', '0 - 10 分鐘'),
    MapEntry('0 - 20 分鐘', '0 - 20 分鐘'),
  ];
  
  // 标签分组
  static const Map<String, List<String>> tagGroups = {
    '影片屬性': [
      '無碼', 'AI解碼', '中文字幕', '中文配音', '同人作品', 
      '斷面圖', 'ASMR', '1080p', '60FPS',
    ],
    '人物關係': [
      '近親', '姐', '妹', '母', '女兒', 
      '師生', '情侶', '青梅竹馬', '同事',
    ],
    '角色設定': [
      'JK', '處女', '御姐', '熟女', '人妻', '女教師', '男教師', 
      '女醫生', '女病人', '護士', 'OL', '女警', '大小姐', '偶像', 
      '女僕', '巫女', '魔女', '修女', '風俗娘', '公主', '女忍者', 
      '女戰士', '女騎士', '魔法少女', '異種族', '天使', '妖精', 
      '魔物娘', '魅魔', '吸血鬼', '女鬼', '獸娘', '乳牛', '機械娘', 
      '碧池', '痴女', '雌小鬼', '不良少女', '傲嬌', '病嬌', 
      '無口', '無表情', '眼神死', '正太', '偽娘', '扶他',
    ],
    '外貌身材': [
      '短髮', '馬尾', '雙馬尾', '丸子頭', '巨乳', '乳環', '舌環', 
      '貧乳', '黑皮膚', '曬痕', '眼鏡娘', '獸耳', '尖耳朵', 
      '異色瞳', '美人痣', '肌肉女', '白虎', '陰毛', '腋毛', 
      '大屌', '著衣', '水手服', '體操服', '泳裝', '比基尼', 
      '死庫水', '和服', '兔女郎', '圍裙', '啦啦隊', '絲襪', 
      '吊襪帶', '熱褲', '迷你裙', '性感內衣', '緊身衣', '丁字褲', 
      '高跟鞋', '睡衣', '婚紗', '旗袍', '古裝', '哥德', '口罩', 
      '刺青', '淫紋', '身體寫字',
    ],
    '情境場所': [
      '校園', '教室', '圖書館', '保健室', '游泳池', '愛情賓館', 
      '醫院', '辦公室', '浴室', '窗邊', '公共廁所', '公眾場合', 
      '戶外野戰', '電車', '車震', '遊艇', '露營帳篷', '電影院', 
      '健身房', '沙灘', '溫泉', '夜店', '監獄', '教堂',
    ],
    '故事劇情': [
      '純愛', '戀愛喜劇', '後宮', '十指緊扣', '開大車', 'NTR', 
      '精神控制', '藥物', '痴漢', '阿嘿顏', '精神崩潰', '獵奇', 
      'BDSM', '綑綁', '眼罩', '項圈', '調教', '異物插入', '尋歡洞', 
      '肉便器', '性奴隸', '胃凸', '強制', '輪姦', '凌辱', '性暴力', 
      '逆強制', '女王樣', '榨精', '母女丼', '姐妹丼', '出軌', 
      '醉酒', '攝影', '睡眠姦', '機械姦', '蟲姦', '性轉換', 
      '百合', '耽美', '時間停止', '異世界', '怪獸', '哥布林', '世界末日',
    ],
    '性交體位': [
      '手交', '指交', '乳交', '乳頭交', '肛交', '雙洞齊下', '腳交', 
      '素股', '拳交', '3P', '群交', '口交', '深喉嚨', '口爆', 
      '吞精', '舔蛋蛋', '舔穴', '69', '自慰', '腋交', '舔腋下', 
      '髮交', '舔耳朵', '舔腳', '內射', '外射', '顏射', '潮吹', 
      '懷孕', '噴奶', '放尿', '排便', '騎乘位', '背後位', '顏面騎乘', 
      '火車便當', '一字馬', '性玩具', '飛機杯', '跳蛋', '毒龍鑽', 
      '觸手', '獸交', '頸手枷', '扯頭髮', '掐脖子', '打屁股', 
      '肉棒打臉', '陰道外翻', '男乳首責', '接吻', '舌吻', 'POV',
    ],
  };
}

class FilterBar extends StatefulWidget {
  final VoidCallback? onBatchDownload;
  final VoidCallback? onEnterMultiSelect;

  const FilterBar({
    super.key,
    this.onBatchDownload,
    this.onEnterMultiSelect,
  });

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  // 使用状态管理中的过滤条件
  String? get _selectedGenre => searchState.filters.value?.genre;
  String? get _selectedSort => searchState.filters.value?.sort;
  String? get _selectedYear => searchState.filters.value?.year;
  String? get _selectedMonth => searchState.filters.value?.month;
  String? get _selectedDuration => searchState.filters.value?.duration;
  Set<String> get _selectedTags => Set<String>.from(searchState.filters.value?.tags ?? []);
  bool get _broadMatch => searchState.filters.value?.broadMatch ?? false;

  void _updateGenre(String? value) {
    searchState.updateGenre(value);
  }

  void _updateSort(String? value) {
    searchState.updateSort(value);
  }

  void _updateYear(String? value) {
    searchState.updateYear(value);
  }

  void _updateDuration(String? value) {
    searchState.updateDuration(value);
  }

  void _updateTags(Set<String> tags, bool broadMatch) {
    if (searchState.filters.value == null) return;
    searchState.filters.value = searchState.filters.value!.copyWith(
      tags: tags.toList(),
      broadMatch: broadMatch,
    );
    searchState.needsCloudflare.value = false;
    searchState.videos.value = [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final isMultiSelect = searchState.isMultiSelectMode.value;
      final selectedCount = searchState.selectedVideoIds.value.length;
      final quality = searchState.multiSelectQuality.value;

      if (isMultiSelect) {
        return Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant
                    .withValues(alpha: theme.colorScheme.outlineVariant.a * 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => searchState.exitMultiSelect(),
                icon: const Icon(Icons.close),
                label: const Text('取消'),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: '下载清晰度',
                onSelected: (value) => searchState.multiSelectQuality.value = value,
                itemBuilder: (context) {
                  const items = ['1080P', '720P', '480P', '360P', 'auto'];
                  return items
                      .map((q) => PopupMenuItem(
                            value: q,
                            child: Row(
                              children: [
                                if (q == quality) const Icon(Icons.check, size: 18),
                                if (q == quality) const SizedBox(width: 8),
                                Text(q),
                              ],
                            ),
                          ))
                      .toList();
                },
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.high_quality),
                  label: Text(quality),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: selectedCount == 0 ? null : widget.onBatchDownload,
                icon: const Icon(Icons.download),
                label: Text('下载($selectedCount)'),
              ),
            ],
          ),
        );
      }

      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outlineVariant
                  .withValues(alpha: theme.colorScheme.outlineVariant.a * 0.5),
            ),
          ),
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // 影片类型
              _FilterDropdown(
                label: '類型',
                value: _selectedGenre,
                items: FilterOptions.genres
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (value) {
                  _updateGenre(value);
                },
              ),

            const SizedBox(width: 12),
          
            // 标签（展开为多选）
            _FilterChip(
              label: _selectedTags.isEmpty ? '標籤' : '標籤 (${_selectedTags.length})',
              isSelected: _selectedTags.isNotEmpty,
              onTap: () => _showTagsSheet(context),
            ),

            const SizedBox(width: 12),

            // 排序
            _FilterDropdown(
              label: '排序',
              value: _selectedSort,
              items: FilterOptions.sorts
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) {
                _updateSort(value);
              },
            ),

            const SizedBox(width: 12),

            // 日期
            _FilterChip(
              label: _getDateLabel(),
              isSelected: _selectedYear != null || _selectedMonth != null,
              onTap: () => _showDateSheet(context),
            ),

            const SizedBox(width: 12),

            // 时长
            _FilterDropdown(
              label: '時長',
              value: _selectedDuration,
              items: FilterOptions.durations
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (value) {
                _updateDuration(value);
              },
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: '多选下载',
              onPressed: () {
                if (widget.onEnterMultiSelect != null) {
                  widget.onEnterMultiSelect!();
                } else {
                  searchState.enterMultiSelect();
                }
              },
              icon: const Icon(Icons.playlist_add_check),
            ),
            ],
          ),
        ),
      );
    });
  }
  
  String _getDateLabel() {
    if (_selectedYear != null && _selectedMonth != null) {
      return '$_selectedYear $_selectedMonth';
    } else if (_selectedYear != null) {
      return _selectedYear!;
    } else if (_selectedMonth != null) {
      return _selectedMonth!;
    }
    return '日期';
  }

  void _showTagsSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _TagsSheet(
            scrollController: scrollController,
            selectedTags: _selectedTags,
            broadMatch: _broadMatch,
          );
        },
      ),
    );

    if (result != null) {
      _updateTags(
        Set<String>.from(result['tags'] as List),
        result['broad'] as bool,
      );
    }
  }

  void _showDateSheet(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      builder: (context) => _DateSheet(
        selectedYear: _selectedYear,
        selectedMonth: _selectedMonth,
      ),
    );

    if (result != null) {
      _updateYear(result['year']);
      // 如果需要同时支持月份，可以在状态管理中添加
    }
  }
}

/// 下拉过滤器
class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;
  
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: value != null 
            ? colorScheme.secondaryContainer 
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(label),
          items: items,
          onChanged: onChanged,
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: value != null 
                ? colorScheme.onSecondaryContainer 
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// 可点击的过滤 Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Material(
      color: isSelected 
          ? colorScheme.secondaryContainer 
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? colorScheme.onSecondaryContainer 
                      : colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: isSelected 
                    ? colorScheme.onSecondaryContainer 
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 标签选择底部弹窗
class _TagsSheet extends StatefulWidget {
  final ScrollController scrollController;
  final Set<String> selectedTags;
  final bool broadMatch;
  
  const _TagsSheet({
    required this.scrollController,
    required this.selectedTags,
    required this.broadMatch,
  });
  
  @override
  State<_TagsSheet> createState() => _TagsSheetState();
}

class _TagsSheetState extends State<_TagsSheet> {
  late Set<String> _selectedTags;
  late bool _broadMatch;
  
  @override
  void initState() {
    super.initState();
    _selectedTags = Set<String>.from(widget.selectedTags);
    _broadMatch = widget.broadMatch;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // 顶部拖动条
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant
                .withValues(alpha: theme.colorScheme.onSurfaceVariant.a * 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text('內容標籤', style: theme.textTheme.titleLarge),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _selectedTags.clear()),
                child: const Text('清除'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'tags': _selectedTags.toList(),
                    'broad': _broadMatch,
                  });
                },
                child: const Text('確定'),
              ),
            ],
          ),
        ),
        
        // 广泛配对开关
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('廣泛配對', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      '較多結果，較不精準。配對所有包含任何一個選擇的標籤的影片，而非全部標籤。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _broadMatch,
                onChanged: (value) => setState(() => _broadMatch = value),
              ),
            ],
          ),
        ),
        
        const Divider(height: 16),
        
        // 标签列表
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: FilterOptions.tagGroups.length,
            itemBuilder: (context, index) {
              final group = FilterOptions.tagGroups.entries.elementAt(index);
              return _buildTagGroup(context, group.key, group.value);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTagGroup(BuildContext context, String name, List<String> tags) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// 日期选择底部弹窗
class _DateSheet extends StatefulWidget {
  final String? selectedYear;
  final String? selectedMonth;
  
  const _DateSheet({
    this.selectedYear,
    this.selectedMonth,
  });
  
  @override
  State<_DateSheet> createState() => _DateSheetState();
}

class _DateSheetState extends State<_DateSheet> {
  String? _selectedYear;
  String? _selectedMonth;
  String? _selectedQuickDate;
  
  @override
  void initState() {
    super.initState();
    _selectedYear = widget.selectedYear;
    _selectedMonth = widget.selectedMonth;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant
                .withValues(alpha: theme.colorScheme.onSurfaceVariant.a * 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('發佈日期', style: theme.textTheme.titleLarge),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedYear = null;
                      _selectedMonth = null;
                      _selectedQuickDate = null;
                    });
                  },
                  child: const Text('清除'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'year': _selectedYear,
                      'month': _selectedMonth,
                      'quickDate': _selectedQuickDate,
                    });
                  },
                  child: const Text('確定'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 快速选项
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FilterOptions.dates.map((date) {
                final isSelected = _selectedQuickDate == date.key;
                return FilterChip(
                  label: Text(date.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedQuickDate = selected ? date.key : null;
                      if (selected) {
                        _selectedYear = null;
                        _selectedMonth = null;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          
          const Divider(height: 1),
          
          // 年月选择
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
        child: DropdownButtonFormField<String?>(
          initialValue: _selectedYear,
                    decoration: const InputDecoration(
                      labelText: '年份',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: FilterOptions.years
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value;
                        _selectedQuickDate = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
        child: DropdownButtonFormField<String?>(
          initialValue: _selectedMonth,
                    decoration: const InputDecoration(
                      labelText: '月份',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: FilterOptions.months
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMonth = value;
                        _selectedQuickDate = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
