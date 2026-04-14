-- ============================================================
-- 完整初始化脚本：清空并重新导入所有数据
-- 执行此文件前请确保数据库已存在
-- 执行后会清空所有数据重新导入
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ============================================================
-- 第一部分：关闭外键检查并删除所有表
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS complaints;
DROP TABLE IF EXISTS refunds;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS shops;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS admins;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 第二部分：创建所有表（按外键依赖顺序）
-- ============================================================

-- 用户表
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    gender CHAR(1) DEFAULT 'M',
    role VARCHAR(20) DEFAULT 'ROLE_USER',
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 地址表
CREATE TABLE addresses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    receiver_name VARCHAR(30) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    province VARCHAR(30) NOT NULL,
    city VARCHAR(30) NOT NULL,
    district VARCHAR(30) NOT NULL,
    detail_address VARCHAR(200) NOT NULL,
    is_default TINYINT(1) DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 商家表
CREATE TABLE merchants (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    shop_name VARCHAR(100) NOT NULL,
    shop_description TEXT,
    shop_image VARCHAR(500),
    category VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 店铺表
CREATE TABLE shops (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    folder VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(500),
    sort_order INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 商品表
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    original_price DECIMAL(10, 2),
    stock INT NOT NULL DEFAULT 0,
    image_url VARCHAR(512),
    description TEXT,
    status TINYINT DEFAULT 1,
    merchant_id BIGINT DEFAULT 0,
    brand VARCHAR(100),
    model VARCHAR(100),
    color VARCHAR(100),
    material VARCHAR(200),
    specifications TEXT,
    features TEXT,
    packaging_list TEXT,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 商品图片表
CREATE TABLE product_images (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    image_url VARCHAR(512) NOT NULL,
    sort_order INT DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_product_id (product_id),
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 购物车表
CREATE TABLE cart_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    selected_color VARCHAR(50),
    selected_storage VARCHAR(50),
    insurance_type VARCHAR(50) DEFAULT 'none',
    insurance_price DECIMAL(10,2) DEFAULT 0.00,
    unit_price DECIMAL(10,2),
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_product_options (user_id, product_id, selected_color, selected_storage, insurance_type),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 订单表
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_no VARCHAR(64) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    merchant_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    product_name VARCHAR(200),
    product_image VARCHAR(500),
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    receiver_name VARCHAR(50),
    receiver_phone VARCHAR(20),
    receiver_address VARCHAR(500),
    accepted_at DATETIME,
    delivered_at DATETIME,
    completed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 评价表
CREATE TABLE reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    rating INT NOT NULL DEFAULT 5,
    content TEXT,
    merchant_reply TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 投诉表
CREATE TABLE complaints (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    merchant_id BIGINT NOT NULL,
    order_id BIGINT,
    content TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    result TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 退款表
CREATE TABLE refunds (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    merchant_id BIGINT NOT NULL,
    reason TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    result TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 管理员表
CREATE TABLE admins (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 第三部分：基础数据（管理员账号）
-- ============================================================
INSERT INTO admins (username, password) VALUES ('lhh', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6');

-- ============================================================
-- 第四部分：商家数据
-- ============================================================
INSERT INTO merchants (username, password, shop_name, shop_description, shop_image, category, status, created_at, updated_at) VALUES
('shop1', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '华为手机专营店', '华为手机官方授权店，正品保障', NULL, 'phone', 'approved', NOW(), NOW()),
('shop2', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', 'iPhone专营店', '苹果iPhone官方授权经销商', NULL, 'phone', 'approved', NOW(), NOW()),
('shop3', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', 'iQOO手机专营店', 'iQOO手机官方旗舰店', NULL, 'phone', 'approved', NOW(), NOW()),
('shop4', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '一加手机专营店', '一加手机官方授权店', NULL, 'phone', 'approved', NOW(), NOW()),
('shop5', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', 'OPPO手机专营店', 'OPPO手机官方旗舰店', NULL, 'phone', 'approved', NOW(), NOW()),
('shop6', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', 'realme手机专营店', 'realme真我手机官方店', NULL, 'phone', 'approved', NOW(), NOW()),
('shop7', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '三星手机专营店', '三星手机官方授权经销商', NULL, 'phone', 'approved', NOW(), NOW()),
('shop8', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', 'vivo手机专营店', 'vivo手机官方旗舰店', NULL, 'phone', 'approved', NOW(), NOW()),
('shop9', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '小米手机专营店', '小米手机官方授权店', NULL, 'phone', 'approved', NOW(), NOW()),
('shop10', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '宏碁电脑专营店', '宏碁电脑官方授权店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop11', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '苹果电脑专营店', 'Apple Mac官方授权经销商', NULL, 'computer', 'approved', NOW(), NOW()),
('shop12', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '华硕电脑专营店', '华硕电脑官方旗舰店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop13', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '戴尔电脑专营店', '戴尔电脑官方授权店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop14', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '惠普电脑专营店', '惠普电脑官方旗舰店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop15', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '华为电脑专营店', '华为电脑官方授权店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop16', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '联想电脑专营店', '联想电脑官方旗舰店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop17', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '微软电脑专营店', '微软Surface官方授权店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop18', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '小米电脑专营店', '小米电脑官方授权店', NULL, 'computer', 'approved', NOW(), NOW()),
('shop19', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '空调专营店', '品牌空调，品质保障，专业安装', NULL, 'appliances', 'approved', NOW(), NOW()),
('shop20', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '洗地机专营店', '智能洗地机，清洁好帮手', NULL, 'appliances', 'approved', NOW(), NOW()),
('shop21', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '冰箱专营店', '品牌冰箱，保鲜生活', NULL, 'appliances', 'approved', NOW(), NOW()),
('shop22', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '电视专营店', '智能电视，视听盛宴', NULL, 'appliances', 'approved', NOW(), NOW()),
('shop23', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '洗衣机专营店', '品牌洗衣机，洁净生活', NULL, 'appliances', 'approved', NOW(), NOW()),
('shop24', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '箱包专营店', '奢侈品箱包，品质之选', NULL, 'cloth-shoes', 'approved', NOW(), NOW()),
('shop25', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '运动鞋专营店', 'Nike AJ正品鞋，潮流之选', NULL, 'cloth-shoes', 'approved', NOW(), NOW()),
('shop26', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '薯片专营店', '美味薯片，休闲零食', NULL, 'food', 'approved', NOW(), NOW()),
('shop27', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '辣条专营店', '经典辣条，童年味道', NULL, 'food', 'approved', NOW(), NOW()),
('shop28', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '游泳装备专营店', '专业游泳装备，畅游无忧', NULL, 'sports', 'approved', NOW(), NOW()),
('shop29', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '登山装备专营店', '专业登山装备，探索自然', NULL, 'sports', 'approved', NOW(), NOW()),
('shop30', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '骑行装备专营店', '骑行装备，绿色出行', NULL, 'sports', 'approved', NOW(), NOW()),
('shop31', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '美妆护肤专营店', '正品美妆，护肤专家', NULL, 'cosmetics', 'approved', NOW(), NOW()),
('shop32', '$2a$10$Kff8lRDm6XV3UcyTinDFjuig6Q6TbjefOPpT1dRJVPvxCfeAdP6b6', '图书音像专营店', '正版图书，知识海洋', NULL, 'book', 'approved', NOW(), NOW());

-- ============================================================
-- 第五部分：店铺数据
-- ============================================================
INSERT INTO shops (name, folder, description, sort_order) VALUES
('华为官方旗舰店', 'huawei', '华为官方授权店铺，正品保障', 1),
('Apple官方旗舰店', 'apple', 'Apple官方授权店铺，正品保障', 2),
('一加官方旗舰店', 'oneplus', '一加官方授权店铺，正品保障', 3),
('OPPO官方旗舰店', 'oppo', 'OPPO官方授权店铺，正品保障', 4),
('三星官方旗舰店', 'samsung', '三星官方授权店铺，正品保障', 5),
('vivo官方旗舰店', 'vivo', 'vivo官方授权店铺，正品保障', 6),
('小米官方旗舰店', 'xiaomi', '小米官方授权店铺，正品保障', 7),
('iQOO官方旗舰店', 'iqoo', 'iQOO官方授权店铺，正品保障', 8),
('realme官方旗舰店', 'realme', 'realme官方授权店铺，正品保障', 9),
('ASUS官方旗舰店', 'asus', '华硕官方授权店铺，正品保障', 10),
('Acer官方旗舰店', 'acer', '宏碁官方授权店铺，正品保障', 11),
('Dell官方旗舰店', 'dell', '戴尔官方授权店铺，正品保障', 12),
('HP官方旗舰店', 'hp', '惠普官方授权店铺，正品保障', 13),
('Lenovo官方旗舰店', 'lenovo', '联想官方授权店铺，正品保障', 14),
('Microsoft官方旗舰店', 'microsoft', '微软官方授权店铺，正品保障', 15),
('美的官方旗舰店', 'midea', '美的官方授权店铺，正品保障', 20),
('海尔官方旗舰店', 'haier', '海尔官方授权店铺，正品保障', 21),
('格力官方旗舰店', 'gree', '格力官方授权店铺，正品保障', 22),
('小米家电旗舰店', 'xiaomi-jd', '小米家电官方授权店铺，正品保障', 23),
('海信官方旗舰店', 'hisense', '海信官方授权店铺，正品保障', 24),
('TCL官方旗舰店', 'tcl', 'TCL官方授权店铺，正品保障', 25),
('耐克官方旗舰店', 'nike', '耐克官方授权店铺，正品保障', 30),
('AJ球鞋专卖店', 'aj', 'AJ球鞋官方店铺，限量发售', 31),
('奢侈品箱包旗舰店', 'luxury', '奢侈品箱包官方店铺，品质保证', 32),
('名牌包包专营店', 'bag', '名牌包包官方店铺，正品直营', 33),
('零食小铺旗舰店', 'lingshi1', '零食小铺官方店铺，美味零食', 40),
('美味零食旗舰店', 'lingshi2', '美味零食官方店铺，品质保证', 41),
('馋嘴猫零食店', 'lingshi3', '馋嘴猫零食官方店铺', 42),
('吃货天堂旗舰店', 'lingshi4', '吃货天堂官方店铺，精选零食', 43),
('京东图书旗舰店', 'jdbook', '京东图书官方店铺，正版图书', 50),
('淘宝图书旗舰店', 'taobaobook', '淘宝图书官方店铺，品质保证', 51),
('天猫图书旗舰店', 'tianmaobook', '天猫图书官方店铺，正版保障', 52),
('当当图书旗舰店', 'dangdangbook', '当当图书官方店铺，正版图书', 53),
('运动户外旗舰店', 'sports1', '专业运动户外装备，品质保障', 70),
('户外探险专卖店', 'sports2', '户外探险装备官方店铺', 71),
('游泳装备专营店', 'sports3', '游泳装备官方店铺', 72),
('骑行运动旗舰店', 'sports4', '骑行装备官方店铺', 73),
('美妆优选旗舰店', 'meizhuang1', '精选全球美妆好物，正品保障', 60),
('美丽小铺旗舰店', 'meizhuang2', '美丽小铺官方店铺，品质保证', 61),
('悦颜美妆旗舰店', 'meizhuang3', '悦颜美妆官方店铺，正品直营', 62),
('魅力工坊旗舰店', 'meizhuang4', '魅力工坊官方店铺，专业美妆', 63);

-- ============================================================
-- 第六部分：手机数码商品数据 (category = 'phone')
-- ============================================================

INSERT INTO products (name, category, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('华为 Mate 80', 'phone', 5999.00, 6499.00, 100, '/image/phone/huawei/Mate80/68692be190c474408.png_e1080.webp', '华为Mate 80，麒麟芯片，卫星通信', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('华为 Pura 80', 'phone', 6999.00, 7499.00, 80, '/image/phone/huawei/Pura80/67a46e928d1284071.jpg_e1080.webp', '华为Pura 80，影像旗舰，超感知影像系统', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('iPhone 14', 'phone', 4999.00, 5999.00, 50, '/image/phone/iphone/iphone14/111850_iphone-14_1.png', 'iPhone 14，A15芯片，超视网膜显示屏', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 14 Pro', 'phone', 6999.00, 7999.00, 30, '/image/phone/iphone/iphone14pro/111846_sp875-sp876-iphone14-pro-promax.png', 'iPhone 14 Pro，灵动岛，ProMotion显示屏', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 15', 'phone', 5999.00, 6999.00, 100, '/image/phone/iphone/iphone15/iphone_15_hero.png', 'iPhone 15，A16芯片，USB-C接口', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 15 Pro', 'phone', 7999.00, 8999.00, 60, '/image/phone/iphone/iphone15pro/iphone_15_pro.png', 'iPhone 15 Pro，钛金属设计，A17 Pro芯片', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 16', 'phone', 6999.00, 7999.00, 120, '/image/phone/iphone/iphone16/iphone-16-model-unselect-gallery-1-202409.webp', 'iPhone 16，A18芯片，相机控制按钮', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 16 Pro', 'phone', 8999.00, 9999.00, 80, '/image/phone/iphone/iphone16pro/iphone-16-pro-a.jpg', 'iPhone 16 Pro，A18 Pro芯片，4K 120fps视频', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 17', 'phone', 7999.00, 8999.00, 150, '/image/phone/iphone/iphone17/iPhone_17_Lavender_Singapore.webp', 'iPhone 17，全新设计，A19芯片', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPhone 17 Pro', 'phone', 9999.00, 10999.00, 100, '/image/phone/iphone/iphone17pro/iphone-17-pro-finish-select-202509-6-3inch-cosmicorange.webp', 'iPhone 17 Pro，A19 Pro芯片，专业影像系统', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('一加 15', 'phone', 4299.00, 4599.00, 60, '/image/phone/oneplus/15/35733938.jpg', '一加15，骁龙旗舰，哈苏影像', 1, (SELECT id FROM shops WHERE folder = 'oneplus' LIMIT 1)),
('一加 Ace Turbo 6', 'phone', 2999.00, 3299.00, 80, '/image/phone/oneplus/Turobo 6/44367411.jpg', '一加Ace Turbo 6，性能怪兽，超级快充', 1, (SELECT id FROM shops WHERE folder = 'oneplus' LIMIT 1)),
('OPPO A6c', 'phone', 1599.00, 1799.00, 200, '/image/phone/oppo/A6c/45032584_sn7.jpg', 'OPPO A6c，轻薄设计，超长续航', 1, (SELECT id FROM shops WHERE folder = 'oppo' LIMIT 1)),
('OPPO Find X9', 'phone', 5999.00, 6499.00, 50, '/image/phone/oppo/FindX9/68863d7607c3b3852.jpg_e1080.webp', 'OPPO Find X9，旗舰影像，哈苏联合调校', 1, (SELECT id FROM shops WHERE folder = 'oppo' LIMIT 1)),
('三星 Galaxy S26', 'phone', 5999.00, 6499.00, 70, '/image/phone/samsung/GalaxyS26/6906bcd9105b58800.jpg_e1080.webp', '三星Galaxy S26，AI手机，超清屏幕', 1, (SELECT id FROM shops WHERE folder = 'samsung' LIMIT 1)),
('三星 Galaxy S26 Ultra', 'phone', 8999.00, 9999.00, 40, '/image/phone/samsung/GalaryS26Ultra/68b19062ce4dd2355.jpg_e1080.webp', '三星Galaxy S26 Ultra，顶级旗舰，S Pen', 1, (SELECT id FROM shops WHERE folder = 'samsung' LIMIT 1)),
('vivo S20', 'phone', 2699.00, 2999.00, 100, '/image/phone/vivo/S20/23763212.jpg', 'vivo S20，柔光自拍，轻薄设计', 1, (SELECT id FROM shops WHERE folder = 'vivo' LIMIT 1)),
('vivo Y500', 'phone', 1999.00, 2199.00, 150, '/image/phone/vivo/Y500/OIP-C.webp', 'vivo Y500，大电池，超长续航', 1, (SELECT id FROM shops WHERE folder = 'vivo' LIMIT 1)),
('vivo X200', 'phone', 4999.00, 5499.00, 60, '/image/phone/vivo/x200/670d2dd3700624602.png_e1080.webp', 'vivo X200，蔡司影像，旗舰体验', 1, (SELECT id FROM shops WHERE folder = 'vivo' LIMIT 1)),
('小米 16', 'phone', 3999.00, 4299.00, 120, '/image/phone/xiaomi/16/v2-119259195df38fc720392bd8dd8dc725_1440w.jpg', '小米16，骁龙旗舰，徕卡影像', 1, (SELECT id FROM shops WHERE folder = 'xiaomi' LIMIT 1)),
('小米 17', 'phone', 4499.00, 4799.00, 100, '/image/phone/xiaomi/17/ceB9aUff1dxEE.jpg', '小米17，全新设计，澎湃OS', 1, (SELECT id FROM shops WHERE folder = 'xiaomi' LIMIT 1)),
('Redmi Turbo 5', 'phone', 1999.00, 2199.00, 200, '/image/phone/xiaomi/REDMIturbo5/1e30e924b899a9014c08e90b60cc1d7b02087bf45fce.webp', 'Redmi Turbo 5，性能小金刚，超值之选', 1, (SELECT id FROM shops WHERE folder = 'xiaomi' LIMIT 1)),
('iQOO 15', 'phone', 3999.00, 4299.00, 100, '/image/phone/IQOO/15/6928404611ec97447.png_e1080.webp', 'iQOO 15，电竞旗舰，超级性能', 1, (SELECT id FROM shops WHERE folder = 'iqoo' LIMIT 1)),
('realme GT 8 Pro', 'phone', 3499.00, 3799.00, 80, '/image/phone/realme/realmeGT8pro/605c60a68c511.jpg', 'realme GT 8 Pro，性能旗舰，游戏利器', 1, (SELECT id FROM shops WHERE folder = 'realme' LIMIT 1)),
('realme 16 Pro', 'phone', 2999.00, 3299.00, 100, '/image/phone/realme/realme16pro/b0ad1676be93efe8.png', 'realme 16 Pro，轻薄设计，强劲性能', 1, (SELECT id FROM shops WHERE folder = 'realme' LIMIT 1)),
('realme Neo 8', 'phone', 2499.00, 2799.00, 120, '/image/phone/realme/realmeNeo8/605c60a68c511.jpg', 'realme Neo 8，性价比之王，潮流设计', 1, (SELECT id FROM shops WHERE folder = 'realme' LIMIT 1));

-- ============================================================
-- 手机数码商品图片数据
-- ============================================================

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '华为 Mate 80' AND category = 'phone' LIMIT 1), '/image/phone/huawei/Mate80/68692be190c474408.png_e1080.webp', 1),
((SELECT id FROM products WHERE name = '华为 Mate 80' AND category = 'phone' LIMIT 1), '/image/phone/huawei/Mate80/68f6e37e11082615.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = '华为 Mate 80' AND category = 'phone' LIMIT 1), '/image/phone/huawei/Mate80/691ad5da45aa35639.jpg_e1080.webp', 3),
((SELECT id FROM products WHERE name = '华为 Pura 80' AND category = 'phone' LIMIT 1), '/image/phone/huawei/Pura80/67a46e928d1284071.jpg_e1080.webp', 1),
((SELECT id FROM products WHERE name = '华为 Pura 80' AND category = 'phone' LIMIT 1), '/image/phone/huawei/Pura80/6849030ee24f43776.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = '华为 Pura 80' AND category = 'phone' LIMIT 1), '/image/phone/huawei/Pura80/684fc3b977595111.jpg_e1080.webp', 3),
((SELECT id FROM products WHERE name = 'iPhone 14' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14/111850_iphone-14_1.png', 1),
((SELECT id FROM products WHERE name = 'iPhone 14' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14/OIP-C.webp', 2),
((SELECT id FROM products WHERE name = 'iPhone 14' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14/a6d2c64ce769b9c3.png', 3),
((SELECT id FROM products WHERE name = 'iPhone 14' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14/v2-9a738879ffc039791465bbd87c2d5f21_720w.jpg', 4),
((SELECT id FROM products WHERE name = 'iPhone 14 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14pro/111846_sp875-sp876-iphone14-pro-promax.png', 1),
((SELECT id FROM products WHERE name = 'iPhone 14 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14pro/648d7d7cef10c2834.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = 'iPhone 14 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone14pro/OIP-C.webp', 3),
((SELECT id FROM products WHERE name = 'iPhone 15' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone15/OIP-C.webp', 1),
((SELECT id FROM products WHERE name = 'iPhone 15' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone15/iphone_15_hero.png', 2),
((SELECT id FROM products WHERE name = 'iPhone 15 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone15pro/OIP-C.webp', 1),
((SELECT id FROM products WHERE name = 'iPhone 15 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone15pro/iphone_15_pro.png', 2),
((SELECT id FROM products WHERE name = 'iPhone 16' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone16/613Dze2vmCL._AC_SX679_.jpg', 1),
((SELECT id FROM products WHERE name = 'iPhone 16' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone16/iphone-16-model-unselect-gallery-1-202409.webp', 2),
((SELECT id FROM products WHERE name = 'iPhone 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone16pro/iphone-16-pro-a.jpg', 1),
((SELECT id FROM products WHERE name = 'iPhone 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone16pro/iphone-16-Pro-b.jpg', 2),
((SELECT id FROM products WHERE name = 'iPhone 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone16pro/iphone-16-Pro-c.jpg', 3),
((SELECT id FROM products WHERE name = 'iPhone 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone16pro/iphone-16-Pro-d.jpg', 4),
((SELECT id FROM products WHERE name = 'iPhone 17' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone17/iPhone_17_Lavender_Singapore.webp', 1),
((SELECT id FROM products WHERE name = 'iPhone 17' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone17/iPhone_17_Mist_Blue_Singapore.webp', 2),
((SELECT id FROM products WHERE name = 'iPhone 17' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone17/iPhone_17_Sage_Singapore.webp', 3),
((SELECT id FROM products WHERE name = 'iPhone 17 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone17pro/iphone-17-pro-finish-select-202509-6-3inch-cosmicorange.webp', 1),
((SELECT id FROM products WHERE name = 'iPhone 17 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone17pro/iphone-17-pro-finish-select-202509-6-3inch-cosmicorange_AV1.webp', 2),
((SELECT id FROM products WHERE name = 'iPhone 17 Pro' AND category = 'phone' LIMIT 1), '/image/phone/iphone/iphone17pro/iphone-17-pro-finish-select-202509-6-3inch-cosmicorange_AV3.webp', 3),
((SELECT id FROM products WHERE name = '一加 15' AND category = 'phone' LIMIT 1), '/image/phone/oneplus/15/35733938.jpg', 1),
((SELECT id FROM products WHERE name = '一加 15' AND category = 'phone' LIMIT 1), '/image/phone/oneplus/15/6862c2f7295aa2510.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = '一加 15' AND category = 'phone' LIMIT 1), '/image/phone/oneplus/15/68b796d5297023417.jpg_e1080.webp', 3),
((SELECT id FROM products WHERE name = '一加 Ace Turbo 6' AND category = 'phone' LIMIT 1), '/image/phone/oneplus/Turobo 6/44367411.jpg', 1),
((SELECT id FROM products WHERE name = '一加 Ace Turbo 6' AND category = 'phone' LIMIT 1), '/image/phone/oneplus/Turobo 6/OIP-C.webp', 2),
((SELECT id FROM products WHERE name = 'OPPO A6c' AND category = 'phone' LIMIT 1), '/image/phone/oppo/A6c/45032584_sn7.jpg', 1),
((SELECT id FROM products WHERE name = 'OPPO A6c' AND category = 'phone' LIMIT 1), '/image/phone/oppo/A6c/ceXsqIP7wXsA.jpg', 2),
((SELECT id FROM products WHERE name = 'OPPO A6c' AND category = 'phone' LIMIT 1), '/image/phone/oppo/A6c/f8abbcdae910f78ad330009c91eaeeb1-1803551226.jpg', 3),
((SELECT id FROM products WHERE name = 'OPPO Find X9' AND category = 'phone' LIMIT 1), '/image/phone/oppo/FindX9/68863d7607c3b3852.jpg_e1080.webp', 1),
((SELECT id FROM products WHERE name = 'OPPO Find X9' AND category = 'phone' LIMIT 1), '/image/phone/oppo/FindX9/68d279269a65b3881.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = 'OPPO Find X9' AND category = 'phone' LIMIT 1), '/image/phone/oppo/FindX9/68d2792836d676036.jpg_e1080.webp', 3),
((SELECT id FROM products WHERE name = 'OPPO Find X9' AND category = 'phone' LIMIT 1), '/image/phone/oppo/FindX9/68e7864eb9d7b3430.jpg_e1080.webp', 4),
((SELECT id FROM products WHERE name = '三星 Galaxy S26' AND category = 'phone' LIMIT 1), '/image/phone/samsung/GalaxyS26/6906bcd9105b58800.jpg_e1080.webp', 1),
((SELECT id FROM products WHERE name = '三星 Galaxy S26' AND category = 'phone' LIMIT 1), '/image/phone/samsung/GalaxyS26/R-C.jpg', 2),
((SELECT id FROM products WHERE name = '三星 Galaxy S26 Ultra' AND category = 'phone' LIMIT 1), '/image/phone/samsung/GalaryS26Ultra/68b19062ce4dd2355.jpg_e1080.webp', 1),
((SELECT id FROM products WHERE name = '三星 Galaxy S26 Ultra' AND category = 'phone' LIMIT 1), '/image/phone/samsung/GalaryS26Ultra/68cfd3e4ee0f92143.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = 'vivo S20' AND category = 'phone' LIMIT 1), '/image/phone/vivo/S20/23763212.jpg', 1),
((SELECT id FROM products WHERE name = 'vivo S20' AND category = 'phone' LIMIT 1), '/image/phone/vivo/S20/674ed0996ad473182.jpg_e1080.webp', 2),
((SELECT id FROM products WHERE name = 'vivo S20' AND category = 'phone' LIMIT 1), '/image/phone/vivo/S20/e0d6ca27037da05bdc18adc95d08e344.jpeg', 3),
((SELECT id FROM products WHERE name = 'vivo Y500' AND category = 'phone' LIMIT 1), '/image/phone/vivo/Y500/OIP-C.webp', 1),
((SELECT id FROM products WHERE name = 'vivo Y500' AND category = 'phone' LIMIT 1), '/image/phone/vivo/Y500/ceRgAeQ7f07ys.jpg', 2),
((SELECT id FROM products WHERE name = 'vivo X200' AND category = 'phone' LIMIT 1), '/image/phone/vivo/x200/670d2dd3700624602.png_e1080.webp', 1),
((SELECT id FROM products WHERE name = 'vivo X200' AND category = 'phone' LIMIT 1), '/image/phone/vivo/x200/ChMkK2cNLEKIP7xVAAGJUMh15HYAAkVtQIuubYAAYlo990.jpg', 2),
((SELECT id FROM products WHERE name = 'vivo X200' AND category = 'phone' LIMIT 1), '/image/phone/vivo/x200/f796f5ee887ebc390dba91e9644f4ae7.png!a', 3),
((SELECT id FROM products WHERE name = '小米 16' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/16/v2-119259195df38fc720392bd8dd8dc725_1440w.jpg', 1),
((SELECT id FROM products WHERE name = '小米 16' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/16/v2-455e50d29d390edc99c1695eb5cd8edb_1440w.webp', 2),
((SELECT id FROM products WHERE name = '小米 17' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/17/ceB9aUff1dxEE.jpg', 1),
((SELECT id FROM products WHERE name = '小米 17' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/17/ceNaZ75WyDJc.jpg', 2),
((SELECT id FROM products WHERE name = '小米 17' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/17/cefbKkPnqtwT.jpg', 3),
((SELECT id FROM products WHERE name = 'Redmi Turbo 5' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/REDMIturbo5/1e30e924b899a9014c08e90b60cc1d7b02087bf45fce.webp', 1),
((SELECT id FROM products WHERE name = 'Redmi Turbo 5' AND category = 'phone' LIMIT 1), '/image/phone/xiaomi/REDMIturbo5/c2fdfc039245d688d43fb04cda9b6a1ed21b0ff48e98.webp', 2),
((SELECT id FROM products WHERE name = 'iQOO 15' AND category = 'phone' LIMIT 1), '/image/phone/IQOO/15/6928404611ec97447.png_e1080.webp', 1),
((SELECT id FROM products WHERE name = 'iQOO 15' AND category = 'phone' LIMIT 1), '/image/phone/IQOO/15/47c4fbd0ceb5859b0e1a23285027c105.jpeg', 2),
((SELECT id FROM products WHERE name = 'iQOO 15' AND category = 'phone' LIMIT 1), '/image/phone/IQOO/15/68f9bd0262de97021.jpg_e1080.webp', 3),
((SELECT id FROM products WHERE name = 'realme GT 8 Pro' AND category = 'phone' LIMIT 1), '/image/phone/realme/realmeGT8pro/605c60a68c511.jpg', 1),
((SELECT id FROM products WHERE name = 'realme GT 8 Pro' AND category = 'phone' LIMIT 1), '/image/phone/realme/realmeGT8pro/OIP-C.webp', 2),
((SELECT id FROM products WHERE name = 'realme 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/realme/realme16pro/b0ad1676be93efe8.png', 1),
((SELECT id FROM products WHERE name = 'realme 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/realme/realme16pro/4298abfd4f435c1f.png', 2),
((SELECT id FROM products WHERE name = 'realme 16 Pro' AND category = 'phone' LIMIT 1), '/image/phone/realme/realme16pro/4eb5d7f2f64c4319.png', 3),
((SELECT id FROM products WHERE name = 'realme Neo 8' AND category = 'phone' LIMIT 1), '/image/phone/realme/realmeNeo8/605c60a68c511.jpg', 1),
((SELECT id FROM products WHERE name = 'realme Neo 8' AND category = 'phone' LIMIT 1), '/image/phone/realme/realmeNeo8/605c609ed476d.jpg', 2),
((SELECT id FROM products WHERE name = 'realme Neo 8' AND category = 'phone' LIMIT 1), '/image/phone/realme/realmeNeo8/OIP-C.webp', 3);

-- ============================================================
-- 第七部分：电脑办公商品数据 (category = 'computer')
-- ============================================================

INSERT INTO products (name, category, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('MacBook Air 13', 'computer', 8999.00, 9999.00, 100, '/image/computer/Apple/MacBook Air 13/MacBook_Air_13_in_M3_Midnight_PDP_Image_Position_1__GBEN_e200e9d6-f6bf-4856-9cec-a60e76860ec7_500x.webp', 'MacBook Air 13，M3芯片，轻薄便携', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('MacBook Air 15', 'computer', 12999.00, 13999.00, 80, '/image/computer/Apple/MacBook Air 15/Apple-WWDC23-MacBook-Air-15-in-hero-230605_big.jpg.large.jpg', 'MacBook Air 15，M3芯片，大屏体验', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('MacBook Pro 14', 'computer', 16999.00, 18999.00, 60, '/image/computer/Apple/MacBook Pro 14/hero_endframe__e4ls9pihykya_xlarge.jpg', 'MacBook Pro 14，M3 Pro芯片，专业性能', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('MacBook Pro 16', 'computer', 24999.00, 26999.00, 40, '/image/computer/Apple/MacBook Pro 16/apple-macbook-pro-16-inch-2023-m3-max_cah1.jpg', 'MacBook Pro 16，M3 Max芯片，极致性能', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('Mac mini', 'computer', 4499.00, 4999.00, 120, '/image/computer/Apple/Mac mini/mac-mini__dvce2jrm11w2_og.jpg', 'Mac mini，M2芯片，小巧强劲', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPad Air', 'computer', 4799.00, 5299.00, 150, '/image/computer/Apple/iPad Air/iPadAirFront.webp', 'iPad Air，M2芯片，轻薄平板', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPad Pro', 'computer', 8999.00, 9999.00, 80, '/image/computer/Apple/iPad Pro/ipad-pro-finish-unselect-gallery-2-202405_FMT_WHH.jpg', 'iPad Pro，M4芯片，专业平板', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('iPad mini', 'computer', 3999.00, 4499.00, 100, '/image/computer/Apple/iPad mini/ipad_mini_starlight_pdp_image_position_1_wifi__sg-en.jpg', 'iPad mini，A17 Pro芯片，小巧便携', 1, (SELECT id FROM shops WHERE folder = 'apple' LIMIT 1)),
('MateBook 14s', 'computer', 6999.00, 7999.00, 80, '/image/computer/HuaWei/MateBook 14s/1080-x-1080.jpg', '华为MateBook 14s，轻薄商务本', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('MateBook D14', 'computer', 4999.00, 5499.00, 120, '/image/computer/HuaWei/MateBook D14/huawei-matebook-d-14-2023-key-vision.jpg', '华为MateBook D14，性价比办公本', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('MateBook GT 14', 'computer', 7999.00, 8999.00, 60, '/image/computer/HuaWei/MateBook GT 14/huawei-matebook-gt-14-kv-01.png', '华为MateBook GT 14，性能轻薄本', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('MateBook X Pro', 'computer', 11999.00, 13999.00, 40, '/image/computer/HuaWei/MateBook X Pro/huawei-matebook-x-pro-2021-kv02.png', '华为MateBook X Pro，旗舰轻薄本', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('MateStation S', 'computer', 3999.00, 4499.00, 100, '/image/computer/HuaWei/MateStation S/huawei-matestation-s-my-02.webp', '华为MateStation S，迷你主机', 1, (SELECT id FROM shops WHERE folder = 'huawei' LIMIT 1)),
('ProArt Studiobook', 'computer', 15999.00, 17999.00, 30, '/image/computer/ASUS/ProArt Studiobook/71qwuhKUGUL._AC_UF894,1000_QL80_.jpg', '华硕ProArt Studiobook，创作者专业笔记本', 1, (SELECT id FROM shops WHERE folder = 'asus' LIMIT 1)),
('Predator Helios 16', 'computer', 12999.00, 14999.00, 40, '/image/computer/Acer/Predator/71sS7G5ZpQL.jpg', '宏碁Predator Helios 16，电竞游戏本', 1, (SELECT id FROM shops WHERE folder = 'acer' LIMIT 1)),
('Alienware m16', 'computer', 18999.00, 20999.00, 30, '/image/computer/Dell/Alienware m16/laptop-alienware-m16-intel-pdp-hero.avif', '戴尔Alienware m16，旗舰游戏本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('Alienware x14', 'computer', 13999.00, 15999.00, 40, '/image/computer/Dell/Alienware x14/01_main_entry_img.jpg', '戴尔Alienware x14，轻薄游戏本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('Dell G15', 'computer', 7999.00, 8999.00, 80, '/image/computer/Dell/Dell G15/laptop-g-15-5530-pdp-hero-sl.avif', '戴尔G15，性价比游戏本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('Inspiron 16 Plus', 'computer', 6999.00, 7999.00, 100, '/image/computer/Dell/Inspiron 16 Plus/laptop-inspiron-16-7630-plus-intel-pdp-hero.jpg', '戴尔Inspiron 16 Plus，大屏办公本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('Latitude 5440', 'computer', 5999.00, 6999.00, 120, '/image/computer/Dell/Latitude 5440/ccw-thinos-latitude-5440-pdp-module-06a.webp', '戴尔Latitude 5440，商务办公本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('Latitude 7440', 'computer', 8999.00, 9999.00, 60, '/image/computer/Dell/Latitude 7440/notebook-latitude-14-7440-t-gray-gallery-1.avif', '戴尔Latitude 7440，高端商务本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('XPS 13', 'computer', 9999.00, 11999.00, 50, '/image/computer/Dell/XPS 13/Dell-XPS-13-9340-laptop.jpg', '戴尔XPS 13，超轻薄旗舰本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('XPS 14', 'computer', 12999.00, 14999.00, 40, '/image/computer/Dell/XPS 14/laptop-da14260t-gray-copilot-gallery-1.avif', '戴尔XPS 14，大屏轻薄本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('XPS 16', 'computer', 16999.00, 18999.00, 30, '/image/computer/Dell/XPS 16/laptop-dell-da16250t-gy-gallery-2.avif', '戴尔XPS 16，旗舰创作本', 1, (SELECT id FROM shops WHERE folder = 'dell' LIMIT 1)),
('EliteBook 1040', 'computer', 11999.00, 13999.00, 50, '/image/computer/HP/EliteBook 1040/hp-inc-elitebook-x360-1040-g11-u7-155h32gb1tb-ssd-a77nzpt-626301_2048x.webp', '惠普EliteBook 1040，高端商务本', 1, (SELECT id FROM shops WHERE folder = 'hp' LIMIT 1)),
('EliteBook 840', 'computer', 7999.00, 8999.00, 80, '/image/computer/HP/EliteBook 840/71rV0dQlcML.jpg', '惠普EliteBook 840，商务办公本', 1, (SELECT id FROM shops WHERE folder = 'hp' LIMIT 1)),
('Omen 16', 'computer', 8999.00, 9999.00, 60, '/image/computer/HP/Omen/01_1e9616e3-6b35-439e-abed-c9ff1b7522e8.webp', '惠普Omen 16，电竞游戏本', 1, (SELECT id FROM shops WHERE folder = 'hp' LIMIT 1)),
('Pavilion', 'computer', 5499.00, 6499.00, 100, '/image/computer/HP/Pavilion/HP Pavilion Aero 13 Laptop PC hero image of all four colors.avif', '惠普Pavilion，家用娱乐本', 1, (SELECT id FROM shops WHERE folder = 'hp' LIMIT 1)),
('Spectre', 'computer', 10999.00, 12999.00, 40, '/image/computer/HP/Spectre/2_82a9c4da-1691-4ee2-b25d-3bd01849423f.webp', '惠普Spectre，高端轻薄本', 1, (SELECT id FROM shops WHERE folder = 'hp' LIMIT 1)),
('Legion R9000P', 'computer', 9999.00, 11999.00, 50, '/image/computer/Lenovo/R9000P/2024-Lenovo-Legion-R9000P.jpg', '联想拯救者R9000P，电竞游戏本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('ThinkBook 14', 'computer', 5499.00, 6499.00, 100, '/image/computer/Lenovo/ThinkBook 14/tnvBvImFaCAXm2uXbKSGJgjHo-7273.jpg', '联想ThinkBook 14，商务办公本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('Legion Y7000P', 'computer', 8499.00, 9499.00, 60, '/image/computer/Lenovo/Y7000P/Vj9LVCUDwo49jK8zRrGmBTVOx-9113.jpg', '联想拯救者Y7000P，主流游戏本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('Legion Y9000K', 'computer', 15999.00, 17999.00, 30, '/image/computer/Lenovo/Y9000K/mlFKsT7YFkS6NbttZydlbwGYO-2775.jpg', '联想拯救者Y9000K，旗舰游戏本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('Legion Y9000P', 'computer', 11999.00, 13999.00, 40, '/image/computer/Lenovo/Y9000P/KhHpj8GmPGG0gaITrUIgBQ0V0-9756.jpg', '联想拯救者Y9000P，高端游戏本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('Yoga Book 9i', 'computer', 13999.00, 15999.00, 30, '/image/computer/Lenovo/Yoga Book 9i/AEUBjKmgsbdWEdrEuw7MPAGkn-0287.jpg', '联想Yoga Book 9i，双屏创意本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('小新 16', 'computer', 4999.00, 5499.00, 120, '/image/computer/Lenovo/xiaoxin 16/7dMQ0ggdDI38BOloe5AwPkLbP-5415.jpg', '联想小新16，大屏轻薄本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('小新 Air14', 'computer', 4499.00, 4999.00, 150, '/image/computer/Lenovo/xiaoxin Air14/FgsrmD823OV9g9P9sp7KD8YzP-8162.jpg', '联想小新Air14，轻薄便携本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('小新 Pro14', 'computer', 5999.00, 6499.00, 100, '/image/computer/Lenovo/xiaoxin Pro14/657ibacNaDGDHwxmQVP1qJ3Al-9880.jpg', '联想小新Pro14，高性能轻薄本', 1, (SELECT id FROM shops WHERE folder = 'lenovo' LIMIT 1)),
('Surface Go 3', 'computer', 3999.00, 4499.00, 80, '/image/computer/Microsoft/Surface Go 3/Highlight-Surface-Go-3-Laptop-Touch-3000x1682.avif', '微软Surface Go 3，便携二合一', 1, (SELECT id FROM shops WHERE folder = 'microsoft' LIMIT 1)),
('Surface Laptop 5/6', 'computer', 8999.00, 9999.00, 50, '/image/computer/Microsoft/Surface Laptop 56/SPZ1B-Platinum-13-BB-00.avif', '微软Surface Laptop，轻薄笔记本', 1, (SELECT id FROM shops WHERE folder = 'microsoft' LIMIT 1)),
('Surface Laptop SE', 'computer', 2999.00, 3499.00, 100, '/image/computer/Microsoft/Surface Laptop SE/microsoft-surface-laptop-se.webp', '微软Surface Laptop SE，教育笔记本', 1, (SELECT id FROM shops WHERE folder = 'microsoft' LIMIT 1)),
('Surface Pro 9/10', 'computer', 7999.00, 8999.00, 60, '/image/computer/Microsoft/Surface Pro 910/SPZ2B-Platinum-BB-00.avif', '微软Surface Pro，专业二合一', 1, (SELECT id FROM shops WHERE folder = 'microsoft' LIMIT 1));

-- ============================================================
-- 电脑办公商品图片数据
-- ============================================================

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'MacBook Air 13' AND category = 'computer' LIMIT 1), '/image/computer/Apple/MacBook Air 13/MacBook_Air_13_in_M3_Midnight_PDP_Image_Position_1__GBEN_e200e9d6-f6bf-4856-9cec-a60e76860ec7_500x.webp', 1),
((SELECT id FROM products WHERE name = 'MacBook Air 13' AND category = 'computer' LIMIT 1), '/image/computer/Apple/MacBook Air 13/MacBook_Air_13_in_M3_Midnight_PDP_Image_Position_2__GBEN_e200e9d6-f6bf-4856-9cec-a60e76860ec7_500x.webp', 2),
((SELECT id FROM products WHERE name = 'MacBook Air 15' AND category = 'computer' LIMIT 1), '/image/computer/Apple/MacBook Air 15/Apple-WWDC23-MacBook-Air-15-in-hero-230605_big.jpg.large.jpg', 1),
((SELECT id FROM products WHERE name = 'MacBook Pro 14' AND category = 'computer' LIMIT 1), '/image/computer/Apple/MacBook Pro 14/hero_endframe__e4ls9pihykya_xlarge.jpg', 1),
((SELECT id FROM products WHERE name = 'MacBook Pro 16' AND category = 'computer' LIMIT 1), '/image/computer/Apple/MacBook Pro 16/apple-macbook-pro-16-inch-2023-m3-max_cah1.jpg', 1),
((SELECT id FROM products WHERE name = 'Mac mini' AND category = 'computer' LIMIT 1), '/image/computer/Apple/Mac mini/mac-mini__dvce2jrm11w2_og.jpg', 1),
((SELECT id FROM products WHERE name = 'iPad Air' AND category = 'computer' LIMIT 1), '/image/computer/Apple/iPad Air/iPadAirFront.webp', 1),
((SELECT id FROM products WHERE name = 'iPad Pro' AND category = 'computer' LIMIT 1), '/image/computer/Apple/iPad Pro/ipad-pro-finish-unselect-gallery-2-202405_FMT_WHH.jpg', 1),
((SELECT id FROM products WHERE name = 'iPad mini' AND category = 'computer' LIMIT 1), '/image/computer/Apple/iPad mini/ipad_mini_starlight_pdp_image_position_1_wifi__sg-en.jpg', 1),
((SELECT id FROM products WHERE name = 'MateBook 14s' AND category = 'computer' LIMIT 1), '/image/computer/HuaWei/MateBook 14s/1080-x-1080.jpg', 1),
((SELECT id FROM products WHERE name = 'MateBook D14' AND category = 'computer' LIMIT 1), '/image/computer/HuaWei/MateBook D14/huawei-matebook-d-14-2023-key-vision.jpg', 1),
((SELECT id FROM products WHERE name = 'MateBook GT 14' AND category = 'computer' LIMIT 1), '/image/computer/HuaWei/MateBook GT 14/huawei-matebook-gt-14-kv-01.png', 1),
((SELECT id FROM products WHERE name = 'MateBook X Pro' AND category = 'computer' LIMIT 1), '/image/computer/HuaWei/MateBook X Pro/huawei-matebook-x-pro-2021-kv02.png', 1),
((SELECT id FROM products WHERE name = 'MateStation S' AND category = 'computer' LIMIT 1), '/image/computer/HuaWei/MateStation S/huawei-matestation-s-my-02.webp', 1),
((SELECT id FROM products WHERE name = 'ProArt Studiobook' AND category = 'computer' LIMIT 1), '/image/computer/ASUS/ProArt Studiobook/71qwuhKUGUL._AC_UF894,1000_QL80_.jpg', 1),
((SELECT id FROM products WHERE name = 'Predator Helios 16' AND category = 'computer' LIMIT 1), '/image/computer/Acer/Predator/71sS7G5ZpQL.jpg', 1),
((SELECT id FROM products WHERE name = 'Alienware m16' AND category = 'computer' LIMIT 1), '/image/computer/Dell/Alienware m16/laptop-alienware-m16-intel-pdp-hero.avif', 1),
((SELECT id FROM products WHERE name = 'Alienware x14' AND category = 'computer' LIMIT 1), '/image/computer/Dell/Alienware x14/01_main_entry_img.jpg', 1),
((SELECT id FROM products WHERE name = 'Dell G15' AND category = 'computer' LIMIT 1), '/image/computer/Dell/Dell G15/laptop-g-15-5530-pdp-hero-sl.avif', 1),
((SELECT id FROM products WHERE name = 'Inspiron 16 Plus' AND category = 'computer' LIMIT 1), '/image/computer/Dell/Inspiron 16 Plus/laptop-inspiron-16-7630-plus-intel-pdp-hero.jpg', 1),
((SELECT id FROM products WHERE name = 'Latitude 5440' AND category = 'computer' LIMIT 1), '/image/computer/Dell/Latitude 5440/ccw-thinos-latitude-5440-pdp-module-06a.webp', 1),
((SELECT id FROM products WHERE name = 'Latitude 7440' AND category = 'computer' LIMIT 1), '/image/computer/Dell/Latitude 7440/notebook-latitude-14-7440-t-gray-gallery-1.avif', 1),
((SELECT id FROM products WHERE name = 'XPS 13' AND category = 'computer' LIMIT 1), '/image/computer/Dell/XPS 13/Dell-XPS-13-9340-laptop.jpg', 1),
((SELECT id FROM products WHERE name = 'XPS 14' AND category = 'computer' LIMIT 1), '/image/computer/Dell/XPS 14/laptop-da14260t-gray-copilot-gallery-1.avif', 1),
((SELECT id FROM products WHERE name = 'XPS 16' AND category = 'computer' LIMIT 1), '/image/computer/Dell/XPS 16/laptop-dell-da16250t-gy-gallery-2.avif', 1),
((SELECT id FROM products WHERE name = 'EliteBook 1040' AND category = 'computer' LIMIT 1), '/image/computer/HP/EliteBook 1040/hp-inc-elitebook-x360-1040-g11-u7-155h32gb1tb-ssd-a77nzpt-626301_2048x.webp', 1),
((SELECT id FROM products WHERE name = 'EliteBook 840' AND category = 'computer' LIMIT 1), '/image/computer/HP/EliteBook 840/71rV0dQlcML.jpg', 1),
((SELECT id FROM products WHERE name = 'Omen 16' AND category = 'computer' LIMIT 1), '/image/computer/HP/Omen/01_1e9616e3-6b35-439e-abed-c9ff1b7522e8.webp', 1),
((SELECT id FROM products WHERE name = 'Pavilion' AND category = 'computer' LIMIT 1), '/image/computer/HP/Pavilion/HP Pavilion Aero 13 Laptop PC hero image of all four colors.avif', 1),
((SELECT id FROM products WHERE name = 'Spectre' AND category = 'computer' LIMIT 1), '/image/computer/HP/Spectre/2_82a9c4da-1691-4ee2-b25d-3bd01849423f.webp', 1),
((SELECT id FROM products WHERE name = 'Legion R9000P' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/R9000P/2024-Lenovo-Legion-R9000P.jpg', 1),
((SELECT id FROM products WHERE name = 'ThinkBook 14' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/ThinkBook 14/tnvBvImFaCAXm2uXbKSGJgjHo-7273.jpg', 1),
((SELECT id FROM products WHERE name = 'Legion Y7000P' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/Y7000P/Vj9LVCUDwo49jK8zRrGmBTVOx-9113.jpg', 1),
((SELECT id FROM products WHERE name = 'Legion Y9000K' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/Y9000K/mlFKsT7YFkS6NbttZydlbwGYO-2775.jpg', 1),
((SELECT id FROM products WHERE name = 'Legion Y9000P' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/Y9000P/KhHpj8GmPGG0gaITrUIgBQ0V0-9756.jpg', 1),
((SELECT id FROM products WHERE name = 'Yoga Book 9i' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/Yoga Book 9i/AEUBjKmgsbdWEdrEuw7MPAGkn-0287.jpg', 1),
((SELECT id FROM products WHERE name = '小新 16' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/xiaoxin 16/7dMQ0ggdDI38BOloe5AwPkLbP-5415.jpg', 1),
((SELECT id FROM products WHERE name = '小新 Air14' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/xiaoxin Air14/FgsrmD823OV9g9P9sp7KD8YzP-8162.jpg', 1),
((SELECT id FROM products WHERE name = '小新 Pro14' AND category = 'computer' LIMIT 1), '/image/computer/Lenovo/xiaoxin Pro14/657ibacNaDGDHwxmQVP1qJ3Al-9880.jpg', 1),
((SELECT id FROM products WHERE name = 'Surface Go 3' AND category = 'computer' LIMIT 1), '/image/computer/Microsoft/Surface Go 3/Highlight-Surface-Go-3-Laptop-Touch-3000x1682.avif', 1),
((SELECT id FROM products WHERE name = 'Surface Laptop 5/6' AND category = 'computer' LIMIT 1), '/image/computer/Microsoft/Surface Laptop 56/SPZ1B-Platinum-13-BB-00.avif', 1),
((SELECT id FROM products WHERE name = 'Surface Laptop SE' AND category = 'computer' LIMIT 1), '/image/computer/Microsoft/Surface Laptop SE/microsoft-surface-laptop-se.webp', 1),
((SELECT id FROM products WHERE name = 'Surface Pro 9/10' AND category = 'computer' LIMIT 1), '/image/computer/Microsoft/Surface Pro 910/SPZ2B-Platinum-BB-00.avif', 1);

-- ============================================================
-- 第八部分：家电商品数据 (category = 'appliance')
-- ============================================================

INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('格力 云锦Ⅱ 1.5匹变频空调', 'appliance', '格力', 'KFR-35GW/NhAd1BAj', '白色', '{"制冷量":"3500W","制热量":"4600W","能效等级":"一级能效","噪音":"18-41dB","适用面积":"15-23㎡","电源":"220V/50Hz"}', '["新一级能效，省电节能","56℃净菌自洁，健康出风","7档风速，舒适随心","WiFi智能控制，远程操控","独立除湿，干爽舒适"]', '["空调主机 x1","遥控器 x1","电池 x2","说明书 x1","保修卡 x1","安装配件 x1套"]', 3299.00, 3699.00, 150, '/image/appliances/aircondition/10001.webp', '格力云锦Ⅱ系列，新一级能效变频空调，56℃净菌自洁，WiFi智能控制', 1, (SELECT id FROM shops WHERE folder = 'gree' LIMIT 1)),
('格力 云佳 1.5匹变频空调', 'appliance', '格力', 'KFR-35GW/NhGc1B', '白色', '{"制冷量":"3500W","制热量":"4600W","能效等级":"一级能效","噪音":"18-41dB","适用面积":"15-23㎡","电源":"220V/50Hz"}', '["新一级能效，省电节能","自清洁功能，健康出风","7档风速，舒适随心","独立除湿，干爽舒适","简约设计，百搭家居"]', '["空调主机 x1","遥控器 x1","电池 x2","说明书 x1","保修卡 x1","安装配件 x1套"]', 2999.00, 3399.00, 200, '/image/appliances/aircondition/10002.webp', '格力云佳系列，新一级能效变频空调，自清洁功能', 1, (SELECT id FROM shops WHERE folder = 'gree' LIMIT 1)),
('格力 京爽 1.5匹变频空调', 'appliance', '格力', 'KFR-35GW/NhKe1BAj', '白色', '{"制冷量":"3500W","制热量":"4600W","能效等级":"一级能效","噪音":"18-41dB","适用面积":"15-23㎡","电源":"220V/50Hz"}', '["新一级能效，省电节能","56℃净菌自洁，健康出风","7档风速，舒适随心","WiFi智能控制，远程操控","独立除湿，干爽舒适"]', '["空调主机 x1","遥控器 x1","电池 x2","说明书 x1","保修卡 x1","安装配件 x1套"]', 3499.00, 3899.00, 120, '/image/appliances/aircondition/10003.webp', '格力京爽系列，新一级能效变频空调，WiFi智能控制', 1, (SELECT id FROM shops WHERE folder = 'gree' LIMIT 1)),
('海尔 BCD-470WDPG 对开门冰箱', 'appliance', '海尔', 'BCD-470WDPG', '银色', '{"总容积":"470L","冷藏室容积":"310L","冷冻室容积":"160L","能效等级":"一级能效","制冷方式":"风冷无霜","噪音":"38dB"}', '["470L大容量，满足全家需求","风冷无霜，告别除霜烦恼","智能变频，节能省电","干湿分储，食材保鲜","独立双循环，不串味"]', '["冰箱主机 x1","说明书 x1","保修卡 x1","搁架 x若干","果菜盒 x1"]', 4999.00, 5499.00, 100, '/image/appliances/fridge/10001.webp', '海尔470L对开门冰箱，风冷无霜，一级能效', 1, (SELECT id FROM shops WHERE folder = 'haier' LIMIT 1)),
('海尔 BCD-535WLHFD58SGU1 对开门冰箱', 'appliance', '海尔', 'BCD-535WLHFD58SGU1', '星辉银', '{"总容积":"535L","冷藏室容积":"339L","冷冻室容积":"196L","能效等级":"一级能效","制冷方式":"风冷无霜","噪音":"37dB"}', '["535L超大容量，囤货无忧","风冷无霜，告别除霜烦恼","智能变频，节能省电","干湿分储，食材保鲜","独立双循环，不串味"]', '["冰箱主机 x1","说明书 x1","保修卡 x1","搁架 x若干","果菜盒 x1"]', 5999.00, 6599.00, 80, '/image/appliances/fridge/10002.webp', '海尔535L对开门冰箱，风冷无霜，智能变频', 1, (SELECT id FROM shops WHERE folder = 'haier' LIMIT 1)),
('海尔 BCD-335WLHFD58DSU1 多门冰箱', 'appliance', '海尔', 'BCD-335WLHFD58DSU1', '星辉银', '{"总容积":"335L","冷藏室容积":"188L","冷冻室容积":"117L","变温室容积":"30L","能效等级":"一级能效","制冷方式":"风冷无霜"}', '["335L容量，小户型首选","风冷无霜，告别除霜烦恼","智能变频，节能省电","变温空间，灵活存储","独立双循环，不串味"]', '["冰箱主机 x1","说明书 x1","保修卡 x1","搁架 x若干","果菜盒 x1"]', 3999.00, 4499.00, 120, '/image/appliances/fridge/10003.webp', '海尔335L多门冰箱，风冷无霜，变温空间', 1, (SELECT id FROM shops WHERE folder = 'haier' LIMIT 1)),
('海尔 EG100MATE71S 滚筒洗衣机', 'appliance', '海尔', 'EG100MATE71S', '极夜灰', '{"洗涤容量":"10kg","脱水容量":"10kg","能效等级":"一级能效","洗涤噪音":"52dB","脱水噪音":"68dB","电机类型":"直驱变频电机"}', '["10kg大容量，全家衣物一次洗","直驱变频电机，静音耐用","智能投放，精准省心","95℃高温煮洗，除菌除螨","16种洗涤程序，满足不同需求"]', '["洗衣机主机 x1","说明书 x1","保修卡 x1","进水管 x1","排水管 x1"]', 2999.00, 3499.00, 150, '/image/appliances/washing/10001.webp', '海尔10kg滚筒洗衣机，直驱变频，智能投放', 1, (SELECT id FROM shops WHERE folder = 'haier' LIMIT 1)),
('海尔 EG100HPRO6S 滚筒洗衣机', 'appliance', '海尔', 'EG100HPRO6S', '极夜灰', '{"洗涤容量":"10kg","脱水容量":"10kg","能效等级":"一级能效","洗涤噪音":"48dB","脱水噪音":"65dB","电机类型":"直驱变频电机"}', '["10kg大容量，全家衣物一次洗","直驱变频电机，超静音","智能投放，精准省心","微蒸汽空气洗，护衣除味","18种洗涤程序，满足不同需求"]', '["洗衣机主机 x1","说明书 x1","保修卡 x1","进水管 x1","排水管 x1"]', 3999.00, 4499.00, 100, '/image/appliances/washing/10002.webp', '海尔10kg滚筒洗衣机，微蒸汽空气洗，超静音', 1, (SELECT id FROM shops WHERE folder = 'haier' LIMIT 1)),
('海信 75E5K 75英寸智能电视', 'appliance', '海信', '75E5K', '黑色', '{"屏幕尺寸":"75英寸","分辨率":"4K超高清","刷新率":"120Hz","HDR支持":"支持","智能系统":"VIDAA系统","接口":"HDMI x3, USB x2"}', '["75英寸巨幕，沉浸观影","4K超高清，画质细腻","120Hz高刷，流畅无拖影","杜比全景声，震撼音效","AI语音控制，操作便捷"]', '["电视主机 x1","遥控器 x1","电池 x2","说明书 x1","保修卡 x1","底座 x2"]', 4999.00, 5999.00, 80, '/image/appliances/tv/10001.webp', '海信75英寸4K智能电视，120Hz高刷，杜比全景声', 1, (SELECT id FROM shops WHERE folder = 'hisense' LIMIT 1)),
('海信 65E5K 65英寸智能电视', 'appliance', '海信', '65E5K', '黑色', '{"屏幕尺寸":"65英寸","分辨率":"4K超高清","刷新率":"120Hz","HDR支持":"支持","智能系统":"VIDAA系统","接口":"HDMI x3, USB x2"}', '["65英寸大屏，客厅首选","4K超高清，画质细腻","120Hz高刷，流畅无拖影","杜比全景声，震撼音效","AI语音控制，操作便捷"]', '["电视主机 x1","遥控器 x1","电池 x2","说明书 x1","保修卡 x1","底座 x2"]', 3499.00, 3999.00, 120, '/image/appliances/tv/10002.webp', '海信65英寸4K智能电视，120Hz高刷', 1, (SELECT id FROM shops WHERE folder = 'hisense' LIMIT 1)),
('TCL 75T7G 75英寸智能电视', 'appliance', 'TCL', '75T7G', '黑色', '{"屏幕尺寸":"75英寸","分辨率":"4K超高清","刷新率":"144Hz","HDR支持":"支持","智能系统":"安卓系统","接口":"HDMI x3, USB x2"}', '["75英寸巨幕，沉浸观影","4K超高清，画质细腻","144Hz高刷，游戏利器","杜比全景声，震撼音效","AI语音控制，操作便捷"]', '["电视主机 x1","遥控器 x1","电池 x2","说明书 x1","保修卡 x1","底座 x2"]', 5499.00, 6499.00, 60, '/image/appliances/tv/10003.webp', 'TCL75英寸4K智能电视，144Hz高刷，游戏利器', 1, (SELECT id FROM shops WHERE folder = 'tcl' LIMIT 1)),
('美的 GX5 Pro 洗地机', 'appliance', '美的', 'GX5 Pro', '白色', '{"清洁方式":"吸拖一体","水箱容量":"清水箱800ml/污水箱700ml","续航时间":"35分钟","噪音":"78dB","充电时间":"4小时"}', '["吸拖一体，一步到位","热风烘干，滚刷不发臭","智能感应，自动调节吸力","LED照明，角落清洁无死角","一键自清洁，解放双手"]', '["洗地机主机 x1","充电底座 x1","清洁刷 x1","说明书 x1","保修卡 x1"]', 2999.00, 3499.00, 100, '/image/appliances/floorwasher/10001.webp', '美的GX5 Pro洗地机，吸拖一体，热风烘干', 1, (SELECT id FROM shops WHERE folder = 'midea' LIMIT 1)),
('美的 G7 洗地机', 'appliance', '美的', 'G7', '白色', '{"清洁方式":"吸拖一体","水箱容量":"清水箱900ml/污水箱800ml","续航时间":"40分钟","噪音":"75dB","充电时间":"4小时"}', '["吸拖一体，一步到位","双向助力，推拉轻松","智能感应，自动调节吸力","LED照明，角落清洁无死角","一键自清洁，解放双手"]', '["洗地机主机 x1","充电底座 x1","清洁刷 x1","说明书 x1","保修卡 x1"]', 3999.00, 4499.00, 80, '/image/appliances/floorwasher/10002.webp', '美的G7洗地机，双向助力，一键自清洁', 1, (SELECT id FROM shops WHERE folder = 'midea' LIMIT 1)),
('小米米家无线吸尘器2', 'appliance', '小米', '小米无线吸尘器2', '白色', '{"吸力":"150AW","续航时间":"60分钟","尘杯容量":"0.5L","噪音":"72dB","充电时间":"3.5小时"}', '["150AW强劲吸力","60分钟长续航","5重过滤系统","轻量化设计，仅1.6kg","多刷头配置，全屋清洁"]', '["吸尘器主机 x1","充电底座 x1","电动地刷 x1","缝隙吸头 x1","毛刷吸头 x1","说明书 x1"]', 1999.00, 2499.00, 150, '/image/appliances/floorwasher/10003.webp', '小米无线吸尘器2，150AW强劲吸力，60分钟续航', 1, (SELECT id FROM shops WHERE folder = 'xiaomi' LIMIT 1));

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '格力 云锦Ⅱ 1.5匹变频空调' AND category = 'appliance' LIMIT 1), '/image/appliances/aircondition/10001.webp', 1),
((SELECT id FROM products WHERE name = '格力 云佳 1.5匹变频空调' AND category = 'appliance' LIMIT 1), '/image/appliances/aircondition/10002.webp', 1),
((SELECT id FROM products WHERE name = '格力 京爽 1.5匹变频空调' AND category = 'appliance' LIMIT 1), '/image/appliances/aircondition/10003.webp', 1),
((SELECT id FROM products WHERE name = '海尔 BCD-470WDPG 对开门冰箱' AND category = 'appliance' LIMIT 1), '/image/appliances/fridge/10001.webp', 1),
((SELECT id FROM products WHERE name = '海尔 BCD-535WLHFD58SGU1 对开门冰箱' AND category = 'appliance' LIMIT 1), '/image/appliances/fridge/10002.webp', 1),
((SELECT id FROM products WHERE name = '海尔 BCD-335WLHFD58DSU1 多门冰箱' AND category = 'appliance' LIMIT 1), '/image/appliances/fridge/10003.webp', 1),
((SELECT id FROM products WHERE name = '海尔 EG100MATE71S 滚筒洗衣机' AND category = 'appliance' LIMIT 1), '/image/appliances/washing/10001.webp', 1),
((SELECT id FROM products WHERE name = '海尔 EG100HPRO6S 滚筒洗衣机' AND category = 'appliance' LIMIT 1), '/image/appliances/washing/10002.webp', 1),
((SELECT id FROM products WHERE name = '海信 75E5K 75英寸智能电视' AND category = 'appliance' LIMIT 1), '/image/appliances/tv/10001.webp', 1),
((SELECT id FROM products WHERE name = '海信 65E5K 65英寸智能电视' AND category = 'appliance' LIMIT 1), '/image/appliances/tv/10002.webp', 1),
((SELECT id FROM products WHERE name = 'TCL 75T7G 75英寸智能电视' AND category = 'appliance' LIMIT 1), '/image/appliances/tv/10003.webp', 1),
((SELECT id FROM products WHERE name = '美的 GX5 Pro 洗地机' AND category = 'appliance' LIMIT 1), '/image/appliances/floorwasher/10001.webp', 1),
((SELECT id FROM products WHERE name = '美的 G7 洗地机' AND category = 'appliance' LIMIT 1), '/image/appliances/floorwasher/10002.webp', 1),
((SELECT id FROM products WHERE name = '小米米家无线吸尘器2' AND category = 'appliance' LIMIT 1), '/image/appliances/floorwasher/10003.webp', 1);

-- ============================================================
-- 第九部分：服装鞋帽商品数据 (category = 'cloth-shoes')
-- ============================================================

INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Nike Air Max 270 黑白配色', 'cloth-shoes', 'Nike', 'Air Max 270', '黑白', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["经典气垫设计","舒适缓震","百搭时尚","透气网面"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1199.00, 200, '/image/cloth-shoes/shoes/10001.png', 'Nike Air Max 270 经典黑白配色，舒适缓震', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 270 白红配色', 'cloth-shoes', 'Nike', 'Air Max 270', '白红', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["经典气垫设计","舒适缓震","百搭时尚","透气网面"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1199.00, 180, '/image/cloth-shoes/shoes/10002.png', 'Nike Air Max 270 白红配色，活力时尚', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 270 全黑配色', 'cloth-shoes', 'Nike', 'Air Max 270', '全黑', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["经典气垫设计","舒适缓震","百搭时尚","透气网面"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1199.00, 150, '/image/cloth-shoes/shoes/10003.png', 'Nike Air Max 270 全黑配色，低调百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 270 白蓝配色', 'cloth-shoes', 'Nike', 'Air Max 270', '白蓝', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["经典气垫设计","舒适缓震","百搭时尚","透气网面"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1199.00, 160, '/image/cloth-shoes/shoes/10004.png', 'Nike Air Max 270 白蓝配色，清新百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('AJ1 黑红配色', 'cloth-shoes', 'Jordan', 'AJ1', '黑红', '{"类型":"篮球鞋","尺码":"36-46","鞋底":"橡胶"}', '["经典AJ1设计","复古潮流","限量发售","收藏价值高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1","吊牌 x1"]', 1599.00, 1999.00, 100, '/image/cloth-shoes/shoes/10005.png', 'AJ1 黑红配色，经典复刻，限量发售', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 黑白配色', 'cloth-shoes', 'Jordan', 'AJ1', '黑白', '{"类型":"篮球鞋","尺码":"36-46","鞋底":"橡胶"}', '["经典AJ1设计","复古潮流","限量发售","收藏价值高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1","吊牌 x1"]', 1599.00, 1999.00, 80, '/image/cloth-shoes/shoes/10006.png', 'AJ1 黑白配色，经典熊猫配色', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 芝加哥配色', 'cloth-shoes', 'Jordan', 'AJ1', '芝加哥', '{"类型":"篮球鞋","尺码":"36-46","鞋底":"橡胶"}', '["经典AJ1设计","复古潮流","限量发售","收藏价值高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1","吊牌 x1"]', 1899.00, 2299.00, 50, '/image/cloth-shoes/shoes/10007.png', 'AJ1 芝加哥配色，经典复刻', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 皇家蓝配色', 'cloth-shoes', 'Jordan', 'AJ1', '皇家蓝', '{"类型":"篮球鞋","尺码":"36-46","鞋底":"橡胶"}', '["经典AJ1设计","复古潮流","限量发售","收藏价值高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1","吊牌 x1"]', 1799.00, 2199.00, 60, '/image/cloth-shoes/shoes/10008.png', 'AJ1 皇家蓝配色，经典配色', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('LV Neverfull 手提包', 'cloth-shoes', 'Louis Vuitton', 'Neverfull', '棕色', '{"类型":"手提包","尺寸":"中号","材质":"帆布/皮革"}', '["经典老花设计","大容量实用","百搭时尚","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 12999.00, 14999.00, 30, '/image/cloth-shoes/bag/10011.png', 'LV Neverfull 中号手提包，经典老花设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('LV Speedy 斜挎包', 'cloth-shoes', 'Louis Vuitton', 'Speedy', '棕色', '{"类型":"斜挎包","尺寸":"中号","材质":"帆布/皮革"}', '["经典老花设计","百搭时尚","品质保证","限量发售"]', '["斜挎包 x1","防尘袋 x1","说明书 x1"]', 10999.00, 12999.00, 20, '/image/cloth-shoes/bag/10012.png', 'LV Speedy 中号斜挎包，经典老花设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Gucci Marmont 链条包', 'cloth-shoes', 'Gucci', 'Marmont', '黑色', '{"类型":"链条包","尺寸":"小号","材质":"皮革"}', '["经典双G设计","百搭时尚","品质保证","限量发售"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 15999.00, 17999.00, 15, '/image/cloth-shoes/bag/10013.png', 'Gucci Marmont 小号链条包，经典双G设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Gucci Dionysus 酒神包', 'cloth-shoes', 'Gucci', 'Dionysus', '黑色', '{"类型":"链条包","尺寸":"小号","材质":"皮革"}', '["经典酒神设计","百搭时尚","品质保证","限量发售"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 18999.00, 20999.00, 10, '/image/cloth-shoes/bag/10014.png', 'Gucci Dionysus 小号酒神包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Chanel Classic Flap 经典款', 'cloth-shoes', 'Chanel', 'Classic Flap', '黑色', '{"类型":"链条包","尺寸":"中号","材质":"羊皮"}', '["经典菱格设计","百搭时尚","品质保证","限量发售"]', '["链条包 x1","防尘袋 x1","说明书 x1","身份卡 x1"]', 59999.00, 64999.00, 5, '/image/cloth-shoes/bag/10015.png', 'Chanel Classic Flap 中号经典款，永恒经典', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Chanel Boy 链条包', 'cloth-shoes', 'Chanel', 'Boy', '黑色', '{"类型":"链条包","尺寸":"中号","材质":"羊皮"}', '["经典Boy设计","百搭时尚","品质保证","限量发售"]', '["链条包 x1","防尘袋 x1","说明书 x1","身份卡 x1"]', 45999.00, 49999.00, 8, '/image/cloth-shoes/bag/10016.png', 'Chanel Boy 中号链条包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Hermes Birkin 铂金包', 'cloth-shoes', 'Hermes', 'Birkin', '橙色', '{"类型":"手提包","尺寸":"30cm","材质":"Togo皮"}', '["经典Birkin设计","顶级工艺","限量发售","收藏价值高"]', '["手提包 x1","防尘袋 x1","说明书 x1","身份卡 x1"]', 129999.00, 149999.00, 2, '/image/cloth-shoes/bag/10017.png', 'Hermes Birkin 30cm 铂金包，顶级工艺', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Hermes Kelly 凯莉包', 'cloth-shoes', 'Hermes', 'Kelly', '黑色', '{"类型":"手提包","尺寸":"28cm","材质":"Epsom皮"}', '["经典Kelly设计","顶级工艺","限量发售","收藏价值高"]', '["手提包 x1","防尘袋 x1","说明书 x1","身份卡 x1"]', 119999.00, 139999.00, 3, '/image/cloth-shoes/bag/10018.png', 'Hermes Kelly 28cm 凯莉包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Dior Lady Dior 戴妃包', 'cloth-shoes', 'Dior', 'Lady Dior', '黑色', '{"类型":"链条包","尺寸":"中号","材质":"羊皮"}', '["经典戴妃包设计","百搭时尚","品质保证","限量发售"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 35999.00, 39999.00, 10, '/image/cloth-shoes/bag/10019.png', 'Dior Lady Dior 中号戴妃包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Dior Saddle 马鞍包', 'cloth-shoes', 'Dior', 'Saddle', '蓝色', '{"类型":"斜挎包","尺寸":"中号","材质":"帆布/皮革"}', '["经典马鞍设计","百搭时尚","品质保证","限量发售"]', '["斜挎包 x1","防尘袋 x1","说明书 x1"]', 28999.00, 32999.00, 12, '/image/cloth-shoes/bag/10020.png', 'Dior Saddle 中号马鞍包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Prada Galleria 杀手包', 'cloth-shoes', 'Prada', 'Galleria', '黑色', '{"类型":"手提包","尺寸":"中号","材质":"Saffiano皮革"}', '["经典杀手包设计","百搭时尚","品质保证","限量发售"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 21999.00, 24999.00, 15, '/image/cloth-shoes/bag/10021.png', 'Prada Galleria 中号杀手包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Prada Re-Edition 尼龙包', 'cloth-shoes', 'Prada', 'Re-Edition', '黑色', '{"类型":"斜挎包","尺寸":"小号","材质":"尼龙/皮革"}', '["经典尼龙设计","百搭时尚","品质保证","限量发售"]', '["斜挎包 x1","防尘袋 x1","说明书 x1"]', 12999.00, 14999.00, 20, '/image/cloth-shoes/bag/10022.png', 'Prada Re-Edition 小号尼龙包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Celine Luggage 笑脸包', 'cloth-shoes', 'Celine', 'Luggage', '黑色', '{"类型":"手提包","尺寸":"中号","材质":"皮革"}', '["经典笑脸包设计","百搭时尚","品质保证","限量发售"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 25999.00, 29999.00, 10, '/image/cloth-shoes/bag/10023.png', 'Celine Luggage 中号笑脸包，经典设计', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1));

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Max 270 黑白配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10001.png', 1),
((SELECT id FROM products WHERE name = 'Nike Air Max 270 白红配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10002.png', 1),
((SELECT id FROM products WHERE name = 'Nike Air Max 270 全黑配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10003.png', 1),
((SELECT id FROM products WHERE name = 'Nike Air Max 270 白蓝配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10004.png', 1),
((SELECT id FROM products WHERE name = 'AJ1 黑红配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10005.png', 1),
((SELECT id FROM products WHERE name = 'AJ1 黑白配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10006.png', 1),
((SELECT id FROM products WHERE name = 'AJ1 芝加哥配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10007.png', 1),
((SELECT id FROM products WHERE name = 'AJ1 皇家蓝配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10008.png', 1),
((SELECT id FROM products WHERE name = 'LV Neverfull 手提包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10011.png', 1),
((SELECT id FROM products WHERE name = 'LV Speedy 斜挎包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10012.png', 1),
((SELECT id FROM products WHERE name = 'Gucci Marmont 链条包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10013.png', 1),
((SELECT id FROM products WHERE name = 'Gucci Dionysus 酒神包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10014.png', 1),
((SELECT id FROM products WHERE name = 'Chanel Classic Flap 经典款' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10015.png', 1),
((SELECT id FROM products WHERE name = 'Chanel Boy 链条包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10016.png', 1),
((SELECT id FROM products WHERE name = 'Hermes Birkin 铂金包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10017.png', 1),
((SELECT id FROM products WHERE name = 'Hermes Kelly 凯莉包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10018.png', 1),
((SELECT id FROM products WHERE name = 'Dior Lady Dior 戴妃包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10019.png', 1),
((SELECT id FROM products WHERE name = 'Dior Saddle 马鞍包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10020.png', 1),
((SELECT id FROM products WHERE name = 'Prada Galleria 杀手包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10021.png', 1),
((SELECT id FROM products WHERE name = 'Prada Re-Edition 尼龙包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10022.png', 1),
((SELECT id FROM products WHERE name = 'Celine Luggage 笑脸包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10023.png', 1);

-- ============================================================
-- 第十部分：食品商品数据 (category = 'food')
-- ============================================================

INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('香辣辣条 100g', 'food', '零食品牌', '香辣味', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["香辣可口","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10001.png', '香辣辣条，Q弹有嚼劲', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('麻辣辣条 100g', 'food', '零食品牌', '麻辣味', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"麻辣"}', '["麻辣过瘾","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10002.png', '麻辣辣条，麻辣过瘾', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('甜辣辣条 100g', 'food', '零食品牌', '甜辣味', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"甜辣"}', '["甜辣适中","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10003.png', '甜辣辣条，甜辣适中', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('原味辣条 100g', 'food', '零食品牌', '原味', '黄色', '{"类型":"辣条","规格":"100g/袋","口味":"原味"}', '["原味经典","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10004.png', '原味辣条，经典口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('蒜香辣条 100g', 'food', '零食品牌', '蒜香味', '黄色', '{"类型":"辣条","规格":"100g/袋","口味":"蒜香"}', '["蒜香浓郁","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10005.png', '蒜香辣条，蒜香浓郁', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('五香味辣条 100g', 'food', '零食品牌', '五香味', '棕色', '{"类型":"辣条","规格":"100g/袋","口味":"五香"}', '["五香浓郁","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10006.png', '五香味辣条，五香浓郁', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('烧烤味辣条 100g', 'food', '零食品牌', '烧烤味', '棕色', '{"类型":"辣条","规格":"100g/袋","口味":"烧烤"}', '["烧烤风味","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10007.png', '烧烤味辣条，烧烤风味', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('孜然味辣条 100g', 'food', '零食品牌', '孜然味', '棕色', '{"类型":"辣条","规格":"100g/袋","口味":"孜然"}', '["孜然风味","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10008.png', '孜然味辣条，孜然风味', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('番茄味薯片 150g', 'food', '零食品牌', '番茄味', '红色', '{"类型":"薯片","规格":"150g/袋","口味":"番茄"}', '["番茄酸甜","酥脆可口","独立包装","追剧必备"]', '["薯片 150g","包装袋 x1"]', 12.00, 15.00, 500, '/image/food/薯片/10031.png', '番茄味薯片，番茄酸甜', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('烧烤味薯片 150g', 'food', '零食品牌', '烧烤味', '棕色', '{"类型":"薯片","规格":"150g/袋","口味":"烧烤"}', '["烧烤风味","酥脆可口","独立包装","追剧必备"]', '["薯片 150g","包装袋 x1"]', 12.00, 15.00, 500, '/image/food/薯片/10032.png', '烧烤味薯片，烧烤风味', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('原味薯片 150g', 'food', '零食品牌', '原味', '黄色', '{"类型":"薯片","规格":"150g/袋","口味":"原味"}', '["原味经典","酥脆可口","独立包装","追剧必备"]', '["薯片 150g","包装袋 x1"]', 12.00, 15.00, 500, '/image/food/薯片/10033.png', '原味薯片，经典口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('黄瓜味薯片 150g', 'food', '零食品牌', '黄瓜味', '绿色', '{"类型":"薯片","规格":"150g/袋","口味":"黄瓜"}', '["黄瓜清香","酥脆可口","独立包装","追剧必备"]', '["薯片 150g","包装袋 x1"]', 12.00, 15.00, 500, '/image/food/薯片/10034.png', '黄瓜味薯片，黄瓜清香', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('桶装薯片 150g', 'food', '零食品牌', '桶装', '红色', '{"类型":"薯片","规格":"150g/桶","口味":"原味"}', '["原味经典","酥脆可口","桶装包装","追剧必备"]', '["薯片 150g","包装桶 x1"]', 15.00, 18.00, 300, '/image/food/薯片/10035.png', '桶装薯片，原味经典', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('桶装薯片 150g', 'food', '零食品牌', '桶装', '绿色', '{"类型":"薯片","规格":"150g/桶","口味":"黄瓜"}', '["黄瓜清香","酥脆可口","桶装包装","追剧必备"]', '["薯片 150g","包装桶 x1"]', 15.00, 18.00, 300, '/image/food/薯片/10036.png', '桶装薯片，黄瓜清香', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1));

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '香辣辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10001.png', 1),
((SELECT id FROM products WHERE name = '麻辣辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10002.png', 1),
((SELECT id FROM products WHERE name = '甜辣辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10003.png', 1),
((SELECT id FROM products WHERE name = '原味辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10004.png', 1),
((SELECT id FROM products WHERE name = '蒜香辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10005.png', 1),
((SELECT id FROM products WHERE name = '五香味辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10006.png', 1),
((SELECT id FROM products WHERE name = '烧烤味辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10007.png', 1),
((SELECT id FROM products WHERE name = '孜然味辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10008.png', 1),
((SELECT id FROM products WHERE name = '番茄味薯片 150g' AND category = 'food' LIMIT 1), '/image/food/薯片/10031.png', 1),
((SELECT id FROM products WHERE name = '烧烤味薯片 150g' AND category = 'food' LIMIT 1), '/image/food/薯片/10032.png', 1),
((SELECT id FROM products WHERE name = '原味薯片 150g' AND category = 'food' LIMIT 1), '/image/food/薯片/10033.png', 1),
((SELECT id FROM products WHERE name = '黄瓜味薯片 150g' AND category = 'food' LIMIT 1), '/image/food/薯片/10034.png', 1),
((SELECT id FROM products WHERE name = '桶装薯片 150g' AND category = 'food' AND color = '红色' LIMIT 1), '/image/food/薯片/10035.png', 1),
((SELECT id FROM products WHERE name = '桶装薯片 150g' AND category = 'food' AND color = '绿色' LIMIT 1), '/image/food/薯片/10036.png', 1);

-- ============================================================
-- 第十一部分：图书文具商品数据 (category = 'book')
-- ============================================================

INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('文学小说精选套装1', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约300页","开本":"32开"}', '["经典文学作品","语言朴实情感真挚","中国当代文学经典","值得收藏阅读"]', '["图书 x1","塑封包装"]', 35.00, 45.00, 500, '/image/book/10001.png', '经典文学小说作品', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('文学小说精选套装2', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约300页","开本":"32开"}', '["经典文学作品","语言朴实情感真挚","中国当代文学经典","值得收藏阅读"]', '["图书 x1","塑封包装"]', 35.00, 45.00, 500, '/image/book/10002.png', '经典文学小说作品', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('文学小说精选套装3', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约300页","开本":"32开"}', '["经典文学作品","语言朴实情感真挚","中国当代文学经典","值得收藏阅读"]', '["图书 x1","塑封包装"]', 35.00, 45.00, 500, '/image/book/10003.png', '经典文学小说作品', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('文学小说精选套装4', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约300页","开本":"32开"}', '["经典文学作品","语言朴实情感真挚","中国当代文学经典","值得收藏阅读"]', '["图书 x1","塑封包装"]', 35.00, 45.00, 500, '/image/book/10004.png', '经典文学小说作品', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('历史传记精选套装1', 'book', '出版社', '历史类', '精装', '{"类型":"历史传记","页数":"约400页","开本":"16开"}', '["历史传记经典","史料翔实可信","了解历史必读","值得收藏阅读"]', '["图书 x1","塑封包装"]', 58.00, 78.00, 300, '/image/book/10005.png', '经典历史传记作品', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('历史传记精选套装2', 'book', '出版社', '历史类', '精装', '{"类型":"历史传记","页数":"约400页","开本":"16开"}', '["历史传记经典","史料翔实可信","了解历史必读","值得收藏阅读"]', '["图书 x1","塑封包装"]', 58.00, 78.00, 300, '/image/book/10006.png', '经典历史传记作品', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('经济管理精选套装1', 'book', '出版社', '经济类', '平装', '{"类型":"经济管理","页数":"约350页","开本":"16开"}', '["经济管理经典","案例丰富实用","职场必读","值得收藏阅读"]', '["图书 x1","塑封包装"]', 48.00, 68.00, 400, '/image/book/10007.png', '经典经济管理作品', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1)),
('经济管理精选套装2', 'book', '出版社', '经济类', '平装', '{"类型":"经济管理","页数":"约350页","开本":"16开"}', '["经济管理经典","案例丰富实用","职场必读","值得收藏阅读"]', '["图书 x1","塑封包装"]', 48.00, 68.00, 400, '/image/book/10008.png', '经典经济管理作品', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1)),
('钢笔套装', 'book', '文具品牌', '钢笔', '黑色', '{"类型":"钢笔套装","笔尖":"德国进口","墨水":"可替换"}', '["德国进口笔尖","书写流畅","精美礼盒","送礼佳品"]', '["钢笔 x1","墨水 x2","礼盒 x1"]', 128.00, 168.00, 200, '/image/book/10021.png', '精美钢笔套装', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('钢笔套装', 'book', '文具品牌', '钢笔', '银色', '{"类型":"钢笔套装","笔尖":"德国进口","墨水":"可替换"}', '["德国进口笔尖","书写流畅","精美礼盒","送礼佳品"]', '["钢笔 x1","墨水 x2","礼盒 x1"]', 128.00, 168.00, 200, '/image/book/10022.png', '精美钢笔套装', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('钢笔套装', 'book', '文具品牌', '钢笔', '金色', '{"类型":"钢笔套装","笔尖":"德国进口","墨水":"可替换"}', '["德国进口笔尖","书写流畅","精美礼盒","送礼佳品"]', '["钢笔 x1","墨水 x2","礼盒 x1"]', 128.00, 168.00, 200, '/image/book/10023.png', '精美钢笔套装', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('笔记本 A5', 'book', '文具品牌', '笔记本', '蓝色', '{"类型":"笔记本","规格":"A5","页数":"100页"}', '["优质纸张","书写流畅","精美封面","学习办公必备"]', '["笔记本 x1"]', 15.00, 20.00, 1000, '/image/book/10024.png', '精美笔记本', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1)),
('笔记本 A5', 'book', '文具品牌', '笔记本', '粉色', '{"类型":"笔记本","规格":"A5","页数":"100页"}', '["优质纸张","书写流畅","精美封面","学习办公必备"]', '["笔记本 x1"]', 15.00, 20.00, 1000, '/image/book/10025.png', '精美笔记本', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('笔记本 B5', 'book', '文具品牌', '笔记本', '绿色', '{"类型":"笔记本","规格":"B5","页数":"120页"}', '["优质纸张","书写流畅","精美封面","学习办公必备"]', '["笔记本 x1"]', 18.00, 25.00, 800, '/image/book/10026.png', '精美笔记本', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('笔记本 B5', 'book', '文具品牌', '笔记本', '黄色', '{"类型":"笔记本","规格":"B5","页数":"120页"}', '["优质纸张","书写流畅","精美封面","学习办公必备"]', '["笔记本 x1"]', 18.00, 25.00, 800, '/image/book/10027.png', '精美笔记本', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('活页本 A5', 'book', '文具品牌', '活页本', '白色', '{"类型":"活页本","规格":"A5","页数":"可替换"}', '["活页设计","可替换内芯","精美封面","学习办公必备"]', '["活页本 x1","内芯 x1"]', 25.00, 35.00, 600, '/image/book/10028.png', '精美活页本', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1)),
('活页本 A5', 'book', '文具品牌', '活页本', '黑色', '{"类型":"活页本","规格":"A5","页数":"可替换"}', '["活页设计","可替换内芯","精美封面","学习办公必备"]', '["活页本 x1","内芯 x1"]', 25.00, 35.00, 600, '/image/book/10029.png', '精美活页本', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('活页本 B5', 'book', '文具品牌', '活页本', '灰色', '{"类型":"活页本","规格":"B5","页数":"可替换"}', '["活页设计","可替换内芯","精美封面","学习办公必备"]', '["活页本 x1","内芯 x1"]', 28.00, 38.00, 500, '/image/book/10030.png', '精美活页本', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1));

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装1' AND category = 'book' LIMIT 1), '/image/book/10001.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装2' AND category = 'book' LIMIT 1), '/image/book/10002.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装3' AND category = 'book' LIMIT 1), '/image/book/10003.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装4' AND category = 'book' LIMIT 1), '/image/book/10004.png', 1),
((SELECT id FROM products WHERE name = '历史传记精选套装1' AND category = 'book' LIMIT 1), '/image/book/10005.png', 1),
((SELECT id FROM products WHERE name = '历史传记精选套装2' AND category = 'book' LIMIT 1), '/image/book/10006.png', 1),
((SELECT id FROM products WHERE name = '经济管理精选套装1' AND category = 'book' LIMIT 1), '/image/book/10007.png', 1),
((SELECT id FROM products WHERE name = '经济管理精选套装2' AND category = 'book' LIMIT 1), '/image/book/10008.png', 1),
((SELECT id FROM products WHERE name = '钢笔套装' AND category = 'book' AND color = '黑色' LIMIT 1), '/image/book/10021.png', 1),
((SELECT id FROM products WHERE name = '钢笔套装' AND category = 'book' AND color = '银色' LIMIT 1), '/image/book/10022.png', 1),
((SELECT id FROM products WHERE name = '钢笔套装' AND category = 'book' AND color = '金色' LIMIT 1), '/image/book/10023.png', 1),
((SELECT id FROM products WHERE name = '笔记本 A5' AND category = 'book' AND color = '蓝色' LIMIT 1), '/image/book/10024.png', 1),
((SELECT id FROM products WHERE name = '笔记本 A5' AND category = 'book' AND color = '粉色' LIMIT 1), '/image/book/10025.png', 1),
((SELECT id FROM products WHERE name = '笔记本 B5' AND category = 'book' AND color = '绿色' LIMIT 1), '/image/book/10026.png', 1),
((SELECT id FROM products WHERE name = '笔记本 B5' AND category = 'book' AND color = '黄色' LIMIT 1), '/image/book/10027.png', 1),
((SELECT id FROM products WHERE name = '活页本 A5' AND category = 'book' AND color = '白色' LIMIT 1), '/image/book/10028.png', 1),
((SELECT id FROM products WHERE name = '活页本 A5' AND category = 'book' AND color = '黑色' LIMIT 1), '/image/book/10029.png', 1),
((SELECT id FROM products WHERE name = '活页本 B5' AND category = 'book' LIMIT 1), '/image/book/10030.png', 1);

-- ============================================================
-- 第十二部分：运动户外商品数据 (category = 'sports')
-- ============================================================

INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('游泳装备套装1', 'sports', '游泳品牌', '套装1', '多色', '{"类型":"游泳装备","尺码":"S-XXL","材质":"涤纶"}', '["专业游泳装备","舒适透气","耐用防水","适合初学者"]', '["游泳装备 x1","包装盒 x1"]', 199.00, 299.00, 150, '/image/sports/游泳装备/2ef05a72-4889-44a6-9026-0abe55c62642.webp', '专业游泳装备套装', 1, (SELECT id FROM shops WHERE folder = 'sports3' LIMIT 1)),
('游泳装备套装2', 'sports', '游泳品牌', '套装2', '多色', '{"类型":"游泳装备","尺码":"S-XXL","材质":"涤纶"}', '["专业游泳装备","舒适透气","耐用防水","适合进阶"]', '["游泳装备 x1","包装盒 x1"]', 299.00, 399.00, 120, '/image/sports/游泳装备/2ef05a72-4889-44a6-9026-0abe55c62642.webp', '专业游泳装备套装', 1, (SELECT id FROM shops WHERE folder = 'sports3' LIMIT 1)),
('登山装备套装1', 'sports', '登山品牌', '套装1', '多色', '{"类型":"登山装备","尺码":"S-XXL","材质":"尼龙"}', '["专业登山装备","耐磨耐用","轻便舒适","适合入门"]', '["登山装备 x1","包装盒 x1"]', 399.00, 599.00, 100, '/image/sports/登山装备/登山装备1.webp', '专业登山装备套装', 1, (SELECT id FROM shops WHERE folder = 'sports2' LIMIT 1)),
('登山装备套装2', 'sports', '登山品牌', '套装2', '多色', '{"类型":"登山装备","尺码":"S-XXL","材质":"尼龙"}', '["专业登山装备","耐磨耐用","轻便舒适","适合进阶"]', '["登山装备 x1","包装盒 x1"]', 599.00, 799.00, 80, '/image/sports/登山装备/登山装备2.webp', '专业登山装备套装', 1, (SELECT id FROM shops WHERE folder = 'sports2' LIMIT 1)),
('骑行装备套装1', 'sports', '骑行品牌', '套装1', '多色', '{"类型":"骑行装备","尺码":"S-XXL","材质":"涤纶"}', '["专业骑行装备","透气舒适","耐磨耐用","适合入门"]', '["骑行装备 x1","包装盒 x1"]', 299.00, 399.00, 120, '/image/sports/骑行装备/骑行装备1.webp', '专业骑行装备套装', 1, (SELECT id FROM shops WHERE folder = 'sports4' LIMIT 1)),
('骑行装备套装2', 'sports', '骑行品牌', '套装2', '多色', '{"类型":"骑行装备","尺码":"S-XXL","材质":"涤纶"}', '["专业骑行装备","透气舒适","耐磨耐用","适合进阶"]', '["骑行装备 x1","包装盒 x1"]', 499.00, 699.00, 100, '/image/sports/骑行装备/骑行装备2.webp', '专业骑行装备套装', 1, (SELECT id FROM shops WHERE folder = 'sports4' LIMIT 1));

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '游泳装备套装1' AND category = 'sports' LIMIT 1), '/image/sports/游泳装备/2ef05a72-4889-44a6-9026-0abe55c62642.webp', 1),
((SELECT id FROM products WHERE name = '游泳装备套装2' AND category = 'sports' LIMIT 1), '/image/sports/游泳装备/2ef05a72-4889-44a6-9026-0abe55c62642.webp', 1),
((SELECT id FROM products WHERE name = '登山装备套装1' AND category = 'sports' LIMIT 1), '/image/sports/登山装备/登山装备1.webp', 1),
((SELECT id FROM products WHERE name = '登山装备套装2' AND category = 'sports' LIMIT 1), '/image/sports/登山装备/登山装备2.webp', 1),
((SELECT id FROM products WHERE name = '骑行装备套装1' AND category = 'sports' LIMIT 1), '/image/sports/骑行装备/骑行装备1.webp', 1),
((SELECT id FROM products WHERE name = '骑行装备套装2' AND category = 'sports' LIMIT 1), '/image/sports/骑行装备/骑行装备2.webp', 1);

-- ============================================================
-- 第十三部分：美妆护肤商品数据 (category = 'cosmetics')
-- ============================================================

INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('化妆品套装1', 'cosmetics', '美妆品牌', '套装1', '多色', '{"类型":"化妆品","规格":"标准装","保质期":"3年"}', '["精选美妆产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 1299.00, 1540.00, 100, '/image/cosmetics/10001.webp', '精选化妆品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang1' LIMIT 1)),
('化妆品套装2', 'cosmetics', '美妆品牌', '套装2', '多色', '{"类型":"化妆品","规格":"标准装","保质期":"3年"}', '["精选美妆产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 1399.00, 1640.00, 80, '/image/cosmetics/10002.webp', '精选化妆品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang1' LIMIT 1)),
('化妆品套装3', 'cosmetics', '美妆品牌', '套装3', '多色', '{"类型":"化妆品","规格":"标准装","保质期":"3年"}', '["精选美妆产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 1499.00, 1740.00, 60, '/image/cosmetics/10003.webp', '精选化妆品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang2' LIMIT 1)),
('化妆品套装4', 'cosmetics', '美妆品牌', '套装4', '多色', '{"类型":"化妆品","规格":"标准装","保质期":"3年"}', '["精选美妆产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 1599.00, 1840.00, 50, '/image/cosmetics/10004.webp', '精选化妆品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang2' LIMIT 1)),
('护肤品套装1', 'cosmetics', '护肤品牌', '套装1', '白色', '{"类型":"护肤品","规格":"标准装","保质期":"3年"}', '["精选护肤产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 899.00, 1099.00, 120, '/image/cosmetics/10005.webp', '精选护肤品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang3' LIMIT 1)),
('护肤品套装2', 'cosmetics', '护肤品牌', '套装2', '白色', '{"类型":"护肤品","规格":"标准装","保质期":"3年"}', '["精选护肤产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 999.00, 1199.00, 100, '/image/cosmetics/10006.webp', '精选护肤品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang3' LIMIT 1)),
('护肤品套装3', 'cosmetics', '护肤品牌', '套装3', '白色', '{"类型":"护肤品","规格":"标准装","保质期":"3年"}', '["精选护肤产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 1099.00, 1299.00, 80, '/image/cosmetics/10007.webp', '精选护肤品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang4' LIMIT 1)),
('护肤品套装4', 'cosmetics', '护肤品牌', '套装4', '白色', '{"类型":"护肤品","规格":"标准装","保质期":"3年"}', '["精选护肤产品","品质保证","适合日常","性价比高"]', '["化妆品 x1","包装盒 x1"]', 1199.00, 1399.00, 60, '/image/cosmetics/10008.webp', '精选护肤品套装', 1, (SELECT id FROM shops WHERE folder = 'meizhuang4' LIMIT 1));

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '化妆品套装1' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10001.webp', 1),
((SELECT id FROM products WHERE name = '化妆品套装2' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10002.webp', 1),
((SELECT id FROM products WHERE name = '化妆品套装3' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10003.webp', 1),
((SELECT id FROM products WHERE name = '化妆品套装4' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10004.webp', 1),
((SELECT id FROM products WHERE name = '护肤品套装1' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10005.webp', 1),
((SELECT id FROM products WHERE name = '护肤品套装2' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10006.webp', 1),
((SELECT id FROM products WHERE name = '护肤品套装3' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10007.webp', 1),
((SELECT id FROM products WHERE name = '护肤品套装4' AND category = 'cosmetics' LIMIT 1), '/image/cosmetics/10008.webp', 1);

-- ============================================================
-- 初始化完成
-- ============================================================