import 'order_statuses.dart';

const estimatedOrderPrepMinutes = 10;

String orderStatusHint(String status) {
  switch (status) {
    case OrderStatuses.created:
      return 'Заказ принят, скоро начнём готовить';
    case OrderStatuses.inProgress:
      return 'Бариста готовит ваш заказ';
    case OrderStatuses.ready:
      return 'Заказ готов - можно забирать';
    default:
      return '';
  }
}

String? orderStatusNotificationMessage(int orderId, String status) {
  switch (status) {
    case OrderStatuses.inProgress:
      return 'Заказ #$orderId готовится';
    case OrderStatuses.ready:
      return 'Заказ #$orderId готов - можно забирать';
    case OrderStatuses.cancelled:
      return 'Заказ #$orderId отменён';
    case OrderStatuses.issued:
      return 'Заказ #$orderId выдан';
    default:
      return null;
  }
}
