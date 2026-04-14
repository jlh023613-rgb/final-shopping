package com.example.shopping.service;

import com.example.shopping.entity.Product;
import com.example.shopping.entity.ProductImage;
import com.example.shopping.entity.Shop;
import com.example.shopping.mapper.ProductImageMapper;
import com.example.shopping.mapper.ProductMapper;
import com.example.shopping.mapper.ShopMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.stereotype.Service;

import java.io.File;
import java.math.BigDecimal;
import java.util.*;
import java.util.regex.Pattern;

@Service
public class ImageScanService {

    private static final Logger log = LoggerFactory.getLogger(ImageScanService.class);
    private static final Pattern IMAGE_PATTERN = Pattern.compile("(?i).+\\.(jpg|jpeg|png|gif|webp)$");
    private static final BigDecimal DEFAULT_PRICE = new BigDecimal("3999.00");

    private final ShopMapper shopMapper;
    private final ProductMapper productMapper;
    private final ProductImageMapper productImageMapper;

    @Value("${image.scan.enabled:false}")
    private boolean scanEnabled;

    @Value("${image.scan.path:}")
    private String scanPath;

    public ImageScanService(ShopMapper shopMapper, ProductMapper productMapper, ProductImageMapper productImageMapper) {
        this.shopMapper = shopMapper;
        this.productMapper = productMapper;
        this.productImageMapper = productImageMapper;
    }

    public int scanAndImport() {
        if (!scanEnabled) {
            log.info("图片扫描导入已禁用 (image.scan.enabled=false)，跳过自动导入。");
            return 0;
        }
        
        File imageRoot = resolveImageRoot();
        if (imageRoot == null || !imageRoot.isDirectory()) {
            log.info("未找到 static/image 目录，跳过图片扫描。");
            return 0;
        }
        File[] shopDirs = imageRoot.listFiles(File::isDirectory);
        if (shopDirs == null || shopDirs.length == 0) {
            log.info("static/image 下无子文件夹，跳过扫描。");
            return 0;
        }
        
        long existingProducts = productMapper.findAll().size();
        if (existingProducts > 0) {
            log.info("数据库已有 {} 个商品，跳过图片扫描导入。", existingProducts);
            return 0;
        }
        
        int count = 0;
        for (File shopDir : shopDirs) {
            count += importShop(shopDir, imageRoot.getPath());
        }
        log.info("图片扫描完成，共导入 {} 个商品/图片。", count);
        return count;
    }

    private File resolveImageRoot() {
        if (scanPath != null && !scanPath.isBlank()) {
            File f = new File(scanPath);
            if (f.isDirectory()) return f;
        }
        try {
            PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
            Resource r = resolver.getResource("classpath:static/image");
            if (r.exists() && r.isFile()) {
                return r.getFile();
            }
            File fromClasspath = new File(Objects.requireNonNull(getClass().getClassLoader().getResource("static/image")).toURI());
            if (fromClasspath.isDirectory()) return fromClasspath;
        } catch (Exception e) {
            log.debug("classpath:static/image 不可用: {}", e.getMessage());
        }
        File relative = new File("src/main/resources/static/image");
        if (relative.isDirectory()) return relative;
        relative = new File("static/image");
        return relative.isDirectory() ? relative : null;
    }

    private int importShop(File shopDir, String imageRootPath) {
        String folderName = shopDir.getName();
        Shop existing = shopMapper.findByFolder(folderName);
        Shop shop = existing;
        if (shop == null) {
            shop = new Shop();
            shop.setName(folderNameToDisplayName(folderName));
            shop.setFolder(folderName);
            shop.setDescription("店铺：" + folderName);
            shop.setSortOrder(0);
            shopMapper.insert(shop);
        }
        long shopId = shop.getId();
        File[] productDirs = shopDir.listFiles(File::isDirectory);
        if (productDirs == null) return 0;
        int count = 0;
        for (File productDir : productDirs) {
            count += importProduct(productDir, shopId, folderName, imageRootPath);
        }
        return count;
    }

    private int importProduct(File productDir, long shopId, String shopFolder, String imageRootPath) {
        String modelName = productDir.getName();
        List<String> imagePaths = listImagePaths(productDir, shopFolder, modelName, imageRootPath);
        if (imagePaths.isEmpty()) return 0;

        String mainImage = imagePaths.get(0);
        Product p = new Product();
        p.setName(modelName);
        p.setCategory(resolveCategory(shopFolder));
        p.setPrice(DEFAULT_PRICE.add(BigDecimal.valueOf(Math.abs((long) modelName.hashCode() % 5000))));
        p.setOriginalPrice(p.getPrice().add(BigDecimal.valueOf(500)));
        p.setStock(100);
        p.setImageUrl(mainImage);
        p.setDescription("型号：" + modelName + "，店铺：" + shopFolder);
        p.setStatus(1);
        p.setMerchantId(shopId);
        productMapper.insert(p);
        long productId = p.getId();
        for (int i = 0; i < imagePaths.size(); i++) {
            ProductImage img = new ProductImage();
            img.setProductId(productId);
            img.setImageUrl(imagePaths.get(i));
            img.setSortOrder(i);
            productImageMapper.insert(img);
        }
        return 1;
    }

    private List<String> listImagePaths(File productDir, String shopFolder, String modelName, String imageRootPath) {
        File[] files = productDir.listFiles(f -> f.isFile() && IMAGE_PATTERN.matcher(f.getName()).matches());
        if (files == null) return Collections.emptyList();
        Arrays.sort(files, Comparator.comparing(File::getName));
        List<String> paths = new ArrayList<>();
        for (File f : files) {
            String relative = "image/" + shopFolder + "/" + modelName + "/" + f.getName();
            paths.add("/" + relative);
        }
        return paths;
    }

    private static String folderNameToDisplayName(String folder) {
        if (folder == null || folder.isEmpty()) return folder;
        return folder.substring(0, 1).toUpperCase(Locale.ROOT) + folder.substring(1).toLowerCase(Locale.ROOT);
    }

    private String resolveCategory(String folderName) {
        if (folderName == null || folderName.isBlank()) {
            return "other";
        }
        String folder = folderName.trim().toLowerCase(Locale.ROOT);
        return switch (folder) {
            case "phone", "phones" -> "phone";
            case "computer", "computers" -> "computer";
            case "appliance", "appliances" -> "appliance";
            case "cloth-shoes", "clothes" -> "cloth-shoes";
            case "food" -> "food";
            case "book", "books" -> "book";
            case "sports", "sport", "sports-outdoor", "outdoor" -> "sports";
            case "cosmetics", "beauty", "makeup", "meizhuang" -> "cosmetics";
            default -> {
                if (folder.startsWith("sports")) {
                    yield "sports";
                }
                if (folder.startsWith("meizhuang")) {
                    yield "cosmetics";
                }
                yield folder;
            }
        };
    }
}
