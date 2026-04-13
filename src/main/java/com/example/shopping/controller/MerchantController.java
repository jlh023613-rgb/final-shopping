package com.example.shopping.controller;

import com.example.shopping.entity.*;
import com.example.shopping.mapper.*;
import com.example.shopping.service.OrderService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/merchant")
public class MerchantController {

    private final MerchantMapper merchantMapper;
    private final ProductMapper productMapper;
    private final OrderMapper orderMapper;
    private final ReviewMapper reviewMapper;
    private final RefundMapper refundMapper;
    private final OrderService orderService;
    private final PasswordEncoder passwordEncoder;

    public MerchantController(MerchantMapper merchantMapper, ProductMapper productMapper,
                              OrderMapper orderMapper, ReviewMapper reviewMapper,
                              RefundMapper refundMapper, OrderService orderService,
                              PasswordEncoder passwordEncoder) {
        this.merchantMapper = merchantMapper;
        this.productMapper = productMapper;
        this.orderMapper = orderMapper;
        this.reviewMapper = reviewMapper;
        this.refundMapper = refundMapper;
        this.orderService = orderService;
        this.passwordEncoder = passwordEncoder;
    }

    @GetMapping("/register")
    public String registerPage() {
        return "merchant/register";
    }

    @PostMapping("/register")
    public String register(@RequestParam String username,
                           @RequestParam String password,
                           @RequestParam String shopName,
                           @RequestParam(required = false) String shopDescription,
                           @RequestParam(required = false) MultipartFile shopImage,
                           Model model) {
        Merchant existing = merchantMapper.findByUsername(username);
        if (existing != null) {
            model.addAttribute("error", "该账号已存在");
            return "merchant/register";
        }

        Merchant merchant = new Merchant();
        merchant.setUsername(username);
        merchant.setPassword(passwordEncoder.encode(password));
        merchant.setShopName(shopName);
        merchant.setShopDescription(shopDescription);
        merchant.setStatus("pending");

        if (shopImage != null && !shopImage.isEmpty()) {
            try {
                String fileName = UUID.randomUUID().toString() + "_" + shopImage.getOriginalFilename();
                Path uploadDir = Paths.get("src/main/resources/static/image/shop");
                if (!Files.exists(uploadDir)) {
                    Files.createDirectories(uploadDir);
                }
                Files.copy(shopImage.getInputStream(), uploadDir.resolve(fileName));
                merchant.setShopImage("/image/shop/" + fileName);
            } catch (IOException e) {
                model.addAttribute("error", "图片上传失败");
                return "merchant/register";
            }
        }

        merchantMapper.insert(merchant);
        model.addAttribute("message", "注册成功，请等待管理员审核");
        return "merchant/login";
    }

