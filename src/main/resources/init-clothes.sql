-- ============================================================
-- 服饰鞋包商品初始化脚本
-- 图片路径：/image/cloth-shoes/shoes/ 和 /image/cloth-shoes/bag/
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ============================================================
-- 1. 清空服饰鞋包相关数据
-- ============================================================
DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE category = 'cloth-shoes');
DELETE FROM products WHERE category = 'cloth-shoes';

-- ============================================================
-- 2. 添加服饰鞋包相关店铺
-- ============================================================
INSERT IGNORE INTO shops (name, folder, description, sort_order) VALUES
('耐克官方旗舰店', 'nike', '耐克官方授权店铺，正品保障', 30),
('AJ球鞋专卖店', 'aj', 'AJ球鞋官方店铺，限量发售', 31),
('奢侈品箱包旗舰店', 'luxury', '奢侈品箱包官方店铺，品质保证', 32),
('名牌包包专营店', 'bag', '名牌包包官方店铺，正品直营', 33);

-- ============================================================
-- 3. 鞋类商品 (Nike/AJ) - category = 'cloth-shoes'
-- ============================================================

-- Nike Air Max系列
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Nike Air Max 270 黑白配色', 'cloth-shoes', 'Nike', 'Air Max 270', '黑白', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["经典气垫设计","舒适缓震","百搭时尚","透气网面"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1199.00, 200, '/image/cloth-shoes/shoes/10001.png', 'Nike Air Max 270 经典黑白配色，舒适缓震', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 270 白红配色', 'cloth-shoes', 'Nike', 'Air Max 270', '白红', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["经典气垫设计","舒适缓震","时尚百搭","透气轻盈"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1199.00, 180, '/image/cloth-shoes/shoes/10002.png', 'Nike Air Max 270 白红配色，时尚百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 90 经典复古', 'cloth-shoes', 'Nike', 'Air Max 90', '白灰红', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["复古经典设计","气垫缓震","耐磨大底","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 999.00, 150, '/image/cloth-shoes/shoes/10003.png', 'Nike Air Max 90 经典复古款，潮流必备', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 97 银子弹', 'cloth-shoes', 'Nike', 'Air Max 97', '银色', '{"类型":"运动鞋","尺码":"36-45","鞋底":"全掌气垫"}', '["全掌气垫","流线型设计","银子弹配色","潮流经典"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1299.00, 1599.00, 100, '/image/cloth-shoes/shoes/10004.png', 'Nike Air Max 97 银子弹，全掌气垫', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 1 经典款', 'cloth-shoes', 'Nike', 'Air Max 1', '白蓝橙', '{"类型":"运动鞋","尺码":"36-45","鞋底":"气垫"}', '["气垫鼻祖","经典设计","舒适百搭","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 999.00, 120, '/image/cloth-shoes/shoes/10005.png', 'Nike Air Max 1 气垫鼻祖，经典百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1));

-- Nike Air Force系列
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Nike Air Force 1 纯白经典', 'cloth-shoes', 'Nike', 'Air Force 1', '纯白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["空军一号","经典纯白","百搭之王","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 899.00, 300, '/image/cloth-shoes/shoes/10006.png', 'Nike Air Force 1 空军一号纯白经典', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Force 1 黑白熊猫', 'cloth-shoes', 'Nike', 'Air Force 1', '黑白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["熊猫配色","经典设计","百搭时尚","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 899.00, 250, '/image/cloth-shoes/shoes/10007.png', 'Nike Air Force 1 黑白熊猫配色', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Force 1 低帮纯白', 'cloth-shoes', 'Nike', 'Air Force 1 Low', '纯白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["低帮设计","经典纯白","百搭休闲","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 749.00, 849.00, 280, '/image/cloth-shoes/shoes/10008.png', 'Nike Air Force 1 低帮纯白经典', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Force 1 07 经典款', 'cloth-shoes', 'Nike', 'Air Force 1 07', '白蓝', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["经典07款","优质皮革","百搭时尚","舒适耐穿"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 899.00, 200, '/image/cloth-shoes/shoes/10009.png', 'Nike Air Force 1 07 经典款', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Force 1 Shadow', 'cloth-shoes', 'Nike', 'Air Force 1 Shadow', '白粉', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["双层设计","时尚百搭","女性专属","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 999.00, 150, '/image/cloth-shoes/shoes/10010.png', 'Nike Air Force 1 Shadow 时尚百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1));

-- Nike Dunk系列
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Nike Dunk Low 熊猫配色', 'cloth-shoes', 'Nike', 'Dunk Low', '黑白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["熊猫配色","复古设计","潮流百搭","限量发售"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 999.00, 1299.00, 100, '/image/cloth-shoes/shoes/10011.png', 'Nike Dunk Low 熊猫配色，潮流百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Dunk Low 纯白款', 'cloth-shoes', 'Nike', 'Dunk Low', '纯白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["纯白经典","复古设计","百搭时尚","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 120, '/image/cloth-shoes/shoes/10012.png', 'Nike Dunk Low 纯白经典款', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Dunk Low 灰白配色', 'cloth-shoes', 'Nike', 'Dunk Low', '灰白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["灰白配色","复古潮流","百搭休闲","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 80, '/image/cloth-shoes/shoes/10013.png', 'Nike Dunk Low 灰白配色，复古潮流', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Dunk High 高帮黑白', 'cloth-shoes', 'Nike', 'Dunk High', '黑白', '{"类型":"高帮板鞋","尺码":"36-45","鞋面":"皮革"}', '["高帮设计","熊猫配色","复古经典","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1099.00, 1399.00, 60, '/image/cloth-shoes/shoes/10014.png', 'Nike Dunk High 高帮黑白熊猫', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Dunk Low 蓝白配色', 'cloth-shoes', 'Nike', 'Dunk Low', '蓝白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["蓝白配色","清新时尚","复古百搭","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 90, '/image/cloth-shoes/shoes/10015.png', 'Nike Dunk Low 蓝白配色，清新时尚', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1));

-- AJ Air Jordan系列
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('AJ1 黑红禁穿', 'cloth-shoes', 'Air Jordan', 'AJ1 High', '黑红', '{"类型":"高帮篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["禁穿配色","经典复刻","潮流必备","收藏佳品"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1599.00, 1999.00, 50, '/image/cloth-shoes/shoes/10016.png', 'AJ1 黑红禁穿经典复刻', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 芝加哥配色', 'cloth-shoes', 'Air Jordan', 'AJ1 High', '白黑红', '{"类型":"高帮篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["芝加哥配色","经典复刻","潮流之王","限量发售"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1899.00, 2299.00, 30, '/image/cloth-shoes/shoes/10017.png', 'AJ1 芝加哥配色经典复刻', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 皇家蓝', 'cloth-shoes', 'Air Jordan', 'AJ1 High', '黑蓝', '{"类型":"高帮篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["皇家蓝配色","经典设计","潮流必备","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1499.00, 1899.00, 40, '/image/cloth-shoes/shoes/10018.png', 'AJ1 皇家蓝配色经典款', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 低帮黑白', 'cloth-shoes', 'Air Jordan', 'AJ1 Low', '黑白', '{"类型":"低帮篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["低帮设计","熊猫配色","百搭时尚","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 999.00, 1299.00, 80, '/image/cloth-shoes/shoes/10019.png', 'AJ1 低帮黑白熊猫配色', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ1 低帮纯白', 'cloth-shoes', 'Air Jordan', 'AJ1 Low', '纯白', '{"类型":"低帮篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["纯白经典","低帮设计","百搭休闲","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 100, '/image/cloth-shoes/shoes/10020.png', 'AJ1 低帮纯白经典款', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ4 白水泥', 'cloth-shoes', 'Air Jordan', 'AJ4', '白灰', '{"类型":"篮球鞋","尺码":"36-45","鞋面":"皮革网面"}', '["白水泥配色","经典复刻","透气舒适","潮流经典"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1399.00, 1799.00, 60, '/image/cloth-shoes/shoes/10021.png', 'AJ4 白水泥经典复刻', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ4 黑红配色', 'cloth-shoes', 'Air Jordan', 'AJ4', '黑红', '{"类型":"篮球鞋","尺码":"36-45","鞋面":"皮革网面"}', '["黑红配色","经典设计","潮流必备","收藏佳品"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1499.00, 1899.00, 50, '/image/cloth-shoes/shoes/10021.webp', 'AJ4 黑红配色经典款', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ11 康扣', 'cloth-shoes', 'Air Jordan', 'AJ11', '白黑', '{"类型":"篮球鞋","尺码":"36-45","鞋面":"漆皮网面"}', '["康扣配色","经典设计","漆皮材质","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1699.00, 2099.00, 40, '/image/cloth-shoes/shoes/10022.png', 'AJ11 康扣经典配色', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ11 伽马蓝', 'cloth-shoes', 'Air Jordan', 'AJ11', '蓝黑', '{"类型":"篮球鞋","尺码":"36-45","鞋面":"漆皮网面"}', '["伽马蓝配色","经典设计","潮流时尚","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1599.00, 1999.00, 35, '/image/cloth-shoes/shoes/10023.png', 'AJ11 伽马蓝配色经典款', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ3 白水泥', 'cloth-shoes', 'Air Jordan', 'AJ3', '白灰', '{"类型":"篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["白水泥配色","经典复刻","爆裂纹设计","潮流经典"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1299.00, 1699.00, 55, '/image/cloth-shoes/shoes/10024.png', 'AJ3 白水泥经典复刻', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1)),
('AJ3 黑水泥', 'cloth-shoes', 'Air Jordan', 'AJ3', '黑灰', '{"类型":"篮球鞋","尺码":"36-45","鞋面":"皮革"}', '["黑水泥配色","爆裂纹设计","经典复刻","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1399.00, 1799.00, 45, '/image/cloth-shoes/shoes/10025.png', 'AJ3 黑水泥经典款', 1, (SELECT id FROM shops WHERE folder = 'aj' LIMIT 1));

-- Nike其他系列
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Nike Blazer Mid 77 经典', 'cloth-shoes', 'Nike', 'Blazer Mid 77', '白黑', '{"类型":"高帮板鞋","尺码":"36-45","鞋面":"皮革"}', '["复古设计","经典百搭","高帮造型","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 699.00, 899.00, 150, '/image/cloth-shoes/shoes/10026.png', 'Nike Blazer Mid 77 经典复古', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Blazer Low 77 经典', 'cloth-shoes', 'Nike', 'Blazer Low 77', '纯白', '{"类型":"低帮板鞋","尺码":"36-45","鞋面":"皮革"}', '["低帮设计","纯白经典","百搭休闲","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 599.00, 799.00, 180, '/image/cloth-shoes/shoes/10027.png', 'Nike Blazer Low 77 纯白经典', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Cortez 阿甘鞋', 'cloth-shoes', 'Nike', 'Cortez', '白红蓝', '{"类型":"休闲鞋","尺码":"36-45","鞋面":"皮革"}', '["阿甘鞋经典","复古设计","轻盈舒适","百搭时尚"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 599.00, 799.00, 200, '/image/cloth-shoes/shoes/10028.png', 'Nike Cortez 阿甘鞋经典款', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike SB Dunk Low', 'cloth-shoes', 'Nike', 'SB Dunk Low', '白蓝', '{"类型":"滑板鞋","尺码":"36-45","鞋面":"皮革"}', '["滑板鞋设计","厚底缓震","潮流百搭","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 999.00, 1299.00, 80, '/image/cloth-shoes/shoes/10028.webp', 'Nike SB Dunk Low 滑板鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Huarache', 'cloth-shoes', 'Nike', 'Air Huarache', '白蓝', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["华莱士经典","透气网面","气垫缓震","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 999.00, 120, '/image/cloth-shoes/shoes/10029.jpeg', 'Nike Air Huarache 华莱士', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Pegasus 40 跑步鞋', 'cloth-shoes', 'Nike', 'Pegasus 40', '白黑', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["专业跑步","气垫缓震","透气轻盈","舒适耐穿"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 150, '/image/cloth-shoes/shoes/10029.png', 'Nike Pegasus 40 专业跑步鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike React Infinity', 'cloth-shoes', 'Nike', 'React Infinity', '白灰', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["React缓震","专业跑步","舒适轻盈","减震保护"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1199.00, 1499.00, 100, '/image/cloth-shoes/shoes/10030.png', 'Nike React Infinity 专业跑步鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Zoom Fly 5', 'cloth-shoes', 'Nike', 'Zoom Fly 5', '白橙', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["Zoom气垫","专业竞速","轻量设计","舒适缓震"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1099.00, 1399.00, 80, '/image/cloth-shoes/shoes/10031.png', 'Nike Zoom Fly 5 专业竞速跑鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Free Run 5.0', 'cloth-shoes', 'Nike', 'Free Run 5.0', '黑灰', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["赤足感受","灵活轻便","透气舒适","日常训练"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 999.00, 130, '/image/cloth-shoes/shoes/10032.png', 'Nike Free Run 5.0 赤足跑步鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Presto', 'cloth-shoes', 'Nike', 'Air Presto', '黑橙', '{"类型":"休闲鞋","尺码":"36-45","鞋面":"网面"}', '["套脚设计","轻盈透气","舒适百搭","潮流之选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 699.00, 899.00, 110, '/image/cloth-shoes/shoes/10033.jpeg', 'Nike Air Presto 轻盈休闲鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Zoom Structure', 'cloth-shoes', 'Nike', 'Air Zoom Structure', '白蓝', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["稳定支撑","Zoom气垫","透气舒适","专业跑步"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 90, '/image/cloth-shoes/shoes/10034.png', 'Nike Air Zoom Structure 稳定跑鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Winflo 10', 'cloth-shoes', 'Nike', 'Winflo 10', '白红', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["气垫缓震","透气轻盈","性价比高","日常跑步"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 699.00, 899.00, 160, '/image/cloth-shoes/shoes/10035.png', 'Nike Winflo 10 性价比跑鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Revolution 6', 'cloth-shoes', 'Nike', 'Revolution 6', '黑灰', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["入门跑步","轻便舒适","透气网面","性价比高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 499.00, 699.00, 200, '/image/cloth-shoes/shoes/10036.png', 'Nike Revolution 6 入门跑鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Monarch IV', 'cloth-shoes', 'Nike', 'Monarch IV', '白蓝', '{"类型":"训练鞋","尺码":"36-45","鞋面":"皮革"}', '["训练经典","耐磨大底","舒适缓震","百搭休闲"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 599.00, 799.00, 140, '/image/cloth-shoes/shoes/10037.webp', 'Nike Monarch IV 训练鞋经典', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max Plus', 'cloth-shoes', 'Nike', 'Air Max Plus', '黑黄', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["经典大气垫","复古设计","潮流百搭","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1199.00, 1499.00, 70, '/image/cloth-shoes/shoes/10038.png', 'Nike Air Max Plus 经典大气垫', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max Dia', 'cloth-shoes', 'Nike', 'Air Max Dia', '白粉', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["女性专属","气垫缓震","时尚百搭","舒适轻盈"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 799.00, 999.00, 100, '/image/cloth-shoes/shoes/10039.png', 'Nike Air Max Dia 女性专属', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max Verona', 'cloth-shoes', 'Nike', 'Air Max Verona', '白黑', '{"类型":"运动鞋","尺码":"36-45","鞋面":"皮革"}', '["时尚设计","气垫缓震","百搭休闲","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 899.00, 1099.00, 85, '/image/cloth-shoes/shoes/10040.png', 'Nike Air Max Verona 时尚运动鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max SC', 'cloth-shoes', 'Nike', 'Air Max SC', '白灰', '{"类型":"运动鞋","尺码":"36-45","鞋面":"皮革网面"}', '["经典设计","气垫缓震","百搭休闲","性价比高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 699.00, 899.00, 170, '/image/cloth-shoes/shoes/10041.png', 'Nike Air Max SC 经典百搭', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max Excee', 'cloth-shoes', 'Nike', 'Air Max Excee', '白蓝', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["复古设计","气垫缓震","时尚百搭","舒适耐穿"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 749.00, 949.00, 130, '/image/cloth-shoes/shoes/10042.png', 'Nike Air Max Excee 复古运动鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max SYSTM', 'cloth-shoes', 'Nike', 'Air Max SYSTM', '黑灰', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["系统设计","气垫缓震","潮流百搭","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 699.00, 899.00, 110, '/image/cloth-shoes/shoes/10043.png', 'Nike Air Max SYSTM 系统运动鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Court Vision', 'cloth-shoes', 'Nike', 'Court Vision', '纯白', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["经典设计","纯白百搭","休闲时尚","性价比高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 499.00, 699.00, 220, '/image/cloth-shoes/shoes/10044.png', 'Nike Court Vision 经典板鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Court Legacy', 'cloth-shoes', 'Nike', 'Court Legacy', '白绿', '{"类型":"板鞋","尺码":"36-45","鞋面":"皮革"}', '["复古网球鞋","经典设计","百搭休闲","舒适耐穿"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 449.00, 599.00, 180, '/image/cloth-shoes/shoes/10045.png', 'Nike Court Legacy 复古网球鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Downshifter 12', 'cloth-shoes', 'Nike', 'Downshifter 12', '黑蓝', '{"类型":"跑步鞋","尺码":"36-45","鞋面":"网面"}', '["入门跑鞋","轻便舒适","透气网面","性价比高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 449.00, 599.00, 190, '/image/cloth-shoes/shoes/10046.png', 'Nike Downshifter 12 入门跑鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Tanjun 休闲鞋', 'cloth-shoes', 'Nike', 'Tanjun', '纯黑', '{"类型":"休闲鞋","尺码":"36-45","鞋面":"网面"}', '["简约设计","轻盈舒适","百搭休闲","性价比高"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 499.00, 699.00, 250, '/image/cloth-shoes/shoes/10047.png', 'Nike Tanjun 简约休闲鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Benassis 拖鞋', 'cloth-shoes', 'Nike', 'Benassis', '黑白', '{"类型":"拖鞋","尺码":"36-45","鞋面":"合成材料"}', '["舒适拖鞋","柔软鞋垫","居家出行","轻便易穿"]', '["拖鞋 x1","鞋盒 x1"]', 299.00, 399.00, 300, '/image/cloth-shoes/shoes/10048.png', 'Nike Benassis 舒适拖鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Victori One 拖鞋', 'cloth-shoes', 'Nike', 'Victori One', '黑橙', '{"类型":"拖鞋","尺码":"36-45","鞋面":"合成材料"}', '["运动拖鞋","舒适缓震","轻便易穿","居家必备"]', '["拖鞋 x1","鞋盒 x1"]', 249.00, 349.00, 280, '/image/cloth-shoes/shoes/10049.png', 'Nike Victori One 运动拖鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Offcourt 拖鞋', 'cloth-shoes', 'Nike', 'Offcourt', '白蓝', '{"类型":"拖鞋","尺码":"36-45","鞋面":"合成材料"}', '["休闲拖鞋","柔软舒适","轻便易穿","居家出行"]', '["拖鞋 x1","鞋盒 x1"]', 279.00, 379.00, 260, '/image/cloth-shoes/shoes/10050.png', 'Nike Offcourt 休闲拖鞋', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 2090', 'cloth-shoes', 'Nike', 'Air Max 2090', '白透明', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面透明材质"}', '["未来感设计","气垫缓震","透明材质","潮流前沿"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1099.00, 1399.00, 65, '/image/cloth-shoes/shoes/10051.png', 'Nike Air Max 2090 未来感设计', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air Max 720', 'cloth-shoes', 'Nike', 'Air Max 720', '黑彩虹', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["720度气垫","极致缓震","时尚设计","潮流必备"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1299.00, 1599.00, 55, '/image/cloth-shoes/shoes/10052.png', 'Nike Air Max 720 极致缓震', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air VaporMax', 'cloth-shoes', 'Nike', 'Air VaporMax', '纯白', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面"}', '["VaporMax气垫","全掌气垫","轻盈舒适","潮流前沿"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1499.00, 1899.00, 45, '/image/cloth-shoes/shoes/10053.png', 'Nike Air VaporMax 全掌气垫', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike Air VaporMax Plus', 'cloth-shoes', 'Nike', 'Air VaporMax Plus', '黑红', '{"类型":"运动鞋","尺码":"36-45","鞋面":"网面皮革"}', '["VaporMax气垫","Plus升级","潮流设计","品质保证"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1599.00, 1999.00, 40, '/image/cloth-shoes/shoes/10054.png', 'Nike Air VaporMax Plus 升级款', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1)),
('Nike ZoomX Vaporfly', 'cloth-shoes', 'Nike', 'ZoomX Vaporfly', '白绿', '{"类型":"竞速跑鞋","尺码":"36-45","鞋面":"网面"}', '["ZoomX科技","专业竞速","碳板加持","马拉松首选"]', '["鞋子 x1","鞋盒 x1","防尘袋 x1"]', 1899.00, 2299.00, 35, '/image/cloth-shoes/shoes/10055.webp', 'Nike ZoomX Vaporfly 专业竞速', 1, (SELECT id FROM shops WHERE folder = 'nike' LIMIT 1));

-- ============================================================
-- 4. 箱包商品 (奢侈品) - category = 'cloth-shoes'
-- ============================================================

-- LV 路易威登
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('LV Neverfull 手提包', 'cloth-shoes', 'Louis Vuitton', 'Neverfull MM', '棕色老花', '{"类型":"手提包","尺寸":"31x28x14cm","材质":"老花帆布"}', '["经典老花设计","大容量实用","可调节肩带","时尚百搭"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 12999.00, 15999.00, 20, '/image/cloth-shoes/bag/10001.webp', 'LV Neverfull 经典老花手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('LV Speedy 经典手提包', 'cloth-shoes', 'Louis Vuitton', 'Speedy 30', '棕色老花', '{"类型":"手提包","尺寸":"30x21x17cm","材质":"老花帆布"}', '["经典Speedy设计","百搭时尚","品质保证","奢华之选"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 11999.00, 14999.00, 15, '/image/cloth-shoes/bag/10002.webp', 'LV Speedy 30 经典老花手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('LV Alma 手提包', 'cloth-shoes', 'Louis Vuitton', 'Alma BB', '黑色', '{"类型":"手提包","尺寸":"23x17x11cm","材质":"Epi皮革"}', '["经典Alma设计","Epi皮革","时尚百搭","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 13999.00, 16999.00, 12, '/image/cloth-shoes/bag/10003.webp', 'LV Alma BB 经典手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('LV Pochette 斜挎包', 'cloth-shoes', 'Louis Vuitton', 'Pochette Metis', '棕色老花', '{"类型":"斜挎包","尺寸":"25x19x8cm","材质":"老花帆布"}', '["经典老花设计","时尚百搭","实用容量","潮流必备"]', '["斜挎包 x1","防尘袋 x1","说明书 x1"]', 15999.00, 18999.00, 10, '/image/cloth-shoes/bag/10004.webp', 'LV Pochette Metis 经典斜挎包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('LV Onthego 手提包', 'cloth-shoes', 'Louis Vuitton', 'Onthego GM', '棕色老花', '{"类型":"手提包","尺寸":"40x30x16cm","材质":"老花帆布"}', '["大容量设计","经典老花","时尚百搭","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 18999.00, 22999.00, 8, '/image/cloth-shoes/bag/10005.webp', 'LV Onthego GM 大容量手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1));

-- Gucci 古驰
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Gucci Marmont 链条包', 'cloth-shoes', 'Gucci', 'GG Marmont', '黑色', '{"类型":"链条包","尺寸":"26x15x7cm","材质":"皮革"}', '["经典Marmont设计","双G标志","时尚百搭","品质保证"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 15999.00, 19999.00, 18, '/image/cloth-shoes/bag/10006.webp', 'Gucci Marmont 经典链条包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Gucci Dionysus 酒神包', 'cloth-shoes', 'Gucci', 'Dionysus', '黑色', '{"类型":"链条包","尺寸":"28x17x9cm","材质":"皮革"}', '["酒神经典设计","双虎头扣","时尚百搭","奢华之选"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 18999.00, 22999.00, 12, '/image/cloth-shoes/bag/10007.webp', 'Gucci Dionysus 酒神包经典', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Gucci Horsebit 马衔扣包', 'cloth-shoes', 'Gucci', 'Horsebit 1955', '黑色', '{"类型":"手提包","尺寸":"26x16x6cm","材质":"皮革"}', '["经典马衔扣设计","复古时尚","品质保证","潮流必备"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 16999.00, 20999.00, 10, '/image/cloth-shoes/bag/10008.webp', 'Gucci Horsebit 1955 经典马衔扣包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Gucci Jackie 1961', 'cloth-shoes', 'Gucci', 'Jackie 1961', '棕色', '{"类型":"手提包","尺寸":"28x18x8cm","材质":"皮革"}', '["经典Jackie设计","复古时尚","百搭百搭","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 17999.00, 21999.00, 8, '/image/cloth-shoes/bag/10009.webp', 'Gucci Jackie 1961 经典手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Gucci Ophidia 斜挎包', 'cloth-shoes', 'Gucci', 'Ophidia', '棕绿红', '{"类型":"斜挎包","尺寸":"25x15x6cm","材质":"老花帆布"}', '["经典老花设计","红绿织带","时尚百搭","潮流必备"]', '["斜挎包 x1","防尘袋 x1","说明书 x1"]', 9999.00, 12999.00, 20, '/image/cloth-shoes/bag/10010.webp', 'Gucci Ophidia 经典斜挎包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1));

-- Hermes 爱马仕
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Hermes Birkin 30', 'cloth-shoes', 'Hermes', 'Birkin 30', '黑色', '{"类型":"手提包","尺寸":"30x22x16cm","材质":"Togo皮革"}', '["经典Birkin设计","顶级皮革","奢华之选","收藏佳品"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 89999.00, 109999.00, 5, '/image/cloth-shoes/bag/10011.webp', 'Hermes Birkin 30 经典手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Hermes Kelly 25', 'cloth-shoes', 'Hermes', 'Kelly 25', '橙色', '{"类型":"手提包","尺寸":"25x17x10cm","材质":"Epsom皮革"}', '["经典Kelly设计","顶级皮革","时尚百搭","奢华之选"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 79999.00, 99999.00, 6, '/image/cloth-shoes/bag/10012.webp', 'Hermes Kelly 25 经典手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Hermes Constance 24', 'cloth-shoes', 'Hermes', 'Constance 24', '黑色', '{"类型":"斜挎包","尺寸":"24x15x5cm","材质":"Epsom皮革"}', '["经典Constance设计","H标志扣","时尚百搭","品质保证"]', '["斜挎包 x1","防尘袋 x1","说明书 x1"]', 59999.00, 79999.00, 8, '/image/cloth-shoes/bag/10013.webp', 'Hermes Constance 24 经典斜挎包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Hermes Lindy 26', 'cloth-shoes', 'Hermes', 'Lindy 26', '蓝色', '{"类型":"手提包","尺寸":"26x18x13cm","材质":"Clemence皮革"}', '["经典Lindy设计","双肩带设计","时尚百搭","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 49999.00, 69999.00, 10, '/image/cloth-shoes/bag/10014.webp', 'Hermes Lindy 26 经典手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Hermes Picotin 18', 'cloth-shoes', 'Hermes', 'Picotin 18', '橙色', '{"类型":"手提包","尺寸":"18x16x11cm","材质":"Clemence皮革"}', '["经典Picotin设计","水桶造型","时尚百搭","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 39999.00, 49999.00, 12, '/image/cloth-shoes/bag/10015.webp', 'Hermes Picotin 18 经典手提包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1));

-- Chanel 香奈儿
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Chanel Classic Flap 经典翻盖包', 'cloth-shoes', 'Chanel', 'Classic Flap', '黑色', '{"类型":"链条包","尺寸":"25x16x7cm","材质":"羊皮革"}', '["经典翻盖设计","双C标志","时尚百搭","奢华之选"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 59999.00, 79999.00, 10, '/image/cloth-shoes/bag/10016.webp', 'Chanel Classic Flap 经典翻盖包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Chanel Boy 香奈儿男孩包', 'cloth-shoes', 'Chanel', 'Boy Chanel', '黑色', '{"类型":"链条包","尺寸":"25x15x6cm","材质":"小牛皮"}', '["经典Boy设计","时尚百搭","品质保证","潮流必备"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 49999.00, 69999.00, 12, '/image/cloth-shoes/bag/10017.webp', 'Chanel Boy 经典男孩包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Chanel 2.55 经典款', 'cloth-shoes', 'Chanel', '2.55 Reissue', '黑色', '{"类型":"链条包","尺寸":"25x16x7cm","材质":"小牛皮"}', '["经典2.55设计","复古时尚","品质保证","收藏佳品"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 69999.00, 89999.00, 8, '/image/cloth-shoes/bag/10018.webp', 'Chanel 2.55 经典款链条包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Chanel Gabrielle 流浪包', 'cloth-shoes', 'Chanel', 'Gabrielle', '黑色', '{"类型":"链条包","尺寸":"27x17x10cm","材质":"小牛皮"}', '["经典Gabrielle设计","时尚百搭","品质保证","潮流必备"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 54999.00, 74999.00, 10, '/image/cloth-shoes/bag/10019.webp', 'Chanel Gabrielle 经典流浪包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Chanel WOC 链条包', 'cloth-shoes', 'Chanel', 'WOC', '黑色', '{"类型":"链条包","尺寸":"20x12x4cm","材质":"羊皮革"}', '["经典WOC设计","小巧精致","时尚百搭","品质保证"]', '["链条包 x1","防尘袋 x1","说明书 x1"]', 29999.00, 39999.00, 15, '/image/cloth-shoes/bag/10020.webp', 'Chanel WOC 经典链条包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1));

-- 其他奢侈品品牌
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('Dior Lady Dior 戴妃包', 'cloth-shoes', 'Dior', 'Lady Dior', '黑色', '{"类型":"手提包","尺寸":"24x20x11cm","材质":"羊皮革"}', '["经典戴妃包设计","藤格纹刺绣","时尚百搭","奢华之选"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 39999.00, 49999.00, 12, '/image/cloth-shoes/bag/10021.png', 'Dior Lady Dior 经典戴妃包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Prada Galleria 杀手包', 'cloth-shoes', 'Prada', 'Galleria', '黑色', '{"类型":"手提包","尺寸":"25x17x10cm","材质":"Saffiano皮革"}', '["经典杀手包设计","Saffiano皮革","时尚百搭","品质保证"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 22999.00, 27999.00, 18, '/image/cloth-shoes/bag/10022.png', 'Prada Galleria 经典杀手包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1)),
('Celine Luggage 笑脸包', 'cloth-shoes', 'Celine', 'Luggage', '黑色', '{"类型":"手提包","尺寸":"30x25x15cm","材质":"小牛皮"}', '["经典笑脸包设计","时尚百搭","品质保证","潮流必备"]', '["手提包 x1","防尘袋 x1","说明书 x1"]', 25999.00, 31999.00, 15, '/image/cloth-shoes/bag/10023.png', 'Celine Luggage 经典笑脸包', 1, (SELECT id FROM shops WHERE folder = 'luxury' LIMIT 1));

-- ============================================================
-- 5. 商品多图数据
-- ============================================================

-- Nike Air Max 270
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Max 270 黑白配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10001.png', 1);

-- Nike Air Max 270 白红
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Max 270 白红配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10002.png', 1);

-- Nike Air Max 90
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Max 90 经典复古' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10003.png', 1);

-- Nike Air Max 97
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Max 97 银子弹' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10004.png', 1);

-- Nike Air Max 1
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Max 1 经典款' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10005.png', 1);

-- Nike Air Force 1 纯白
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Force 1 纯白经典' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10006.png', 1);

-- Nike Air Force 1 熊猫
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Force 1 黑白熊猫' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10007.png', 1);

-- Nike Air Force 1 低帮
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Force 1 低帮纯白' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10008.png', 1);

-- Nike Air Force 1 07
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Force 1 07 经典款' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10009.png', 1);

-- Nike Air Force 1 Shadow
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Air Force 1 Shadow' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10010.png', 1);

-- Nike Dunk Low 熊猫
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Dunk Low 熊猫配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10011.png', 1);

-- Nike Dunk Low 纯白
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Dunk Low 纯白款' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10012.png', 1);

-- Nike Dunk Low 灰白
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Dunk Low 灰白配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10013.png', 1);

-- Nike Dunk High
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Dunk High 高帮黑白' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10014.png', 1);

-- Nike Dunk Low 蓝白
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Nike Dunk Low 蓝白配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10015.png', 1);

-- AJ1 黑红
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ1 黑红禁穿' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10016.png', 1);

-- AJ1 芝加哥
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ1 芝加哥配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10017.png', 1);

-- AJ1 皇家蓝
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ1 皇家蓝' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10018.png', 1);

-- AJ1 低帮黑白
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ1 低帮黑白' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10019.png', 1);

-- AJ1 低帮纯白
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ1 低帮纯白' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10020.png', 1);

-- AJ4 白水泥
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ4 白水泥' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10021.png', 1);

-- AJ4 黑红
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ4 黑红配色' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10021.webp', 1);

-- AJ11 康扣
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ11 康扣' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10022.png', 1);

-- AJ11 伽马蓝
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ11 伽马蓝' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10023.png', 1);

-- AJ3 白水泥
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ3 白水泥' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10024.png', 1);

-- AJ3 黑水泥
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'AJ3 黑水泥' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/shoes/10025.png', 1);

-- LV Neverfull
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'LV Neverfull 手提包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10001.webp', 1);

-- LV Speedy
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'LV Speedy 经典手提包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10002.webp', 1);

-- LV Alma
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'LV Alma 手提包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10003.webp', 1);

-- LV Pochette
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'LV Pochette 斜挎包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10004.webp', 1);

-- LV Onthego
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'LV Onthego 手提包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10005.webp', 1);

-- Gucci Marmont
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Gucci Marmont 链条包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10006.webp', 1);

-- Gucci Dionysus
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Gucci Dionysus 酒神包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10007.webp', 1);

-- Gucci Horsebit
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Gucci Horsebit 马衔扣包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10008.webp', 1);

-- Gucci Jackie
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Gucci Jackie 1961' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10009.webp', 1);

-- Gucci Ophidia
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Gucci Ophidia 斜挎包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10010.webp', 1);

-- Hermes Birkin
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Hermes Birkin 30' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10011.webp', 1);

-- Hermes Kelly
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Hermes Kelly 25' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10012.webp', 1);

-- Hermes Constance
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Hermes Constance 24' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10013.webp', 1);

-- Hermes Lindy
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Hermes Lindy 26' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10014.webp', 1);

-- Hermes Picotin
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Hermes Picotin 18' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10015.webp', 1);

-- Chanel Classic Flap
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Chanel Classic Flap 经典翻盖包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10016.webp', 1);

-- Chanel Boy
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Chanel Boy 香奈儿男孩包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10017.webp', 1);

-- Chanel 2.55
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Chanel 2.55 经典款' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10018.webp', 1);

-- Chanel Gabrielle
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Chanel Gabrielle 流浪包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10019.webp', 1);

-- Chanel WOC
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Chanel WOC 链条包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10020.webp', 1);

-- Dior Lady Dior
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Dior Lady Dior 戴妃包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10021.png', 1);

-- Prada Galleria
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Prada Galleria 杀手包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10022.png', 1);

-- Celine Luggage
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = 'Celine Luggage 笑脸包' AND category = 'cloth-shoes' LIMIT 1), '/image/cloth-shoes/bag/10023.png', 1);
