package com.example.shopping.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class Merchant {
    private Long id;
    private String username;
    private String password;
    private String shopName;
    private String shopDescription;
    private String shopImage;
    private String category;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
