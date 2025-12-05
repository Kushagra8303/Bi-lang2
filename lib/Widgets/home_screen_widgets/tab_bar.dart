import 'package:flutter/material.dart';

class HomeTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;

  const HomeTabBar({
    super.key,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      child: TabBar(
        indicatorWeight: 5,
        indicatorSize: TabBarIndicatorSize.label,
        controller: tabController,
        labelStyle: theme.textTheme.bodyLarge,
        unselectedLabelStyle: theme.textTheme.labelLarge,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(5),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Tab(text: "CHATS"),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Tab(text: "GROUPS"),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Tab(text: "CALLS"),
          ),

        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
