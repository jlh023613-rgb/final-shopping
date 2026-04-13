package com.example.shopping.controller;

import com.example.shopping.entity.*;
import com.example.shopping.mapper.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@Controller
public class CheckoutController {

    private final CartMapper cartMapper;
    private final UserMapper userMapper;
    private final ProductMapper productMapper;
    private final AddressMapper addressMapper;
    private final OrderMapper orderMapper;
    private final MerchantMapper merchantMapper;

    public CheckoutController(CartMapper cartMapper, UserMapper userMapper,
                              ProductMapper productMapper, AddressMapper addressMapper,
                              OrderMapper orderMapper, MerchantMapper merchantMapper) {
        this.cartMapper = cartMapper;
        this.userMapper = userMapper;
        this.productMapper = productMapper;
        this.addressMapper = addressMapper;
        this.orderMapper = orderMapper;
        this.merchantMapper = merchantMapper;
    }

    private User getCurrentUser(HttpSession session) {
        return (User) session.getAttribute("user");
    }

    @GetMapping("/checkout")
    public String checkoutPage(@RequestParam String ids, HttpSession session, Model model) {
        User user = getCurrentUser(session);
        if (user == null) {
            return "redirect:/user/login";
        }

        String[] idArray = ids.split(",");
        List<CartItem> selectedItems = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        for (String idStr : idArray) {
            try {
                Long id = Long.parseLong(idStr.trim());
                List<CartItem> allItems = cartMapper.findByUserId(user.getId());
                for (CartItem item : allItems) {
                    if (item.getId().equals(id)) {
                        selectedItems.add(item);
                        BigDecimal itemPrice = item.getUnitPrice() != null ? item.getUnitPrice() : item.getPrice();
                        BigDecimal insurancePrice = item.getInsurancePrice() != null ? item.getInsurancePrice() : BigDecimal.ZERO;
                        total = total.add(itemPrice.multiply(new BigDecimal(item.getQuantity())).add(insurancePrice));
                        break;
                    }
                }
            } catch (NumberFormatException e) {
                // ignore invalid id
            }
        }

        if (selectedItems.isEmpty()) {
            return "redirect:/cart";
        }

        List<Address> addresses = addressMapper.findByUserId(user.getId());

        model.addAttribute("user", user);
        model.addAttribute("cartItems", selectedItems);
        model.addAttribute("total", total);
        model.addAttribute("addresses", addresses);
        model.addAttribute("cartIds", ids);
        return "user/checkout";
    }

    @PostMapping("/checkout")
    @ResponseBody
    public Map<String, Object> processCheckout(@RequestParam String cartIds,
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

            String[] idArray = cartIds.split(",");
            List<Long> processedIds = new ArrayList<>();
            int orderCount = 0;

            for (String idStr : idArray) {
                try {
                    Long cartId = Long.parseLong(idStr.trim());
                    List<CartItem> allItems = cartMapper.findByUserId(user.getId());
                    for (CartItem item : allItems) {
                        if (item.getId().equals(cartId)) {
                            Product product = productMapper.findById(item.getProductId());
                            if (product == null) continue;

                            if (product.getMerchantId() != null) {
                                Merchant merchant = merchantMapper.findById(product.getMerchantId());
                                if (merchant != null && ("closed".equals(merchant.getStatus()) || "pending".equals(merchant.getStatus()))) {
                                    continue;
                                }
                            }

                            String orderNo = generateOrderNo();
                            BigDecimal itemPrice = item.getUnitPrice() != null ? item.getUnitPrice() : item.getPrice();
                            BigDecimal totalPrice = itemPrice.multiply(new BigDecimal(item.getQuantity()));

                            Order order = new Order();
                            order.setOrderNo(orderNo);
                            order.setUserId(user.getId());
                            order.setMerchantId(product.getMerchantId());
                            order.setProductId(product.getId());
                            order.setProductName(product.getName());
                            order.setProductImage(product.getImageUrl());
                            order.setQuantity(item.getQuantity());
                            order.setUnitPrice(itemPrice);
                            order.setTotalPrice(totalPrice);
                            order.setStatus("pending");
                            order.setReceiverName(address.getReceiverName());
                            order.setReceiverPhone(address.getReceiverPhone());
                            order.setReceiverAddress(address.getProvince() + address.getCity() + address.getDistrict() + address.getDetailAddress());

                            orderMapper.insert(order);
                            processedIds.add(cartId);
                            orderCount++;
                            break;
                        }
                    }
                } catch (NumberFormatException e) {
                    // ignore invalid id
                }
            }

            for (Long cartId : processedIds) {
                cartMapper.delete(cartId, user.getId());
            }

            result.put("success", true);
            result.put("message", "下单成功，共创建 " + orderCount + " 个订单");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "下单失败: " + e.getMessage());
        }
        return result;
    }

    private String generateOrderNo() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        String timestamp = LocalDateTime.now().format(formatter);
        String random = String.format("%04d", new Random().nextInt(10000));
        return "ORD" + timestamp + random;
    }
}
