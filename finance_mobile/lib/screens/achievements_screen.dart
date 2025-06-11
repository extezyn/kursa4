import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'edit_note':
        return Icons.edit_note;
      case 'payments':
        return Icons.payments;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'category':
        return Icons.category;
      case 'savings':
        return Icons.savings;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'format_list_numbered':
        return Icons.format_list_numbered;
      case 'account_balance':
        return Icons.account_balance;
      case 'trending_down':
        return Icons.trending_down;
      case 'account_tree':
        return Icons.account_tree;
      case 'analytics':
        return Icons.analytics;
      case 'stars':
        return Icons.stars;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          final achievements = provider.achievements;
          
          if (achievements.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Нет доступных достижений',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Начните пользоваться приложением,\nчтобы открыть достижения',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    _getIconData(achievement.icon),
                    color: achievement.isUnlocked ? Colors.amber : Colors.grey,
                    size: 32,
                  ),
                  title: Text(
                    achievement.name,
                    style: TextStyle(
                      fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(achievement.description),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: achievement.progress / achievement.targetValue,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          achievement.isUnlocked ? Colors.green : Colors.blue,
                        ),
                      ),
                      Text(
                        '${achievement.progress}/${achievement.targetValue}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 