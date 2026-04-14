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
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Objects;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Stream;

@Service
public class ImageScanService {

    private static final Logger log = LoggerFactory.getLogger(ImageScanService.class);
    private static final Pattern IMAGE_PATTERN = Pattern.compile("(?i).+\\.(jpg|jpeg|png|gif|webp)$");
    private static final BigDecimal DEFAULT_PRICE = new BigDecimal("3999.00");
    private static final Set<String> TARGET_FOLDERS = Set.of("sports", "cosmetics", "meizhuang");

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
            log.info("Image scan import disabled (image.scan.enabled=false), skipped.");
            return 0;
        }

        File imageRoot = resolveImageRoot();
        if (imageRoot == null || !imageRoot.isDirectory()) {
            log.info("static/image directory not found, skipped.");
            return 0;
        }

        File[] shopDirs = imageRoot.listFiles(File::isDirectory);
        if (shopDirs == null || shopDirs.length == 0) {
            log.info("No category directories under static/image, skipped.");
            return 0;
        }

        Set<String> existingImageUrls = loadExistingImageUrls();
        int count = 0;
        for (File shopDir : shopDirs) {
            String folder = shopDir.getName().toLowerCase(Locale.ROOT);
            if (!TARGET_FOLDERS.contains(folder)) {
                continue;
            }
            count += importFlatImageProducts(shopDir.toPath(), imageRoot.toPath(), existingImageUrls);
        }

        log.info("Image scan import completed. {} products imported.", count);
        return count;
    }

    private File resolveImageRoot() {
        if (scanPath != null && !scanPath.isBlank()) {
            File f = new File(scanPath);
            if (f.isDirectory()) {
                return f;
            }
        }
        try {
            PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
            Resource r = resolver.getResource("classpath:static/image");
            if (r.exists() && r.isFile()) {
                return r.getFile();
            }
            File fromClasspath = new File(Objects.requireNonNull(getClass().getClassLoader().getResource("static/image")).toURI());
            if (fromClasspath.isDirectory()) {
                return fromClasspath;
            }
        } catch (Exception e) {
            log.debug("classpath:static/image is unavailable: {}", e.getMessage());
        }
        File relative = new File("src/main/resources/static/image");
        if (relative.isDirectory()) {
            return relative;
        }
        relative = new File("static/image");
        return relative.isDirectory() ? relative : null;
    }

    private Set<String> loadExistingImageUrls() {
        Set<String> urls = new HashSet<>();
        for (Product product : productMapper.findAll()) {
            if (product.getImageUrl() != null && !product.getImageUrl().isBlank()) {
                urls.add(normalizeImageUrl(product.getImageUrl()));
            }
        }
        return urls;
    }

    private int importFlatImageProducts(Path categoryPath, Path imageRootPath, Set<String> existingImageUrls) {
        String folderName = categoryPath.getFileName().toString();
        Shop shop = ensureShop(folderName);

        List<Path> imageFiles = new ArrayList<>();
        try (Stream<Path> stream = Files.walk(categoryPath)) {
            stream.filter(Files::isRegularFile)
                    .filter(path -> IMAGE_PATTERN.matcher(path.getFileName().toString()).matches())
                    .sorted()
                    .forEach(imageFiles::add);
        } catch (IOException e) {
            log.warn("Failed to scan folder {}: {}", folderName, e.getMessage());
            return 0;
        }

        int count = 0;
        String category = resolveCategory(folderName);
        for (Path imagePath : imageFiles) {
            String imageUrl = normalizeImageUrl(toImageUrl(imageRootPath, imagePath));
            if (existingImageUrls.contains(imageUrl)) {
                continue;
            }

            Product product = new Product();
            product.setName(buildProductName(category, categoryPath, imagePath));
            product.setCategory(category);
            product.setPrice(calculatePrice(imageUrl));
            product.setOriginalPrice(product.getPrice().add(BigDecimal.valueOf(500)));
            product.setStock(100);
            product.setImageUrl(imageUrl);
            product.setDescription("Auto imported from static image assets");
            product.setStatus(1);
            product.setMerchantId(shop.getId());
            productMapper.insert(product);

            ProductImage img = new ProductImage();
            img.setProductId(product.getId());
            img.setImageUrl(imageUrl);
            img.setSortOrder(0);
            productImageMapper.insert(img);

            existingImageUrls.add(imageUrl);
            count++;
        }

        log.info("Category {} imported {} products from local images.", folderName, count);
        return count;
    }

    private Shop ensureShop(String folderName) {
        Shop existing = shopMapper.findByFolder(folderName);
        if (existing != null) {
            return existing;
        }
        Shop shop = new Shop();
        shop.setName(folderNameToDisplayName(folderName));
        shop.setFolder(folderName);
        shop.setDescription("Auto imported image category: " + folderName);
        shop.setSortOrder(0);
        shopMapper.insert(shop);
        return shop;
    }

    private String buildProductName(String category, Path categoryPath, Path imagePath) {
        Path relative = categoryPath.relativize(imagePath);
        String fileName = relative.getFileName().toString();
        String stem = stripExtension(fileName);
        String cleanedStem = cleanName(stem);

        if (relative.getNameCount() > 1) {
            String firstDir = cleanName(relative.getName(0).toString());
            return trimProductName(firstDir + " " + cleanedStem);
        }

        String prefix = switch (category) {
            case "sports" -> "Sports";
            case "cosmetics" -> "Cosmetics";
            default -> "Product";
        };
        return trimProductName(prefix + " " + cleanedStem);
    }

    private String cleanName(String raw) {
        if (raw == null || raw.isBlank()) {
            return "Product";
        }
        String cleaned = raw.replace('_', ' ')
                .replace('-', ' ')
                .replaceAll("\\s+", " ")
                .trim();
        return cleaned.isBlank() ? "Product" : cleaned;
    }

    private String trimProductName(String value) {
        if (value.length() <= 180) {
            return value;
        }
        return value.substring(0, 180);
    }

    private BigDecimal calculatePrice(String seed) {
        long offset = Math.abs((long) seed.hashCode() % 4000);
        return DEFAULT_PRICE.add(BigDecimal.valueOf(offset));
    }

    private String toImageUrl(Path imageRootPath, Path imagePath) {
        Path relativePath = imageRootPath.relativize(imagePath);
        return "/image/" + relativePath.toString().replace('\\', '/');
    }

    private String normalizeImageUrl(String imageUrl) {
        String normalized = imageUrl.replace('\\', '/').trim();
        if (!normalized.startsWith("/")) {
            normalized = "/" + normalized;
        }
        return normalized;
    }

    private String stripExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        if (dot <= 0) {
            return fileName;
        }
        return fileName.substring(0, dot);
    }

    private static String folderNameToDisplayName(String folder) {
        if (folder == null || folder.isEmpty()) {
            return folder;
        }
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