package com.example.shopping.controller;

import com.example.shopping.entity.Merchant;
import com.example.shopping.entity.Order;
import com.example.shopping.entity.Product;
import com.example.shopping.entity.Refund;
import com.example.shopping.entity.Review;
import com.example.shopping.mapper.MerchantMapper;
import com.example.shopping.mapper.ProductMapper;
import com.example.shopping.mapper.RefundMapper;
import com.example.shopping.mapper.ReviewMapper;
import com.example.shopping.service.OrderService;
import com.example.shopping.service.UploadStorageService;
import jakarta.servlet.http.HttpSession;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;

@Controller
@RequestMapping("/merchant")
public class MerchantController {

    private final MerchantMapper merchantMapper;
    private final ProductMapper productMapper;
    private final ReviewMapper reviewMapper;
    private final RefundMapper refundMapper;
    private final OrderService orderService;
    private final UploadStorageService uploadStorageService;
    private final PasswordEncoder passwordEncoder;

    public MerchantController(MerchantMapper merchantMapper,
                              ProductMapper productMapper,
                              ReviewMapper reviewMapper,
                              RefundMapper refundMapper,
                              OrderService orderService,
                              UploadStorageService uploadStorageService,
                              PasswordEncoder passwordEncoder) {
        this.merchantMapper = merchantMapper;
        this.productMapper = productMapper;
        this.reviewMapper = reviewMapper;
        this.refundMapper = refundMapper;
        this.orderService = orderService;
        this.uploadStorageService = uploadStorageService;
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
                merchant.setShopImage(uploadStorageService.storeImage(shopImage, "shop"));
            } catch (IOException e) {
                model.addAttribute("error", "店铺图片上传失败，请重试");
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
                        HttpSession session) {
        Merchant merchant = merchantMapper.findByUsername(username);
        if (merchant == null) {
            return "redirect:/merchant/login?error";
        }
        if (!passwordEncoder.matches(password, merchant.getPassword())) {
            return "redirect:/merchant/login?error";
        }

        merchant = refreshMerchantStatusIfNeeded(merchant);
        if ("pending".equals(merchant.getStatus())) {
            return "redirect:/merchant/login?pending";
        }
        if ("rejected".equals(merchant.getStatus())) {
            return "redirect:/merchant/login?rejected";
        }

        session.setAttribute("merchant", merchant);
        return "redirect:/merchant/dashboard";
    }

    @GetMapping("/dashboard")
    public String dashboard(HttpSession session, Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        try {
            List<Product> products = productMapper.findByMerchantId(merchant.getId());
            List<Order> orders = orderService.findByMerchantId(merchant.getId());
            List<Review> reviews = reviewMapper.findByMerchantProducts(merchant.getId());
            List<Refund> refunds = refundMapper.findByMerchantId(merchant.getId());

            long pendingOrders = orders.stream().filter(order -> "pending".equals(order.getStatus())).count();
            long shippingOrders = orders.stream().filter(order -> "shipping".equals(order.getStatus())).count();
            long deliveredOrders = orders.stream().filter(order -> "delivered".equals(order.getStatus())).count();
            long pendingRefunds = refunds.stream()
                    .filter(refund -> "pending".equals(refund.getStatus()) || "escalated".equals(refund.getStatus()))
                    .count();

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
            populateMerchantState(model, merchant);
        } catch (Exception e) {
            model.addAttribute("merchant", merchant);
            model.addAttribute("products", Collections.emptyList());
            model.addAttribute("orders", Collections.emptyList());
            model.addAttribute("reviews", Collections.emptyList());
            model.addAttribute("refunds", Collections.emptyList());
            model.addAttribute("pendingOrders", 0L);
            model.addAttribute("shippingOrders", 0L);
            model.addAttribute("deliveredOrders", 0L);
            model.addAttribute("pendingRefunds", 0L);
            model.addAttribute("totalProducts", 0);
            model.addAttribute("totalOrders", 0);
            model.addAttribute("error", "加载数据失败：" + e.getMessage());
            populateMerchantState(model, merchant);
        }
        return "merchant/dashboard";
    }

