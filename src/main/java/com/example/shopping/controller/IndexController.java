package com.example.shopping.controller;

import com.example.shopping.entity.Product;
import com.example.shopping.entity.ProductImage;
import com.example.shopping.entity.Shop;
import com.example.shopping.entity.User;
import com.example.shopping.mapper.ProductImageMapper;
import com.example.shopping.mapper.ProductMapper;
import com.example.shopping.mapper.ShopMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class IndexController {

    private final ProductMapper productMapper;
    private final ProductImageMapper productImageMapper;
    private final ShopMapper shopMapper;

    public IndexController(ProductMapper productMapper, ProductImageMapper productImageMapper, ShopMapper shopMapper) {
        this.productMapper = productMapper;
        this.productImageMapper = productImageMapper;
        this.shopMapper = shopMapper;
    }

    @GetMapping({"/", "/index"})
    public String index(@RequestParam(required = false) String keyword,
                        @RequestParam(required = false) String category,
                        @RequestParam(required = false) Long shopId,
                        HttpSession session,
                        Model model) {
        List<Product> products;
        if (keyword != null && !keyword.isBlank()) {
            products = productMapper.findByNameContainingIgnoreCase(keyword.trim());
        } else if (category != null && !category.isBlank()) {
            products = productMapper.findByCategory(category.trim());
        } else if (shopId != null) {
            products = productMapper.findByMerchantId(shopId);
        } else {
            products = productMapper.findRandom(24);
            if (products.isEmpty()) {
                products = productMapper.findAll();
            }
        }
        
        Map<Long, List<ProductImage>> productImages = new HashMap<>();
        for (Product p : products) {
            List<ProductImage> images = productImageMapper.findByProductId(p.getId());
            if (!images.isEmpty()) {
                productImages.put(p.getId(), images);
            }
        }
        
        List<Shop> shops = shopMapper.findAll();
        
        User user = (User) session.getAttribute("user");
        
        model.addAttribute("products", products);
        model.addAttribute("productImages", productImages);
        model.addAttribute("shops", shops);
        model.addAttribute("keyword", keyword);
        model.addAttribute("category", category);
        model.addAttribute("shopId", shopId);
        model.addAttribute("user", user);
        return "index";
    }
}
