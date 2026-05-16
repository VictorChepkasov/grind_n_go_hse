-- Подключиться нужно к базе coffee_shop_db

-- 1. Пользователи
CREATE TABLE IF NOT EXISTS app_users (
    user_id        BIGSERIAL PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    phone_number   VARCHAR(20)  NOT NULL UNIQUE,
    password_hash  TEXT         NOT NULL,
    language       VARCHAR(10)  NOT NULL DEFAULT 'ru',
    role           VARCHAR(20)  NOT NULL CHECK (role IN ('client', 'barista'))
);

-- 2. Заказы
CREATE TABLE IF NOT EXISTS orders (
    order_id     BIGSERIAL PRIMARY KEY,
    user_id      BIGINT NOT NULL,
    status       VARCHAR(30) NOT NULL DEFAULT 'создан'
                 CHECK (status IN ('создан', 'в работе', 'отменён', 'готов к выдаче')),
    total_price  NUMERIC(10,2) NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id)
        REFERENCES app_users(user_id)
        ON DELETE RESTRICT
);

-- 3. Товары
CREATE TABLE IF NOT EXISTS products (
    product_id   BIGSERIAL PRIMARY KEY,
    name         VARCHAR(150) NOT NULL,
    description  TEXT,
    category     VARCHAR(50) NOT NULL,
    photo        BYTEA
);

-- 4. Размеры
CREATE TABLE IF NOT EXISTS sizes (
    size_id   BIGSERIAL PRIMARY KEY,
    name      VARCHAR(50) NOT NULL UNIQUE
);

-- 5. Связка товар + размер + цена
CREATE TABLE IF NOT EXISTS product_sizes (
    product_size_id  BIGSERIAL PRIMARY KEY,
    product_id       BIGINT NOT NULL,
    size_id          BIGINT NOT NULL,
    price            NUMERIC(10,2) NOT NULL CHECK (price >= 0),

    CONSTRAINT fk_product_sizes_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_product_sizes_size
        FOREIGN KEY (size_id)
        REFERENCES sizes(size_id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_product_size UNIQUE (product_id, size_id)
);

-- 6. Содержимое заказа
CREATE TABLE IF NOT EXISTS order_items (
    contain_id      BIGSERIAL PRIMARY KEY,
    order_id        BIGINT NOT NULL,
    product_size_id  BIGINT NOT NULL,
    quantity        INT NOT NULL CHECK (quantity > 0),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_order_items_product_size
        FOREIGN KEY (product_size_id)
        REFERENCES product_sizes(product_size_id)
        ON DELETE RESTRICT
);

-- Индексы для ускорения выборок
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_product_sizes_product_id ON product_sizes(product_id);
CREATE INDEX IF NOT EXISTS idx_product_sizes_size_id ON product_sizes(size_id);