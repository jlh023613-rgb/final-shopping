package com.example.shopping.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Order {
    private Long id;
    private String orderNo;
    private Long userId;
    private Long merchantId;
    private Long productId;
    private String productName;
    private String productImage;
    private Integer quantity;
    private BigDecimal unitPrice;
    private BigDecimal totalPrice;
    private String status;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime acceptedAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime completedAt;

    private String merchantShopName;
    private String username;
    private Boolean canComplaint;
    private Boolean canRefund;
    private Boolean hasComplaint;
    private Boolean hasRefund;
}
