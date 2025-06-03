import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'savings':
        return Icons.savings;
      case 'category':
        return Icons.category;
      case 'money':
        return Icons.money;
      case 'calendar':
        return Icons.calendar_today;
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
              child: Text('Нет доступных достижений'),
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
                        '${achievement.progress.toInt()}/${achievement.targetValue.toInt()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: achievement.isUnlocked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.lock_outline, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 