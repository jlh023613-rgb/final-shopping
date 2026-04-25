package com.example.shopping.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Product {
    private Long id;
    private String name;
    private String category;
    private String brand;
    private String model;
    private String color;
    private String material;
    private String specifications;
    private String features;
    private String packagingList;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stock = 0;
    private String imageUrl;
    private String description;
    private Integer status = 1;
    private Long merchantId;
    private String auditReason;
    private LocalDateTime submittedAt;
    private LocalDateTime auditedAt;
    private String merchantShopName;
}
