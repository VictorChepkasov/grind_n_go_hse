class OrderStatuses {
  static const created = 'создан';
  static const inProgress = 'в работе';
  static const cancelled = 'отменён';
  static const ready = 'готов к выдаче';
  static const issued = 'выдан';

  static const clientActive = [created, inProgress, ready];
}
