abstract final class OrderStatuses {
  static const created = 'создан';
  static const inProgress = 'в работе';
  static const cancelled = 'отменён';
  static const ready = 'готов к выдаче';

  static String label(String status) => switch (status) {
        created => 'Новый',
        inProgress => 'Готовится',
        ready => 'Готов к выдаче',
        cancelled => 'Отменён',
        _ => status,
      };
}
