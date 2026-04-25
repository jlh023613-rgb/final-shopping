package com.example.shopping.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AbnormalOrderRecord {
    private Integer serialNo;
    private String type;
    private Long sourceId;
    private String shopName;
    private String productName;
    private String issue;
    private Boolean handled;
    private String statusText;
    private String targetUrl;
    private String result;
    private LocalDateTime createdAt;
}
