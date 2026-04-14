package com.example.shopping.controller;

import com.example.shopping.entity.Product;
import com.example.shopping.entity.ProductImage;
import com.example.shopping.entity.Shop;
import com.example.shopping.entity.User;
import com.example.shopping.mapper.ProductImageMapper;
import com.example.shopping.mapper.ProductMapper;
import com.example.shopping.mapper.ShopMapper;
import com.example.shopping.service.ImageAssetService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Controller
public class IndexController {

    private final ProductMapper productMapper;
    private final ProductImageMapper productImageMapper;
    private final ShopMapper shopMapper;
    private final ImageAssetService imageAssetService;

    private static final int PAGE_SIZE = 15;

    public IndexController(ProductMapper productMapper, ProductImageMapper productImageMapper,
                           ShopMapper shopMapper, ImageAssetService imageAssetService) {
        this.productMapper = productMapper;
        this.productImageMapper = productImageMapper;
        this.shopMapper = shopMapper;
        this.imageAssetService = imageAssetService;
    }

    @GetMapping({"/", "/index"})
    public String index(@RequestParam(required = false) String keyword,
                        @RequestParam(required = false) String category,
                        @RequestParam(required = false) Long shopId,
                        @RequestParam(defaultValue = "1") int page,
                        HttpSession session,
                        Model model) {
        User user = (User) session.getAttribute("user");
        List<Shop> shops = shopMapper.findAll();

        if (keyword != null && !keyword.isBlank()) {
            List<Product> products = productMapper.findByNameContainingIgnoreCase(keyword.trim());
            Map<Long, List<ProductImage>> productImages = buildResolvedImageMap(products);
            model.addAttribute("products", products);
            model.addAttribute("productImages", productImages);
            model.addAttribute("keyword", keyword);
            model.addAttribute("category", null);
            model.addAttribute("shopId", null);
            model.addAttribute("currentPage", 1);
            model.addAttribute("totalPages", 1);
            model.addAttribute("shops", shops);
            model.addAttribute("selectedShop", null);
            model.addAttribute("user", user);
            return "index";
        }

        if (shopId != null) {
            List<Product> products = productMapper.findByMerchantId(shopId);
            Map<Long, List<ProductImage>> productImages = buildResolvedImageMap(products);
            model.addAttribute("products", products);
            model.addAttribute("productImages", productImages);
            model.addAttribute("keyword", null);
            model.addAttribute("category", null);
            model.addAttribute("shopId", shopId);
            model.addAttribute("currentPage", 1);
            model.addAttribute("totalPages", 1);
            model.addAttribute("shops", shops);
            model.addAttribute("selectedShop", shopMapper.findById(shopId));
            model.addAttribute("user", user);
            return "index";
        }

        String effectiveCategory = normalizeCategory(category);
        int total = productMapper.countByCategory(effectiveCategory);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;

        int offset = (page - 1) * PAGE_SIZE;
        List<Product> products = productMapper.findByPage(effectiveCategory, offset, PAGE_SIZE);
        Map<Long, List<ProductImage>> productImages = buildResolvedImageMap(products);

        model.addAttribute("products", products);
        model.addAttribute("productImages", productImages);
        model.addAttribute("keyword", null);
        model.addAttribute("category", effectiveCategory);
        model.addAttribute("shopId", null);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("shops", shops);
        model.addAttribute("selectedShop", null);
        model.addAttribute("user", user);
        return "index";
    }

    private Map<Long, List<ProductImage>> buildResolvedImageMap(List<Product> products) {
        Map<Long, List<ProductImage>> productImages = new HashMap<>();
        for (Product product : products) {
            product.setImageUrl(imageAssetService.resolveImageUrl(product.getImageUrl()));
            List<ProductImage> images = productImageMapper.findByProductId(product.getId());
            for (ProductImage image : images) {
                image.setImageUrl(imageAssetService.resolveImageUrl(image.getImageUrl()));
            }
            if (!images.isEmpty()) {
                productImages.put(product.getId(), images);
            }
        }
        return productImages;
    }

    private String normalizeCategory(String category) {
        if (category == null || category.isBlank()) {
            return null;
        }
        String normalized = category.trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case "appliances" -> "appliance";
            case "clothes" -> "cloth-shoes";
            case "sport", "sports-outdoor", "outdoor" -> "sports";
            case "beauty", "makeup", "meizhuang" -> "cosmetics";
            default -> normalized;
        };
    }
}
