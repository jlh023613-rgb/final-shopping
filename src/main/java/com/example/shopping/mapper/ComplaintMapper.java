package com.example.shopping.mapper;

import com.example.shopping.entity.Complaint;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ComplaintMapper {
    void insert(Complaint complaint);
    Complaint findById(Long id);
    Complaint findByOrderId(Long orderId);
    List<Complaint> findByUserId(Long userId);
    List<Complaint> findByMerchantId(Long merchantId);
    List<Complaint> findByStatus(String status);
    List<Complaint> findAll();
    void updateResult(Complaint complaint);
}
