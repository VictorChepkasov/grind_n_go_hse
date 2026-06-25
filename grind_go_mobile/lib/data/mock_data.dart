import '../models/product.dart';
import '../models/product_size.dart';

const mockProducts = <Product>[
  Product(
    id: 1,
    name: 'Фильтр кофе',
    sizes: [
      ProductSize(name: 'S', price: 130),
      ProductSize(name: 'M', price: 150),
      ProductSize(name: 'L', price: 170),
    ],
    description:
        'Классический фильтр кофе с насыщенным вкусом и ароматом свежемолотых зёрен.',
  ),
  Product(
    id: 2,
    name: 'Капучино',
    sizes: [
      ProductSize(name: 'S', price: 150),
      ProductSize(name: 'M', price: 180),
      ProductSize(name: 'L', price: 210),
    ],
    description: 'Эспрессо с нежной молочной пенкой.',
  ),
  Product(
    id: 3,
    name: 'Флэт Уайт',
    sizes: [
      ProductSize(name: 'S', price: 160),
      ProductSize(name: 'M', price: 190),
      ProductSize(name: 'L', price: 220),
    ],
    description: 'Двойной эспрессо с бархатистым молоком.',
  ),
  Product(
    id: 4,
    name: 'Латте',
    sizes: [
      ProductSize(name: 'S', price: 160),
      ProductSize(name: 'M', price: 200),
      ProductSize(name: 'L', price: 230),
    ],
    description: 'Мягкий кофейный напиток с большим количеством молока.',
  ),
  Product(
    id: 5,
    name: 'Айс Латте',
    sizes: [
      ProductSize(name: 'S', price: 180),
      ProductSize(name: 'M', price: 210),
      ProductSize(name: 'L', price: 240),
    ],
    description: 'Освежающий холодный латте со льдом.',
  ),
  Product(
    id: 6,
    name: 'Американо',
    sizes: [
      ProductSize(name: 'S', price: 120),
      ProductSize(name: 'M', price: 140),
      ProductSize(name: 'L', price: 160),
    ],
    description: 'Эспрессо, разбавленный горячей водой.',
  ),
];

Product? findProductById(int id) {
  for (final product in mockProducts) {
    if (product.id == id) return product;
  }
  return null;
}
