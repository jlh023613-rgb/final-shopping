-- ============================================================
-- 食品生鲜商品初始化脚本
-- 图片路径：/image/food/辣条/ 和 /image/food/薯片/
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ============================================================
-- 1. 清空食品生鲜相关数据
-- ============================================================
DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE category = 'food');
DELETE FROM products WHERE category = 'food';

-- ============================================================
-- 2. 添加食品生鲜相关店铺
-- ============================================================
INSERT IGNORE INTO shops (name, folder, description, sort_order) VALUES
('零食小铺旗舰店', 'lingshi1', '零食小铺官方店铺，美味零食', 40),
('美味零食旗舰店', 'lingshi2', '美味零食官方店铺，品质保证', 41),
('馋嘴猫零食店', 'lingshi3', '馋嘴猫零食官方店铺', 42),
('吃货天堂旗舰店', 'lingshi4', '吃货天堂官方店铺，精选零食', 43);

-- ============================================================
-- 3. 食品生鲜商品数据 (category = 'food')
-- ============================================================

-- 辣条类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('香辣辣条 100g', 'food', '零食品牌', '香辣味', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["香辣可口","Q弹有嚼劲","独立包装","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10001.png', '香辣辣条，Q弹有嚼劲', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('麻辣辣条 100g', 'food', '零食品牌', '麻辣味', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"麻辣"}', '["麻辣鲜香","口感Q弹","独立包装","开胃解馋"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 1000, '/image/food/辣条/10002.png', '麻辣辣条，麻辣鲜香', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('卫龙辣条 106g', 'food', '零食品牌', '经典味', '红色', '{"类型":"辣条","规格":"106g/袋","口味":"经典"}', '["经典口味","甜辣适中","Q弹爽滑","国民零食"]', '["辣条 106g","包装袋 x1"]', 6.00, 9.00, 800, '/image/food/辣条/10003.png', '卫龙辣条，经典口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('大刀肉辣条 200g', 'food', '零食品牌', '大刀肉', '红棕色', '{"类型":"辣条","规格":"200g/袋","口味":"香辣"}', '["大刀肉造型","香辣过瘾","肉质厚实","满足感强"]', '["辣条 200g","包装袋 x1"]', 8.00, 12.00, 600, '/image/food/辣条/10004.png', '大刀肉辣条，香辣过瘾', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('亲嘴烧辣条 100g', 'food', '零食品牌', '亲嘴烧', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["小片装设计","香辣够味","方便食用","办公室零食"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 900, '/image/food/辣条/10005.png', '亲嘴烧辣条，香辣够味', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('魔芋爽辣条 150g', 'food', '零食品牌', '魔芋爽', '红棕色', '{"类型":"辣条","规格":"150g/袋","口味":"香辣"}', '["魔芋制作","低卡健康","爽脆可口","减肥也能吃"]', '["辣条 150g","包装袋 x1"]', 9.00, 13.00, 700, '/image/food/辣条/10006.png', '魔芋爽辣条，低卡健康', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('辣条大礼包 500g', 'food', '零食品牌', '混合装', '多色', '{"类型":"辣条","规格":"500g/袋","口味":"混合"}', '["多种口味混合","量大实惠","分享装","聚会必备"]', '["辣条 500g","包装袋 x1"]', 18.00, 25.00, 400, '/image/food/辣条/10007.png', '辣条大礼包，多种口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('豆皮辣条 100g', 'food', '零食品牌', '豆皮味', '红棕色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["豆皮制作","层次丰富","香辣入味","口感独特"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 800, '/image/food/辣条/10008.png', '豆皮辣条，层次丰富', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('素牛筋辣条 120g', 'food', '零食品牌', '素牛筋', '红棕色', '{"类型":"辣条","规格":"120g/袋","口味":"香辣"}', '["素牛筋口感","Q弹有嚼劲","香辣可口","素食首选"]', '["辣条 120g","包装袋 x1"]', 6.00, 10.00, 700, '/image/food/辣条/10009.png', '素牛筋辣条，Q弹有嚼劲', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('香辣棒辣条 100g', 'food', '零食品牌', '香辣棒', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["棒状设计","方便食用","香辣过瘾","童年回忆"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 900, '/image/food/辣条/10010.png', '香辣棒辣条，童年回忆', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('臭干子辣条 100g', 'food', '零食品牌', '臭干子', '深棕色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["臭干子风味","闻着臭吃着香","独特口感","重口味最爱"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 600, '/image/food/辣条/10011.png', '臭干子辣条，独特风味', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('面筋辣条 150g', 'food', '零食品牌', '面筋味', '红棕色', '{"类型":"辣条","规格":"150g/袋","口味":"香辣"}', '["面筋制作","吸汁入味","香辣可口","口感丰富"]', '["辣条 150g","包装袋 x1"]', 7.00, 10.00, 700, '/image/food/辣条/10012.png', '面筋辣条，吸汁入味', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('辣片辣条 100g', 'food', '零食品牌', '辣片味', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["薄片设计","香辣入味","方便撕着吃","追剧必备"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 800, '/image/food/辣条/10013.png', '辣片辣条，香辣入味', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('香辣丝辣条 100g', 'food', '零食品牌', '香辣丝', '红色', '{"类型":"辣条","规格":"100g/袋","口味":"香辣"}', '["丝状设计","香辣爽口","方便食用","开胃解馋"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 900, '/image/food/辣条/10014.jpeg', '香辣丝辣条，香辣爽口', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('麻辣豆干辣条 120g', 'food', '零食品牌', '麻辣豆干', '红棕色', '{"类型":"辣条","规格":"120g/袋","口味":"麻辣"}', '["豆干制作","麻辣鲜香","口感扎实","下饭神器"]', '["辣条 120g","包装袋 x1"]', 7.00, 10.00, 600, '/image/food/辣条/10015.png', '麻辣豆干辣条，麻辣鲜香', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('辣条组合装 300g', 'food', '零食品牌', '组合装', '多色', '{"类型":"辣条","规格":"300g/袋","口味":"混合"}', '["多种口味组合","性价比高","尝鲜首选","送礼佳品"]', '["辣条 300g","包装袋 x1"]', 12.00, 18.00, 500, '/image/food/辣条/10016.png', '辣条组合装，多种口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('手撕辣条 150g', 'food', '零食品牌', '手撕味', '红棕色', '{"类型":"辣条","规格":"150g/袋","口味":"香辣"}', '["手撕设计","香辣过瘾","肉质厚实","满足感强"]', '["辣条 150g","包装袋 x1"]', 8.00, 12.00, 700, '/image/food/辣条/10017.png', '手撕辣条，香辣过瘾', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('蒜香辣条 100g', 'food', '零食品牌', '蒜香味', '浅棕色', '{"类型":"辣条","规格":"100g/袋","口味":"蒜香"}', '["蒜香浓郁","微辣可口","独特风味","蒜香爱好者必选"]', '["辣条 100g","包装袋 x1"]', 5.00, 8.00, 800, '/image/food/辣条/10018.png', '蒜香辣条，蒜香浓郁', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1));

-- 薯片类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('原味薯片 70g', 'food', '零食品牌', '原味', '黄色', '{"类型":"薯片","规格":"70g/袋","口味":"原味"}', '["经典原味","香脆可口","薄脆爽口","追剧必备"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10014.png', '原味薯片，香脆可口', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('番茄味薯片 70g', 'food', '零食品牌', '番茄味', '红色', '{"类型":"薯片","规格":"70g/袋","口味":"番茄"}', '["番茄风味","酸甜可口","薄脆爽口","老少皆宜"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10019.png', '番茄味薯片，酸甜可口', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('烧烤味薯片 70g', 'food', '零食品牌', '烧烤味', '棕色', '{"类型":"薯片","规格":"70g/袋","口味":"烧烤"}', '["烧烤风味","香浓美味","薄脆爽口","聚会必备"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10020.png', '烧烤味薯片，香浓美味', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('黄瓜味薯片 70g', 'food', '零食品牌', '黄瓜味', '绿色', '{"类型":"薯片","规格":"70g/袋","口味":"黄瓜"}', '["黄瓜清香","清新爽口","薄脆爽口","夏日必备"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10021.webp', '黄瓜味薯片，清新爽口', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('香辣味薯片 70g', 'food', '零食品牌', '香辣味', '红色', '{"类型":"薯片","规格":"70g/袋","口味":"香辣"}', '["香辣过瘾","刺激味蕾","薄脆爽口","辣味爱好者必选"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10022.png', '香辣味薯片，香辣过瘾', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('椒盐味薯片 70g', 'food', '零食品牌', '椒盐味', '浅黄色', '{"类型":"薯片","规格":"70g/袋","口味":"椒盐"}', '["椒盐风味","咸香可口","薄脆爽口","经典口味"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10023.png', '椒盐味薯片，咸香可口', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('芝士味薯片 70g', 'food', '零食品牌', '芝士味', '黄色', '{"类型":"薯片","规格":"70g/袋","口味":"芝士"}', '["芝士浓郁","奶香四溢","薄脆爽口","芝士控必选"]', '["薯片 70g","包装袋 x1"]', 9.00, 13.00, 700, '/image/food/薯片/10024.webp', '芝士味薯片，芝士浓郁', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('海苔味薯片 70g', 'food', '零食品牌', '海苔味', '绿色', '{"类型":"薯片","规格":"70g/袋","口味":"海苔"}', '["海苔清香","鲜美可口","薄脆爽口","海鲜风味"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10025.png', '海苔味薯片，海苔清香', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('薯片大礼包 300g', 'food', '零食品牌', '混合装', '多色', '{"类型":"薯片","规格":"300g/袋","口味":"混合"}', '["多种口味混合","量大实惠","分享装","聚会必备"]', '["薯片 300g","包装袋 x1"]', 25.00, 35.00, 400, '/image/food/薯片/10026.png', '薯片大礼包，多种口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('蜂蜜黄油薯片 70g', 'food', '零食品牌', '蜂蜜黄油', '金黄色', '{"类型":"薯片","规格":"70g/袋","口味":"蜂蜜黄油"}', '["蜂蜜黄油风味","甜咸交织","薄脆爽口","网红爆款"]', '["薯片 70g","包装袋 x1"]', 10.00, 15.00, 600, '/image/food/薯片/10027.png', '蜂蜜黄油薯片，甜咸交织', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('薯条形状薯片 100g', 'food', '零食品牌', '薯条形', '黄色', '{"类型":"薯片","规格":"100g/袋","口味":"原味"}', '["薯条造型","趣味十足","香脆可口","儿童最爱"]', '["薯片 100g","包装袋 x1"]', 10.00, 15.00, 600, '/image/food/薯片/10028.png', '薯条形状薯片，趣味十足', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('波浪薯片 70g', 'food', '零食品牌', '波浪形', '黄色', '{"类型":"薯片","规格":"70g/袋","口味":"原味"}', '["波浪造型","口感更丰富","香脆可口","造型独特"]', '["薯片 70g","包装袋 x1"]', 9.00, 13.00, 700, '/image/food/薯片/10029.png', '波浪薯片，口感丰富', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('洋葱味薯片 70g', 'food', '零食品牌', '洋葱味', '浅黄色', '{"类型":"薯片","规格":"70g/袋","口味":"洋葱"}', '["洋葱风味","香气扑鼻","薄脆爽口","独特口味"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10030.png', '洋葱味薯片，香气扑鼻', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('黑椒味薯片 70g', 'food', '零食品牌', '黑椒味', '深棕色', '{"类型":"薯片","规格":"70g/袋","口味":"黑椒"}', '["黑椒风味","辛辣可口","薄脆爽口","黑椒爱好者必选"]', '["薯片 70g","包装袋 x1"]', 8.00, 12.00, 800, '/image/food/薯片/10031.png', '黑椒味薯片，辛辣可口', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('薯片组合装 200g', 'food', '零食品牌', '组合装', '多色', '{"类型":"薯片","规格":"200g/袋","口味":"混合"}', '["多种口味组合","性价比高","尝鲜首选","送礼佳品"]', '["薯片 200g","包装袋 x1"]', 18.00, 25.00, 500, '/image/food/薯片/10032.png', '薯片组合装，多种口味', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1)),
('麻辣小龙虾味薯片 70g', 'food', '零食品牌', '小龙虾味', '红色', '{"类型":"薯片","规格":"70g/袋","口味":"麻辣小龙虾"}', '["小龙虾风味","麻辣鲜香","薄脆爽口","网红口味"]', '["薯片 70g","包装袋 x1"]', 9.00, 13.00, 600, '/image/food/薯片/10033.png', '小龙虾味薯片，麻辣鲜香', 1, (SELECT id FROM shops WHERE folder = 'lingshi2' LIMIT 1)),
('培根味薯片 70g', 'food', '零食品牌', '培根味', '红棕色', '{"类型":"薯片","规格":"70g/袋","口味":"培根"}', '["培根风味","肉香四溢","薄脆爽口","肉食爱好者必选"]', '["薯片 70g","包装袋 x1"]', 9.00, 13.00, 600, '/image/food/薯片/10034.png', '培根味薯片，肉香四溢', 1, (SELECT id FROM shops WHERE folder = 'lingshi3' LIMIT 1)),
('酸奶洋葱味薯片 70g', 'food', '零食品牌', '酸奶洋葱', '浅黄色', '{"类型":"薯片","规格":"70g/袋","口味":"酸奶洋葱"}', '["酸奶洋葱风味","酸甜可口","薄脆爽口","独特口味"]', '["薯片 70g","包装袋 x1"]', 9.00, 13.00, 600, '/image/food/薯片/10035.png', '酸奶洋葱味薯片，酸甜可口', 1, (SELECT id FROM shops WHERE folder = 'lingshi4' LIMIT 1)),
('桶装薯片 150g', 'food', '零食品牌', '桶装', '黄色', '{"类型":"薯片","规格":"150g/桶","口味":"原味"}', '["桶装设计","方便取用","香脆可口","分享装"]', '["薯片 150g","包装桶 x1"]', 15.00, 20.00, 500, '/image/food/薯片/10036.png', '桶装薯片，方便取用', 1, (SELECT id FROM shops WHERE folder = 'lingshi1' LIMIT 1));

-- ============================================================
-- 4. 食品生鲜商品多图数据
-- ============================================================

-- 辣条类
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '香辣辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10001.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '麻辣辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10002.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '卫龙辣条 106g' AND category = 'food' LIMIT 1), '/image/food/辣条/10003.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '大刀肉辣条 200g' AND category = 'food' LIMIT 1), '/image/food/辣条/10004.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '亲嘴烧辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10005.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '魔芋爽辣条 150g' AND category = 'food' LIMIT 1), '/image/food/辣条/10006.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '辣条大礼包 500g' AND category = 'food' LIMIT 1), '/image/food/辣条/10007.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '豆皮辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10008.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '素牛筋辣条 120g' AND category = 'food' LIMIT 1), '/image/food/辣条/10009.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '香辣棒辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10010.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '臭干子辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10011.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '面筋辣条 150g' AND category = 'food' LIMIT 1), '/image/food/辣条/10012.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '辣片辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10013.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '香辣丝辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10014.jpeg', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '麻辣豆干辣条 120g' AND category = 'food' LIMIT 1), '/image/food/辣条/10015.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '辣条组合装 300g' AND category = 'food' LIMIT 1), '/image/food/辣条/10016.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '手撕辣条 150g' AND category = 'food' LIMIT 1), '/image/food/辣条/10017.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '蒜香辣条 100g' AND category = 'food' LIMIT 1), '/image/food/辣条/10018.png', 1);

-- 薯片类
INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '原味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10014.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '番茄味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10019.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '烧烤味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10020.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '黄瓜味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10021.webp', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '香辣味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10022.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '椒盐味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10023.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '芝士味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10024.webp', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '海苔味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10025.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '薯片大礼包 300g' AND category = 'food' LIMIT 1), '/image/food/薯片/10026.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '蜂蜜黄油薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10027.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '薯条形状薯片 100g' AND category = 'food' LIMIT 1), '/image/food/薯片/10028.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '波浪薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10029.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '洋葱味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10030.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '黑椒味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10031.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '薯片组合装 200g' AND category = 'food' LIMIT 1), '/image/food/薯片/10032.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '麻辣小龙虾味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10033.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '培根味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10034.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '酸奶洋葱味薯片 70g' AND category = 'food' LIMIT 1), '/image/food/薯片/10035.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '桶装薯片 150g' AND category = 'food' LIMIT 1), '/image/food/薯片/10036.png', 1);
