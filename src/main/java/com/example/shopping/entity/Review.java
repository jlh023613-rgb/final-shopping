package com.example.shopping.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Review {
    private Long id;
    private Long userId;
    private Long productId;
    private Long orderId;
    private Integer rating;
    private String content;
    private String merchantReply;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    private String username;
    private String productName;
}
