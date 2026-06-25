import 'order_statuses.dart';

const estimatedOrderPrepMinutes = 10;

String orderStatusHint(String status) {
  switch (status) {
    case OrderStatuses.created:
      return 'Заказ принят, скоро начнём готовить';
    case OrderStatuses.inProgress:
      return 'Бариста готовит ваш заказ';
    case OrderStatuses.ready:
      return 'Заказ готов — можно забирать';
    default:
      return '';
  }
}