    @GetMapping("/products")
    public String products(@RequestParam(required = false) String notice,
                           HttpSession session,
                           Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        model.addAttribute("merchant", merchant);
        model.addAttribute("products", productMapper.findByMerchantId(merchant.getId()));
        model.addAttribute("notice", notice);
        populateMerchantState(model, merchant);
        return "merchant/products";
    }

    @GetMapping("/product/add")
    public String addProductPage(HttpSession session, Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }
        if (isProductManagementLocked(merchant)) {
            return "redirect:/merchant/products?notice=shop_locked";
        }

        model.addAttribute("merchant", merchant);
        populateMerchantState(model, merchant);
        return "merchant/product-add";
    }

    @PostMapping("/product/add")
    public String addProduct(@RequestParam String name,
                             @RequestParam BigDecimal price,
                             @RequestParam(required = false) BigDecimal originalPrice,
                             @RequestParam(defaultValue = "0") Integer stock,
                             @RequestParam(required = false) String description,
                             @RequestParam(required = false) String specifications,
                             @RequestParam(required = false) String features,
                             @RequestParam(required = false) String packagingList,
                             @RequestParam(required = false) MultipartFile imageFile,
                             HttpSession session,
                             Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }
        if (isProductManagementLocked(merchant)) {
            return "redirect:/merchant/products?notice=shop_locked";
        }
        if (merchant.getCategory() == null || merchant.getCategory().isBlank()) {
            model.addAttribute("merchant", merchant);
            model.addAttribute("error", "店铺尚未分配经营分类，暂时无法提交商品申请");
            populateMerchantState(model, merchant);
            return "merchant/product-add";
        }

        Product product = new Product();
        product.setName(name);
        product.setCategory(merchant.getCategory());
        product.setPrice(price);
        product.setOriginalPrice(originalPrice);
        product.setStock(stock);
        product.setDescription(description);
        product.setSpecifications(specifications);
        product.setFeatures(features);
        product.setPackagingList(packagingList);
        product.setStatus(0);
        product.setMerchantId(merchant.getId());
        product.setAuditReason("待审核，等待管理员处理");
        product.setSubmittedAt(LocalDateTime.now());

        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                product.setImageUrl(uploadStorageService.storeImage(imageFile, merchant.getCategory()));
            } catch (IOException e) {
                model.addAttribute("merchant", merchant);
                model.addAttribute("error", "商品图片上传失败，请重新提交");
                populateMerchantState(model, merchant);
                return "merchant/product-add";
            }
        }

        productMapper.insert(product);
        return "redirect:/merchant/products?notice=product_submitted";
    }

    @GetMapping("/product/edit/{id}")
    public String editProductPage(@PathVariable Long id, HttpSession session, Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }
        if (isProductManagementLocked(merchant)) {
            return "redirect:/merchant/products?notice=shop_locked";
        }

        Product product = productMapper.findById(id);
        if (product == null || !product.getMerchantId().equals(merchant.getId())) {
            return "redirect:/merchant/products";
        }

        model.addAttribute("merchant", merchant);
        model.addAttribute("product", product);
        populateMerchantState(model, merchant);
        return "merchant/product-edit";
    }

    @PostMapping("/product/edit/{id}")
    public String editProduct(@PathVariable Long id,
                              @RequestParam String name,
                              @RequestParam BigDecimal price,
                              @RequestParam(required = false) BigDecimal originalPrice,
                              @RequestParam(defaultValue = "0") Integer stock,
                              @RequestParam(required = false) String description,
                              @RequestParam(required = false) String specifications,
                              @RequestParam(required = false) String features,
                              @RequestParam(required = false) String packagingList,
                              @RequestParam(required = false) MultipartFile imageFile,
                              HttpSession session) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }
        if (isProductManagementLocked(merchant)) {
            return "redirect:/merchant/products?notice=shop_locked";
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
        product.setSpecifications(specifications);
        product.setFeatures(features);
        product.setPackagingList(packagingList);

        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                product.setImageUrl(uploadStorageService.storeImage(imageFile, merchant.getCategory()));
            } catch (IOException e) {
                return "redirect:/merchant/products?notice=image_upload_failed";
            }
        }

        productMapper.update(product);
        return "redirect:/merchant/products";
    }

    @PostMapping("/product/delete/{id}")
    public String deleteProduct(@PathVariable Long id, HttpSession session) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }
        if (isProductManagementLocked(merchant)) {
            return "redirect:/merchant/products?notice=shop_locked";
        }

        Product product = productMapper.findById(id);
        if (product != null && product.getMerchantId().equals(merchant.getId())) {
            productMapper.delete(id);
        }
        return "redirect:/merchant/products";
    }

    @GetMapping("/orders")
    public String orders(HttpSession session, Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        model.addAttribute("merchant", merchant);
        model.addAttribute("orders", orderService.findByMerchantId(merchant.getId()));
        populateMerchantState(model, merchant);
        return "merchant/orders";
    }

    @PostMapping("/order/accept/{id}")
    public String acceptOrder(@PathVariable Long id, HttpSession session) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.acceptOrder(id, merchant.getId());
        return "redirect:/merchant/orders";
    }

    @PostMapping("/order/deliver/{id}")
    public String deliverOrder(@PathVariable Long id, HttpSession session) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.deliverOrder(id, merchant.getId());
        return "redirect:/merchant/orders";
    }

    @GetMapping("/refunds")
    public String refunds(HttpSession session, Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        model.addAttribute("merchant", merchant);
        model.addAttribute("refunds", refundMapper.findByMerchantId(merchant.getId()));
        populateMerchantState(model, merchant);
        return "merchant/refunds";
    }

    @PostMapping("/refund/approve/{id}")
    public String approveRefund(@PathVariable Long id,
                                @RequestParam(required = false) String result,
                                HttpSession session) {
        Merchant merchant = getCurrentMerchant(session);
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
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        orderService.processRefund(id, merchant.getId(), false, result);
        return "redirect:/merchant/refunds";
    }

    @GetMapping("/reviews")
    public String reviews(HttpSession session, Model model) {
        Merchant merchant = getCurrentMerchant(session);
        if (merchant == null) {
            return "redirect:/merchant/login";
        }

        model.addAttribute("merchant", merchant);
        model.addAttribute("reviews", reviewMapper.findByMerchantProducts(merchant.getId()));
        populateMerchantState(model, merchant);
        return "merchant/reviews";
    }

    @PostMapping("/review/reply/{id}")
    public String replyReview(@PathVariable Long id,
                              @RequestParam String merchantReply,
                              HttpSession session) {
        Merchant merchant = getCurrentMerchant(session);
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

    private Merchant getCurrentMerchant(HttpSession session) {
        Merchant sessionMerchant = (Merchant) session.getAttribute("merchant");
        if (sessionMerchant == null) {
            return null;
        }

        Merchant merchant = merchantMapper.findById(sessionMerchant.getId());
        if (merchant == null) {
            session.removeAttribute("merchant");
            return null;
        }

        merchant = refreshMerchantStatusIfNeeded(merchant);
        session.setAttribute("merchant", merchant);
        return merchant;
    }

    private Merchant refreshMerchantStatusIfNeeded(Merchant merchant) {
        if (!"closed".equals(merchant.getStatus())) {
            return merchant;
        }
        if (merchant.getCloseUntil() != null && !merchant.getCloseUntil().isAfter(LocalDateTime.now())) {
            merchantMapper.clearClosure(merchant.getId());
            Merchant refreshed = merchantMapper.findById(merchant.getId());
            return refreshed != null ? refreshed : merchant;
        }
        return merchant;
    }

    private boolean isProductManagementLocked(Merchant merchant) {
        if (merchant == null || !"closed".equals(merchant.getStatus())) {
            return false;
        }
        return merchant.getCloseUntil() == null || merchant.getCloseUntil().isAfter(LocalDateTime.now());
    }

    private void populateMerchantState(Model model, Merchant merchant) {
        boolean locked = isProductManagementLocked(merchant);
        model.addAttribute("productManagementLocked", locked);
        model.addAttribute("showClosureNotice", locked);
        model.addAttribute("closureReason", merchant.getCloseReason());
        model.addAttribute("closureUntil", merchant.getCloseUntil());
    }
}
