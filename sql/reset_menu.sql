-- Очистка меню (order_items ссылается на product_sizes)
TRUNCATE TABLE order_items, product_sizes, products, sizes RESTART IDENTITY CASCADE;
