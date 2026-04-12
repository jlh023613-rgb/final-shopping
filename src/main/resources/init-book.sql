-- ============================================================
-- 图书文具商品初始化脚本
-- 图片路径：/image/book/
-- ============================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- ============================================================
-- 1. 清空图书文具相关数据
-- ============================================================
DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE category = 'book');
DELETE FROM products WHERE category = 'book';

-- ============================================================
-- 2. 添加图书文具相关店铺
-- ============================================================
INSERT IGNORE INTO shops (name, folder, description, sort_order) VALUES
('京东图书旗舰店', 'jdbook', '京东图书官方店铺，正版图书', 50),
('淘宝图书旗舰店', 'taobaobook', '淘宝图书官方店铺，品质保证', 51),
('天猫图书旗舰店', 'tianmaobook', '天猫图书官方店铺，正版保障', 52),
('当当图书旗舰店', 'dangdangbook', '当当图书官方店铺，正版图书', 53);

-- ============================================================
-- 3. 图书文具商品数据 (category = 'book')
-- ============================================================

-- 文学小说类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('文学小说精选套装1', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约300页","开本":"32开"}', '["经典文学作品","语言朴实情感真挚","中国当代文学经典","值得收藏阅读"]', '["图书 x1","塑封包装"]', 35.00, 45.00, 500, '/image/book/10001.png', '经典文学小说作品', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('文学小说精选套装2', 'book', '出版社', '文学类', '精装', '{"类型":"文学小说","页数":"约360页","开本":"32开"}', '["世界文学经典","影响世界的重要作品","中文版销量超千万","装帧精美"]', '["图书 x1","塑封包装"]', 55.00, 68.00, 300, '/image/book/10002.png', '世界文学经典作品', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('文学小说精选套装3', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约302页","开本":"16开"}', '["获奖文学作品","中国文学里程碑","被译成多种语言","改编影视剧热播"]', '["图书 x1","塑封包装"]', 68.00, 88.00, 400, '/image/book/10003.png', '获奖文学经典作品', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('文学小说精选套装4', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约359页","开本":"32开"}', '["现代文学经典","幽默讽刺妙语连珠","被誉为新儒林外史","值得反复阅读"]', '["图书 x1","塑封包装"]', 39.00, 49.00, 350, '/image/book/10004.png', '现代文学经典作品', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1)),
('文学小说精选套装5', 'book', '出版社', '文学类', '精装', '{"类型":"文学小说","页数":"约1606页","开本":"32开"}', '["古典文学名著","红学研究必读版本","注释详尽权威版本","装帧精美收藏佳品"]', '["图书 x1","塑封包装"]', 89.00, 128.00, 200, '/image/book/10005.png', '古典文学名著', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('文学小说精选套装6', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约1584页","开本":"32开"}', '["获奖文学作品","激励千万青年的经典","讲述普通人的奋斗史","感人至深催人奋进"]', '["图书 x1","塑封包装"]', 99.00, 128.00, 250, '/image/book/10006.png', '励志文学经典', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('文学小说精选套装7', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约467页","开本":"32开"}', '["推理小说经典","情节扣人心弦","销量超百万册","引人入胜"]', '["图书 x1","塑封包装"]', 49.00, 59.00, 400, '/image/book/10007.png', '推理小说经典', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('文学小说精选套装8', 'book', '出版社', '文学类', '平装', '{"类型":"文学小说","页数":"约362页","开本":"32开"}', '["全球畅销作品","感人至深的友情故事","关于救赎与成长","被改编成电影"]', '["图书 x1","塑封包装"]', 42.00, 55.00, 350, '/image/book/10008.png', '畅销文学作品', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1));

-- 社科历史类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('社科历史精选套装1', 'book', '出版社', '社科类', '精装', '{"类型":"社科历史","页数":"约440页","开本":"16开"}', '["全球畅销书","重新认识人类历史","视角独特引人深思","被译成多种语言"]', '["图书 x1","塑封包装"]', 68.00, 88.00, 300, '/image/book/10009.png', '社科历史畅销书', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('社科历史精选套装2', 'book', '出版社', '社科类', '平装', '{"类型":"社科历史","页数":"约2682页","开本":"16开"}', '["历史畅销书第一名","用小说笔法写历史","语言幽默风趣","全七册典藏版"]', '["图书 x7","塑封包装"]', 168.00, 228.00, 150, '/image/book/10010.png', '历史畅销书', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('社科历史精选套装3', 'book', '出版社', '社科类', '平装', '{"类型":"社科历史","页数":"约318页","开本":"32开"}', '["历史学经典著作","大历史观的开创之作","以小见大见解独到","学术性与可读性兼备"]', '["图书 x1","塑封包装"]', 39.00, 48.00, 250, '/image/book/10011.png', '历史学经典著作', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('社科历史精选套装4', 'book', '出版社', '社科类', '平装', '{"类型":"社科历史","页数":"约514页","开本":"16开"}', '["获奖作品","解释人类社会的命运","跨学科研究典范","被译成多种语言"]', '["图书 x1","塑封包装"]', 62.00, 78.00, 200, '/image/book/10012.png', '社科经典著作', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1));

-- 经济管理类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('经济管理精选套装1', 'book', '出版社', '经管类', '平装', '{"类型":"经济管理","页数":"约288页","开本":"32开"}', '["财商启蒙经典","改变金钱观念","全球畅销千万册","投资理财入门必读"]', '["图书 x1","塑封包装"]', 48.00, 58.00, 400, '/image/book/10013.png', '财商启蒙经典', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('经济管理精选套装2', 'book', '出版社', '经管类', '精装', '{"类型":"经济管理","页数":"约576页","开本":"16开"}', '["投资界必读经典","生活和工作原则","被译成多种语言","深度思考之作"]', '["图书 x1","塑封包装"]', 98.00, 128.00, 200, '/image/book/10014.png', '投资管理经典', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('经济管理精选套装3', 'book', '出版社', '经管类', '平装', '{"类型":"经济管理","页数":"约418页","开本":"16开"}', '["获奖作品著作","认知心理学经典","揭示思维的两个系统","决策科学必读"]', '["图书 x1","塑封包装"]', 69.00, 88.00, 250, '/image/book/10015.png', '认知心理学经典', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('经济管理精选套装4', 'book', '出版社', '经管类', '精装', '{"类型":"经济管理","页数":"约835页","开本":"32开"}', '["经济学开山之作","现代经济学奠基","经典译本权威版本","经济学专业必读"]', '["图书 x1","塑封包装"]', 58.00, 78.00, 150, '/image/book/10016.png', '经济学经典', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1));

-- 心理励志类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('心理励志精选套装1', 'book', '出版社', '心理类', '平装', '{"类型":"心理励志","页数":"约194页","开本":"32开"}', '["心理学入门经典","自我启发之父的教诲","改变人生的勇气","畅销书"]', '["图书 x1","塑封包装"]', 42.00, 52.00, 450, '/image/book/10017.png', '心理学入门经典', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('心理励志精选套装2', 'book', '出版社', '心理类', '平装', '{"类型":"心理励志","页数":"约224页","开本":"32开"}', '["心理学经典之作","认识自我超越自卑","人生必读之书","深度解析人性"]', '["图书 x1","塑封包装"]', 35.00, 45.00, 300, '/image/book/10018.png', '心理学经典', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('心理励志精选套装3', 'book', '出版社', '心理类', '平装', '{"类型":"心理励志","页数":"约300页","开本":"32开"}', '["心理学畅销书经典","心灵成长必读","关于爱成长与救赎","连续多年畅销"]', '["图书 x1","塑封包装"]', 38.00, 48.00, 350, '/image/book/10019.png', '心灵成长经典', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1));

-- 童书绘本类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('童书绘本精选套装1', 'book', '出版社', '童书类', '精装', '{"类型":"童书绘本","页数":"约97页","开本":"32开"}', '["世界经典童话","献给大人的童话","关于爱与责任","被译成多种语言"]', '["图书 x1","塑封包装"]', 32.00, 42.00, 500, '/image/book/10020.png', '世界经典童话', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('童书绘本精选套装2', 'book', '出版社', '童书类', '平装', '{"类型":"童书绘本","页数":"约272页","开本":"32开"}', '["畅销书第一名","关于教育与成长","温暖治愈的故事","连续多年畅销"]', '["图书 x1","塑封包装"]', 36.00, 45.00, 400, '/image/book/10021.png', '教育成长故事', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('童书绘本精选套装3', 'book', '出版社', '童书类', '平装', '{"类型":"童书绘本","页数":"约216页","开本":"32开"}', '["经典儿童文学","关于友谊与承诺","感动全球的童话","被改编成电影"]', '["图书 x1","塑封包装"]', 28.00, 35.00, 450, '/image/book/10022.png', '经典儿童文学', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('童书绘本精选套装4', 'book', '出版社', '童书类', '精装', '{"类型":"童书绘本","页数":"约3000页","开本":"32开"}', '["魔法世界经典","全球畅销书","被改编成电影","全七册礼盒装"]', '["图书 x7","礼盒包装"]', 398.00, 498.00, 100, '/image/book/10023.png', '魔法世界经典', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1));

-- 科普读物类
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('科普读物精选套装1', 'book', '出版社', '科普类', '精装', '{"类型":"科普读物","页数":"约202页","开本":"32开"}', '["物理学大师代表作","探索宇宙奥秘","科普经典之作","被译成多种语言"]', '["图书 x1","塑封包装"]', 45.00, 58.00, 300, '/image/book/10024.png', '物理学科普经典', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('科普读物精选套装2', 'book', '出版社', '科普类', '平装', '{"类型":"科普读物","页数":"约418页","开本":"16开"}', '["进化生物学经典","基因视角看生命","颠覆传统认知","科学必读之作"]', '["图书 x1","塑封包装"]', 68.00, 88.00, 200, '/image/book/10025.png', '进化生物学经典', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1));

-- 文具用品
INSERT INTO products (name, category, brand, model, color, specifications, features, packaging_list, price, original_price, stock, image_url, description, status, merchant_id) VALUES
('中性笔套装 12支', 'book', '文具品牌', 'GP1008', '黑色', '{"类型":"文具","规格":"0.5mm*12支","颜色":"黑色"}', '["书写流畅不断墨","人体工学设计","适合日常书写","性价比高"]', '["中性笔 x12","包装盒 x1"]', 15.00, 20.00, 1000, '/image/book/10026.png', '中性笔套装', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1)),
('笔记本 A5 100页', 'book', '文具品牌', 'NB510', '多色可选', '{"类型":"文具","规格":"A5/100页","颜色":"多色可选"}', '["优质纸张书写顺滑","线圈装订翻页方便","适合学习办公","多色可选"]', '["笔记本 x1","塑封包装"]', 8.00, 12.00, 2000, '/image/book/10027.jpeg', 'A5笔记本', 1, (SELECT id FROM shops WHERE folder = 'dangdangbook' LIMIT 1)),
('彩色铅笔 48色', 'book', '文具品牌', 'CP48', '多色', '{"类型":"文具","规格":"48色","材质":"环保木材"}', '["色彩鲜艳易于上色","环保材质安全无毒","适合绘画创作","专业绘画工具"]', '["彩色铅笔 x48","笔盒 x1"]', 89.00, 128.00, 300, '/image/book/10028.jpeg', '48色彩色铅笔', 1, (SELECT id FROM shops WHERE folder = 'jdbook' LIMIT 1)),
('钢笔礼盒装', 'book', '文具品牌', 'FP01', '黑色/蓝色', '{"类型":"文具","规格":"F尖/M尖","材质":"树脂"}', '["书写流畅手感舒适","经典款式经久耐用","礼盒包装送礼佳品","品质保证"]', '["钢笔 x1","墨囊 x5","礼盒 x1"]', 128.00, 168.00, 200, '/image/book/10029.png', '钢笔礼盒装', 1, (SELECT id FROM shops WHERE folder = 'taobaobook' LIMIT 1)),
('活页本 B5', 'book', '文具品牌', 'LB-B5', '多色', '{"类型":"文具","规格":"B5/100页","颜色":"多色可选"}', '["活页设计方便整理","纸张优质书写顺滑","适合学习办公","品质保证"]', '["活页本 x1","活页纸 x100","塑封包装"]', 35.00, 45.00, 500, '/image/book/10030.png', 'B5活页本', 1, (SELECT id FROM shops WHERE folder = 'tianmaobook' LIMIT 1));

-- ============================================================
-- 4. 图书文具商品多图数据
-- ============================================================

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装1' AND category = 'book' LIMIT 1), '/image/book/10001.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装1' AND category = 'book' LIMIT 1), '/image/book/10031.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装2' AND category = 'book' LIMIT 1), '/image/book/10002.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装2' AND category = 'book' LIMIT 1), '/image/book/10032.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装3' AND category = 'book' LIMIT 1), '/image/book/10003.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装3' AND category = 'book' LIMIT 1), '/image/book/10033.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装4' AND category = 'book' LIMIT 1), '/image/book/10004.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装4' AND category = 'book' LIMIT 1), '/image/book/10034.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装5' AND category = 'book' LIMIT 1), '/image/book/10005.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装5' AND category = 'book' LIMIT 1), '/image/book/10035.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装6' AND category = 'book' LIMIT 1), '/image/book/10006.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装6' AND category = 'book' LIMIT 1), '/image/book/10036.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装7' AND category = 'book' LIMIT 1), '/image/book/10007.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装7' AND category = 'book' LIMIT 1), '/image/book/10037.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '文学小说精选套装8' AND category = 'book' LIMIT 1), '/image/book/10008.png', 1),
((SELECT id FROM products WHERE name = '文学小说精选套装8' AND category = 'book' LIMIT 1), '/image/book/10038.jpeg', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '社科历史精选套装1' AND category = 'book' LIMIT 1), '/image/book/10009.png', 1),
((SELECT id FROM products WHERE name = '社科历史精选套装1' AND category = 'book' LIMIT 1), '/image/book/10039.webp', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '社科历史精选套装2' AND category = 'book' LIMIT 1), '/image/book/10010.png', 1),
((SELECT id FROM products WHERE name = '社科历史精选套装2' AND category = 'book' LIMIT 1), '/image/book/10040.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '社科历史精选套装3' AND category = 'book' LIMIT 1), '/image/book/10011.png', 1),
((SELECT id FROM products WHERE name = '社科历史精选套装3' AND category = 'book' LIMIT 1), '/image/book/10041.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '社科历史精选套装4' AND category = 'book' LIMIT 1), '/image/book/10012.png', 1),
((SELECT id FROM products WHERE name = '社科历史精选套装4' AND category = 'book' LIMIT 1), '/image/book/10042.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '经济管理精选套装1' AND category = 'book' LIMIT 1), '/image/book/10013.png', 1),
((SELECT id FROM products WHERE name = '经济管理精选套装1' AND category = 'book' LIMIT 1), '/image/book/10043.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '经济管理精选套装2' AND category = 'book' LIMIT 1), '/image/book/10014.png', 1),
((SELECT id FROM products WHERE name = '经济管理精选套装2' AND category = 'book' LIMIT 1), '/image/book/10044.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '经济管理精选套装3' AND category = 'book' LIMIT 1), '/image/book/10015.png', 1),
((SELECT id FROM products WHERE name = '经济管理精选套装3' AND category = 'book' LIMIT 1), '/image/book/10045.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '经济管理精选套装4' AND category = 'book' LIMIT 1), '/image/book/10016.png', 1),
((SELECT id FROM products WHERE name = '经济管理精选套装4' AND category = 'book' LIMIT 1), '/image/book/10046.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '心理励志精选套装1' AND category = 'book' LIMIT 1), '/image/book/10017.png', 1),
((SELECT id FROM products WHERE name = '心理励志精选套装1' AND category = 'book' LIMIT 1), '/image/book/10047.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '心理励志精选套装2' AND category = 'book' LIMIT 1), '/image/book/10018.png', 1),
((SELECT id FROM products WHERE name = '心理励志精选套装2' AND category = 'book' LIMIT 1), '/image/book/10048.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '心理励志精选套装3' AND category = 'book' LIMIT 1), '/image/book/10019.png', 1),
((SELECT id FROM products WHERE name = '心理励志精选套装3' AND category = 'book' LIMIT 1), '/image/book/10049.png', 2);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '童书绘本精选套装1' AND category = 'book' LIMIT 1), '/image/book/10020.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '童书绘本精选套装2' AND category = 'book' LIMIT 1), '/image/book/10021.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '童书绘本精选套装3' AND category = 'book' LIMIT 1), '/image/book/10022.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '童书绘本精选套装4' AND category = 'book' LIMIT 1), '/image/book/10023.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '科普读物精选套装1' AND category = 'book' LIMIT 1), '/image/book/10024.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '科普读物精选套装2' AND category = 'book' LIMIT 1), '/image/book/10025.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '中性笔套装 12支' AND category = 'book' LIMIT 1), '/image/book/10026.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '笔记本 A5 100页' AND category = 'book' LIMIT 1), '/image/book/10027.jpeg', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '彩色铅笔 48色' AND category = 'book' LIMIT 1), '/image/book/10028.jpeg', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '钢笔礼盒装' AND category = 'book' LIMIT 1), '/image/book/10029.png', 1);

INSERT INTO product_images (product_id, image_url, sort_order) VALUES
((SELECT id FROM products WHERE name = '活页本 B5' AND category = 'book' LIMIT 1), '/image/book/10030.png', 1);
