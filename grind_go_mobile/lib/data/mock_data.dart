import '../models/product.dart';

const mockProducts = <Product>[
  Product(
    id: 1,
    name: 'Фильтр кофе',
    basePrice: 150,
    description:
        'Классический фильтр кофе с насыщенным вкусом и ароматом свежемолотых зёрен.',
  ),
  Product(
    id: 2,
    name: 'Капучино',
    basePrice: 180,
    description: 'Эспresso с нежной молочной пенкой.',
  ),
  Product(
    id: 3,
    name: 'Флэт Уайт',
    basePrice: 190,
    description: 'Двойной эспresso с бархатистым молоком.',
  ),
  Product(
    id: 4,
    name: 'Латте',
    basePrice: 200,
    description: 'Мягкий кофейный напиток с большим количеством молока.',
  ),
  Product(
    id: 5,
    name: 'Айс Латте',
    basePrice: 210,
    description: 'Освежающий холодный латте со льдом.',
  ),
  Product(
    id: 6,
    name: 'Американо',
    basePrice: 140,
    description: 'Эспresso, разбавленный горячей водой.',
  ),
];

Product? findProductById(int id) {
  for (final product in mockProducts) {
    if (product.id == id) return product;
  }
  return null;
}
