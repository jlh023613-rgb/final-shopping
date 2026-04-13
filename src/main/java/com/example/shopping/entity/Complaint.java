package com.example.shopping.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Complaint {
    private Long id;
    private Long userId;
    private Long merchantId;
    private Long orderId;
    private String content;
    private String status;
    private String result;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String username;
    private String merchantShopName;
    private String orderNo;
    private String productName;
}
