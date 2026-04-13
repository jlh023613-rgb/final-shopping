package com.example.shopping.controller;

import com.example.shopping.entity.*;
import com.example.shopping.mapper.*;
import com.example.shopping.service.OrderService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@Controller
@RequestMapping("/user")
public class UserOrderController {

    private final UserMapper userMapper;
    private final ProductMapper productMapper;
    private final MerchantMapper merchantMapper;
    private final OrderMapper orderMapper;
    private final ReviewMapper reviewMapper;
    private final ComplaintMapper complaintMapper;
    private final AddressMapper addressMapper;
    private final RefundMapper refundMapper;
    private final OrderService orderService;

    public UserOrderController(UserMapper userMapper, ProductMapper productMapper,
                               MerchantMapper merchantMapper, OrderMapper orderMapper,
                               ReviewMapper reviewMapper, ComplaintMapper complaintMapper,
                               AddressMapper addressMapper, RefundMapper refundMapper,
                               OrderService orderService) {
        this.userMapper = userMapper;
        this.productMapper = productMapper;
        this.merchantMapper = merchantMapper;
        this.orderMapper = orderMapper;
        this.reviewMapper = reviewMapper;
        this.complaintMapper = complaintMapper;
        this.addressMapper = addressMapper;
        this.refundMapper = refundMapper;
        this.orderService = orderService;
    }

