// 首页（搜索页）
// 参考官方布局，包含搜索框、过滤条件、视频列表

import 'package:flutter/material.dart';
import 'package:hibiscus/src/ui/theme/app_theme.dart';
import 'package:hibiscus/src/ui/widgets/video_grid.dart';
import 'package:hibiscus/src/ui/widgets/filter_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // TODO: 加载首页数据
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // 滚动到底部时加载更多
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // TODO: 加载更多数据
    }
  }
  
  void _onSearch(String query) {
    // TODO: 执行搜索
    debugPrint('Search: $query');
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Breakpoints.isDesktop(context);
    
    return Scaffold(
      appBar: AppBar(
        // 移动端显示侧栏按钮
        leading: isDesktop ? null : IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        // 搜索框
        title: _buildSearchField(context),
        titleSpacing: isDesktop ? 16 : 0,
      ),
      body: Column(
        children: [
          // 过滤条件栏
          const FilterBar(),
          
          // 视频列表
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: 刷新数据
              },
              child: VideoGrid(
                controller: _scrollController,
                videos: const [], // TODO: 从状态管理获取
                isLoading: false, // TODO: 从状态管理获取
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: '搜索视频...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textInputAction: TextInputAction.search,
      onSubmitted: _onSearch,
      onChanged: (value) => setState(() {}),
    );
  }
}
