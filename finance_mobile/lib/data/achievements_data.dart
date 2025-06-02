import '../models/achievement.dart';

final List<Achievement> initialAchievements = [
  Achievement(
    id: '1',
    name: 'Первые шаги',
    description: 'Добавьте свою первую транзакцию',
    icon: 'assets/icons/achievements/first_steps.png',
    targetValue: 1,
  ),
  Achievement(
    id: '2',
    name: 'Бюджетный мастер',
    description: 'Создайте 5 категорий расходов',
    icon: 'assets/icons/achievements/budget_master.png',
    targetValue: 5,
  ),
  Achievement(
    id: '3',
    name: 'Экономный месяц',
    description: 'Сэкономьте 20% от запланированного бюджета',
    icon: 'assets/icons/achievements/savings.png',
    targetValue: 20,
  ),
  Achievement(
    id: '4',
    name: 'Инвестор',
    description: 'Создайте накопительный счет',
    icon: 'assets/icons/achievements/investor.png',
    targetValue: 1,
  ),
  Achievement(
    id: '5',
    name: 'Финансовый эксперт',
    description: 'Используйте приложение 30 дней подряд',
    icon: 'assets/icons/achievements/expert.png',
    targetValue: 30,
  ),
]; 