    private User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }

    @GetMapping("/order/create")
    public String createOrderPage(@RequestParam Long productId,
                                  @RequestParam(defaultValue = "1") Integer quantity,
                                  HttpSession session,
                                  Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Product product = productMapper.findById(productId);
        if (product == null) {
            return "redirect:/";
        }

        List<Address> addresses = addressMapper.findByUserId(user.getId());
        BigDecimal totalPrice = product.getPrice().multiply(new BigDecimal(quantity));

        model.addAttribute("user", user);
        model.addAttribute("product", product);
        model.addAttribute("quantity", quantity);
        model.addAttribute("addresses", addresses);
        model.addAttribute("totalPrice", totalPrice);
        return "user/create-order";
    }

    @PostMapping("/order/create")
    @ResponseBody
    public Map<String, Object> createOrder(@RequestParam Long productId,
                                           @RequestParam(defaultValue = "1") Integer quantity,
                                           @RequestParam(required = false) Long addressId,
                                           HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        try {
            User user = getCurrentUser(session);
            if (user == null) {
                result.put("success", false);
                result.put("message", "请先登录");
                return result;
            }

            Product product = productMapper.findById(productId);
            if (product == null) {
                result.put("success", false);
                result.put("message", "商品不存在");
                return result;
            }

            if (product.getMerchantId() != null) {
                Merchant merchant = merchantMapper.findById(product.getMerchantId());
                if (merchant != null && ("closed".equals(merchant.getStatus()) || "pending".equals(merchant.getStatus()))) {
                    result.put("success", false);
                    result.put("message", "该商品暂不支持购买");
                    return result;
                }
            }

            Address address = null;
            if (addressId != null) {
                address = addressMapper.findById(addressId);
            }
            if (address == null) {
                List<Address> addresses = addressMapper.findByUserId(user.getId());
                if (!addresses.isEmpty()) {
                    address = addresses.stream().filter(Address::getIsDefault).findFirst().orElse(addresses.get(0));
                }
            }

            if (address == null) {
                result.put("success", false);
                result.put("message", "请先添加收货地址");
                return result;
            }

            String orderNo = generateOrderNo();
            BigDecimal totalPrice = product.getPrice().multiply(new BigDecimal(quantity));

            Order order = new Order();
            order.setOrderNo(orderNo);
            order.setUserId(user.getId());
            order.setMerchantId(product.getMerchantId());
            order.setProductId(productId);
            order.setProductName(product.getName());
            order.setProductImage(product.getImageUrl());
            order.setQuantity(quantity);
            order.setUnitPrice(product.getPrice());
            order.setTotalPrice(totalPrice);
            order.setStatus("pending");
            order.setReceiverName(address.getReceiverName());
            order.setReceiverPhone(address.getReceiverPhone());
            order.setReceiverAddress(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetailAddress());

            orderMapper.insert(order);
            result.put("success", true);
            result.put("message", "下单成功");
            result.put("orderId", order.getId());
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "下单失败: " + e.getMessage());
        }
        return result;
    }

    @GetMapping("/orders")
    public String orders(HttpSession session, Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        try {
            List<Order> orders = orderService.findByUserId(user.getId());
            model.addAttribute("user", user);
            model.addAttribute("orders", orders);
        } catch (Exception e) {
            model.addAttribute("user", user);
            model.addAttribute("orders", java.util.Collections.emptyList());
            model.addAttribute("error", "查询订单失败: " + e.getMessage());
        }
        return "user/orders";
    }

    @PostMapping("/order/confirm-receive/{id}")
    public String confirmReceive(@PathVariable Long id, HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        orderService.confirmReceive(id, user.getId());
        return "redirect:/user/orders";
    }

    @PostMapping("/order/cancel/{id}")
    public String cancelOrder(@PathVariable Long id, HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        orderService.cancelOrder(id, user.getId());
        return "redirect:/user/orders";
    }

    @GetMapping("/review/{orderId}")
    public String reviewPage(@PathVariable Long orderId,
                             HttpSession session,
                             Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Order order = orderService.findById(orderId);
        if (order == null || !order.getUserId().equals(user.getId()) || !"completed".equals(order.getStatus())) {
            return "redirect:/user/orders";
        }

        Review existingReview = reviewMapper.findByProductId(order.getProductId()).stream()
                .filter(r -> r.getOrderId().equals(orderId) && r.getUserId().equals(user.getId()))
                .findFirst().orElse(null);

        if (existingReview != null) {
            model.addAttribute("error", "该订单已评价");
            return "redirect:/user/orders";
        }

        model.addAttribute("order", order);
        model.addAttribute("user", user);
        return "user/review";
    }

    @PostMapping("/review/submit")
    public String submitReview(@RequestParam Long orderId,
                               @RequestParam Long productId,
                               @RequestParam Integer rating,
                               @RequestParam(required = false) String content,
                               HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Order order = orderService.findById(orderId);
        if (order == null || !order.getUserId().equals(user.getId())) {
            return "redirect:/user/orders";
        }

        Review review = new Review();
        review.setUserId(user.getId());
        review.setProductId(productId);
        review.setOrderId(orderId);
        review.setRating(rating);
        review.setContent(content);
        reviewMapper.insert(review);

        order.setStatus("reviewed");
        orderMapper.updateStatus(order);

        return "redirect:/user/orders";
    }

    @GetMapping("/complaint/{orderId}")
    public String complaintPage(@PathVariable Long orderId,
                                HttpSession session,
                                Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Order order = orderService.findById(orderId);
        if (order == null || !order.getUserId().equals(user.getId())) {
            return "redirect:/user/orders";
        }

        if (!"completed".equals(order.getStatus())) {
            model.addAttribute("error", "只有已完成的订单才能投诉");
            return "redirect:/user/orders";
        }

        Complaint existingComplaint = complaintMapper.findByOrderId(orderId);
        if (existingComplaint != null) {
            model.addAttribute("error", "该订单已投诉");
            return "redirect:/user/orders";
        }

        Merchant merchant = merchantMapper.findById(order.getMerchantId());
        model.addAttribute("order", order);
        model.addAttribute("merchant", merchant);
        model.addAttribute("user", user);
        return "user/complaint";
    }

    @PostMapping("/complaint/submit")
    public String submitComplaint(@RequestParam Long orderId,
                                  @RequestParam Long merchantId,
                                  @RequestParam String content,
                                  HttpSession session) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Order order = orderService.findById(orderId);
        if (order == null || !order.getUserId().equals(user.getId()) || !"completed".equals(order.getStatus())) {
            return "redirect:/user/orders";
        }

        Complaint existingComplaint = complaintMapper.findByOrderId(orderId);
        if (existingComplaint != null) {
            return "redirect:/user/orders";
        }

        Complaint complaint = new Complaint();
        complaint.setUserId(user.getId());
        complaint.setMerchantId(merchantId);
        complaint.setOrderId(orderId);
        complaint.setContent(content);
        complaint.setStatus("pending");
        complaintMapper.insert(complaint);

        return "redirect:/user/orders";
    }

    @GetMapping("/refund/{orderId}")
    public String refundPage(@PathVariable Long orderId,
                             HttpSession session,
                             Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Order order = orderService.findById(orderId);
        if (order == null || !order.getUserId().equals(user.getId())) {
            return "redirect:/user/orders";
        }

        if (!Boolean.TRUE.equals(order.getCanRefund())) {
            model.addAttribute("error", "该订单不支持申请退款");
            return "redirect:/user/orders";
        }

        model.addAttribute("order", order);
        model.addAttribute("user", user);
        return "user/refund";
    }

    @PostMapping("/refund/submit")
    public String submitRefund(@RequestParam Long orderId,
                               @RequestParam String reason,
                               HttpSession session,
                               Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        Refund refund = orderService.applyRefund(orderId, user.getId(), reason);
        if (refund == null) {
            model.addAttribute("error", "退款申请失败");
            return "redirect:/user/orders";
        }

        return "redirect:/user/orders";
    }

    private String generateOrderNo() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        String timestamp = LocalDateTime.now().format(formatter);
        String random = String.format("%04d", new Random().nextInt(10000));
        return "ORD" + timestamp + random;
    }
}