    @GetMapping("/login")
    public String loginPage() {
        return "merchant/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        HttpSession session,
                        Model model) {
        Merchant merchant = merchantMapper.findByUsername(username);
        if (merchant == null) {
            model.addAttribute("error", "账号不存在");
            return "merchant/login";
        }
        if (!passwordEncoder.matches(password, merchant.getPassword())) {
            model.addAttribute("error", "密码错误");
            return "merchant/login";
        }
        if ("pending".equals(merchant.getStatus())) {
            model.addAttribute("error", "账号待审核，请等待管理员审核通过");
            return "merchant/login";
        }
        if ("closed".equals(merchant.getStatus())) {
            model.addAttribute("error", "店铺已被关停，无法登录");
            return "merchant/login";
        }

        session.setAttribute("merchant", merchant);
        return "redirect:/merchant/dashboard";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        try {
            merchant = merchantMapper.findById(merchant.getId());
            session.setAttribute("merchant", merchant);

            List<Product> products = productMapper.findByMerchantId(merchant.getId());
            List<Order> orders = orderService.findByMerchantId(merchant.getId());
            List<Review> reviews = reviewMapper.findByMerchantProducts(merchant.getId());
            List<Refund> refunds = refundMapper.findByMerchantId(merchant.getId());

            long pendingOrders = orders.stream().filter(o -> "pending".equals(o.getStatus())).count();
            long shippingOrders = orders.stream().filter(o -> "shipping".equals(o.getStatus())).count();
            long deliveredOrders = orders.stream().filter(o -> "delivered".equals(o.getStatus())).count();
            long pendingRefunds = refunds.stream().filter(r -> "pending".equals(r.getStatus())).count();

            model.addAttribute("merchant", merchant);
            model.addAttribute("products", products);
            model.addAttribute("orders", orders);
            model.addAttribute("reviews", reviews);
            model.addAttribute("refunds", refunds);
            model.addAttribute("pendingOrders", pendingOrders);
            model.addAttribute("shippingOrders", shippingOrders);
            model.addAttribute("deliveredOrders", deliveredOrders);
            model.addAttribute("pendingRefunds", pendingRefunds);
            model.addAttribute("totalProducts", products.size());
            model.addAttribute("totalOrders", orders.size());
        } catch (Exception e) {
            model.addAttribute("merchant", merchant);
            model.addAttribute("products", java.util.Collections.emptyList());
            model.addAttribute("orders", java.util.Collections.emptyList());
            model.addAttribute("reviews", java.util.Collections.emptyList());
            model.addAttribute("refunds", java.util.Collections.emptyList());
            model.addAttribute("pendingOrders", 0L);
            model.addAttribute("shippingOrders", 0L);
            model.addAttribute("deliveredOrders", 0L);
            model.addAttribute("pendingRefunds", 0L);
            model.addAttribute("totalProducts", 0);
            model.addAttribute("totalOrders", 0);
            model.addAttribute("error", "加载数据失败: " + e.getMessage());
        }
        return "merchant/dashboard";
    }

    @GetMapping("/products")
    public String products(HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        List<Product> products = productMapper.findByMerchantId(merchant.getId());
        model.addAttribute("merchant", merchant);
        model.addAttribute("products", products);
        return "merchant/products";
    }

