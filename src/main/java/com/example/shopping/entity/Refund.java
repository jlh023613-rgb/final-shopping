package com.example.shopping.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Refund {
    private Long id;
    private Long orderId;
    private Long userId;
    private Long merchantId;
    private String reason;
    private String status;
    private String result;
    private LocalDateTime createdAt;
    private LocalDateTime processedAt;

    private String username;
    private String merchantShopName;
    private String orderNo;
    private String productName;
}
