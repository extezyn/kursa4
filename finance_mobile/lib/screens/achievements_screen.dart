import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../utils/achievement_icons.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  IconData _getIconData(String iconPath) {
    switch (iconPath) {
      case 'assets/icons/achievements/first_steps.png':
        return AchievementIcons.firstSteps;
      case 'assets/icons/achievements/budget_master.png':
        return AchievementIcons.budgetMaster;
      case 'assets/icons/achievements/savings.png':
        return AchievementIcons.savings;
      case 'assets/icons/achievements/investor.png':
        return AchievementIcons.investor;
      case 'assets/icons/achievements/expert.png':
        return AchievementIcons.expert;
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
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Card(
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(achievement.name),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getIconData(achievement.icon),
                              size: 64,
                              color: achievement.isUnlocked ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              achievement.description,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: achievement.progress / achievement.targetValue,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement.isUnlocked ? Colors.green : Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(achievement.progress / achievement.targetValue * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: achievement.isUnlocked ? Colors.green : null,
                                fontWeight: achievement.isUnlocked ? FontWeight.bold : null,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Закрыть'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              _getIconData(achievement.icon),
                              size: 48,
                              color: achievement.isUnlocked ? Theme.of(context).primaryColor : Colors.grey,
                            ),
                            if (achievement.isUnlocked)
                              const Positioned(
                                right: -10,
                                top: -10,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: achievement.isUnlocked ? null : Colors.grey,
                            fontWeight: achievement.isUnlocked ? FontWeight.bold : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: achievement.progress / achievement.targetValue,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.isUnlocked ? Colors.green : Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
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