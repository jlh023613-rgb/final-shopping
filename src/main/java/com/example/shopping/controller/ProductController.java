package com.example.shopping.controller;

import com.example.shopping.entity.Merchant;
import com.example.shopping.entity.Product;
import com.example.shopping.entity.ProductImage;
import com.example.shopping.entity.Review;
import com.example.shopping.entity.Shop;
import com.example.shopping.entity.User;
import com.example.shopping.mapper.MerchantMapper;
import com.example.shopping.mapper.ProductImageMapper;
import com.example.shopping.mapper.ProductMapper;
import com.example.shopping.mapper.ReviewMapper;
import com.example.shopping.mapper.ShopMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Controller
public class ProductController {

    private final ProductMapper productMapper;
    private final ProductImageMapper productImageMapper;
    private final ShopMapper shopMapper;
    private final MerchantMapper merchantMapper;
    private final ReviewMapper reviewMapper;

    public ProductController(ProductMapper productMapper, ProductImageMapper productImageMapper,
                             ShopMapper shopMapper, MerchantMapper merchantMapper, ReviewMapper reviewMapper) {
        this.productMapper = productMapper;
        this.productImageMapper = productImageMapper;
        this.shopMapper = shopMapper;
        this.merchantMapper = merchantMapper;
        this.reviewMapper = reviewMapper;
    }

    @GetMapping("/product/{id}")
    public String detail(@PathVariable Long id, HttpSession session, Model model) {
        Product product = productMapper.findById(id);
        if (product == null) {
            model.addAttribute("product", null);
            return "product/detail";
        }
        List<ProductImage> images = productImageMapper.findByProductId(id);
        List<String> imageUrls = images.isEmpty()
                ? (product.getImageUrl() != null ? List.of(product.getImageUrl()) : new ArrayList<>())
                : images.stream().map(ProductImage::getImageUrl).collect(Collectors.toList());
        product.setImageUrl(product.getImageUrl() != null ? product.getImageUrl() : (imageUrls.isEmpty() ? null : imageUrls.get(0)));
        model.addAttribute("product", product);
        model.addAttribute("imageUrls", imageUrls);

        if (product.getMerchantId() != null) {
            Merchant merchant = merchantMapper.findById(product.getMerchantId());
            if (merchant != null) {
                Shop shop = new Shop();
                shop.setId(merchant.getId());
                shop.setName(merchant.getShopName());
                shop.setDescription(merchant.getShopDescription());
                model.addAttribute("shop", shop);
                model.addAttribute("merchant", merchant);
            } else {
                model.addAttribute("shop", null);
                model.addAttribute("merchant", null);
            }
        } else {
            model.addAttribute("shop", null);
            model.addAttribute("merchant", null);
        }

        List<Review> reviews = reviewMapper.findByProductId(id);
        model.addAttribute("reviews", reviews);
        model.addAttribute("reviewCount", reviews.size());

        if (!reviews.isEmpty()) {
            double avgRating = reviews.stream().mapToInt(Review::getRating).average().orElse(0.0);
            model.addAttribute("avgRating", avgRating);
        } else {
            model.addAttribute("avgRating", null);
        }

        User user = (User) session.getAttribute("user");
        model.addAttribute("user", user);

        return "product/detail";
    }
}