    @GetMapping("/product/add")
    public String addProductPage(HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }
        model.addAttribute("merchant", merchant);
        return "merchant/product-add";
    }

    @PostMapping("/product/add")
    public String addProduct(@RequestParam String name,
                             @RequestParam BigDecimal price,
                             @RequestParam(required = false) BigDecimal originalPrice,
                             @RequestParam(defaultValue = "0") Integer stock,
                             @RequestParam(required = false) String description,
                             @RequestParam(required = false) MultipartFile imageFile,
                             HttpSession session,
                             Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        Product product = new Product();
        product.setName(name);
        product.setCategory(merchant.getCategory());
        product.setPrice(price);
        product.setOriginalPrice(originalPrice);
        product.setStock(stock);
        product.setDescription(description);
        product.setStatus(1);
        product.setMerchantId(merchant.getId());

        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
                Path uploadDir = Paths.get("src/main/resources/static/image/" + merchant.getCategory());
                if (!Files.exists(uploadDir)) {
                    Files.createDirectories(uploadDir);
                }
                Files.copy(imageFile.getInputStream(), uploadDir.resolve(fileName));
                product.setImageUrl("/image/" + merchant.getCategory() + "/" + fileName);
            } catch (IOException e) {
                model.addAttribute("error", "图片上传失败");
                return "merchant/product-add";
            }
        }

        productMapper.insert(product);
        return "redirect:/merchant/products";
    }

    @GetMapping("/product/edit/{id}")
    public String editProductPage(@PathVariable Long id, HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        Product product = productMapper.findById(id);
        if (product == null || !product.getMerchantId().equals(merchant.getId())) {
            return "redirect:/merchant/products";
        }

        model.addAttribute("merchant", merchant);
        model.addAttribute("product", product);
        return "merchant/product-edit";
    }

    @PostMapping("/product/edit/{id}")
    public String editProduct(@PathVariable Long id,
                              @RequestParam String name,
                              @RequestParam BigDecimal price,
                              @RequestParam(required = false) BigDecimal originalPrice,
                              @RequestParam(defaultValue = "0") Integer stock,
                              @RequestParam(required = false) String description,
                              @RequestParam(required = false) MultipartFile imageFile,
                              HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        Product product = productMapper.findById(id);
        if (product == null || !product.getMerchantId().equals(merchant.getId())) {
            return "redirect:/merchant/products";
        }

        product.setName(name);
        product.setPrice(price);
        product.setOriginalPrice(originalPrice);
        product.setStock(stock);
        product.setDescription(description);

        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
                Path uploadDir = Paths.get("src/main/resources/static/image/" + merchant.getCategory());
                if (!Files.exists(uploadDir)) {
                    Files.createDirectories(uploadDir);
                }
                Files.copy(imageFile.getInputStream(), uploadDir.resolve(fileName));
                product.setImageUrl("/image/" + merchant.getCategory() + "/" + fileName);
            } catch (IOException e) {
                // ignore
            }
        }

        productMapper.update(product);
        return "redirect:/merchant/products";
    }

    @PostMapping("/product/delete/{id}")
    public String deleteProduct(@PathVariable Long id, HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        Product product = productMapper.findById(id);
        if (product != null && product.getMerchantId().equals(merchant.getId())) {
            productMapper.delete(id);
        }
        return "redirect:/merchant/products";
    }

    @GetMapping("/orders")
    public String orders(HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        List<Order> orders = orderService.findByMerchantId(merchant.getId());
        model.addAttribute("merchant", merchant);
        model.addAttribute("orders", orders);
        return "merchant/orders";
    }

    @PostMapping("/order/accept/{id}")
    public String acceptOrder(@PathVariable Long id, HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.acceptOrder(id, merchant.getId());
        return "redirect:/merchant/orders";
    }

    @PostMapping("/order/deliver/{id}")
    public String deliverOrder(@PathVariable Long id, HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.deliverOrder(id, merchant.getId());
        return "redirect:/merchant/orders";
    }

    @GetMapping("/refunds")
    public String refunds(HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        List<Refund> refunds = refundMapper.findByMerchantId(merchant.getId());
        model.addAttribute("merchant", merchant);
        model.addAttribute("refunds", refunds);
        return "merchant/refunds";
    }

    @PostMapping("/refund/approve/{id}")
    public String approveRefund(@PathVariable Long id,
                                @RequestParam(required = false) String result,
                                HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.processRefund(id, merchant.getId(), true, result);
        return "redirect:/merchant/refunds";
    }

    @PostMapping("/refund/reject/{id}")
    public String rejectRefund(@PathVariable Long id,
                               @RequestParam String result,
                               HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.processRefund(id, merchant.getId(), false, result);
        return "redirect:/merchant/refunds";
    }

    @GetMapping("/reviews")
    public String reviews(HttpSession session, Model model) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        List<Review> reviews = reviewMapper.findByMerchantProducts(merchant.getId());
        model.addAttribute("merchant", merchant);
        model.addAttribute("reviews", reviews);
        return "merchant/reviews";
    }

    @PostMapping("/review/reply/{id}")
    public String replyReview(@PathVariable Long id,
                              @RequestParam String merchantReply,
                              HttpSession session) {
        Merchant merchant = (Merchant) session.getAttribute("merchant");
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        Review review = reviewMapper.findById(id);
        if (review != null) {
            Product product = productMapper.findById(review.getProductId());
            if (product != null && product.getMerchantId().equals(merchant.getId())) {
                review.setMerchantReply(merchantReply);
                reviewMapper.updateMerchantReply(review);
            }
        }
        return "redirect:/merchant/reviews";
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/merchant/login";
    }
}
