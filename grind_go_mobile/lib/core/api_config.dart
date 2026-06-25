const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:5000',
);

String productPhotoUrl(int productId) =>
    '$apiBaseUrl/api/menu/products/$productId/photo';

String baristaProductPhotoUrl(int productId) =>
    '$apiBaseUrl/api/barista/products/$productId/photo';
